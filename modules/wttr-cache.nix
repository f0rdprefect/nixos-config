# modules/home/wttr-cache.nix
#
# home-manager module: wttr.in weather PNG cache for hyprlock
#
# Fetches a wttr.in weather PNG every N minutes and caches it locally.
# On network failure (e.g. post-suspend), keeps the last cached image.
# If geo-detection is blocked, falls back to the last known auto-detected location.
#
# Usage in your home.nix / flake:
#
#   imports = [ ./modules/home/wttr-cache.nix ];
#
#   services.wttr-cache = {
#     enable = true;
#     # All options below are optional — defaults shown
#   };
#
#   Then in hyprlock.conf:
#     image {
#       path = /home/YOU/.cache/wttr/weather.png
#       size = 300
#       ...
#     }

{ config, lib, pkgs, ... }:

let
  cfg = config.services.wttr-cache;

  # URL suffix that controls the image style.
  # See https://wttr.in/:help for all options.
  # Options are joined with _ for PNG URLs (not & or ?).
  imageOptions = lib.concatStringsSep "_" (
    lib.optional cfg.transparent "t"
    ++ lib.optional (cfg.format != null) cfg.format
    ++ lib.optional (cfg.lang != null) "lang=${cfg.lang}"
  );

  # Build the wttr.in PNG URL for a given location string.
  # Empty string = auto-detect from IP.
  mkUrl = location:
    let
      locPart = if location == "" then "" else "/${location}";
      optPart = if imageOptions == "" then ".png" else "_${imageOptions}.png";
    in
      "https://wttr.in${locPart}${optPart}";

  # The update script — embedded as a Nix-managed derivation so all deps
  # (curl, python3, coreutils) come from the Nix store, not PATH.
  updateScript = pkgs.writeShellScript "wttr-cache-update" ''
    set -euo pipefail

    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/wttr"
    WEATHER_PNG="$CACHE_DIR/weather.png"
    WEATHER_PNG_TMP="$CACHE_DIR/weather.png.tmp"
    LOCATION_FILE="$CACHE_DIR/location.txt"
    LOG_FILE="$CACHE_DIR/weather.log"
    TIMEOUT="${toString cfg.timeoutSeconds}"

    mkdir -p "$CACHE_DIR"

    log() {
      echo "[$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
      # Rotate log if over 100 KB
      local size
      size=$(${pkgs.coreutils}/bin/stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
      if [ "$size" -gt 102400 ]; then
        ${pkgs.coreutils}/bin/tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp"
        ${pkgs.coreutils}/bin/mv "$LOG_FILE.tmp" "$LOG_FILE"
      fi
    }

    fetch_png() {
      local url="$1"
      ${pkgs.curl}/bin/curl -sf --max-time "$TIMEOUT" \
        -H "Accept-Language: ${cfg.lang or "en"}" \
        --output "$WEATHER_PNG_TMP" \
        "$url"
    }

    # Sanity-check: is the downloaded file actually a PNG?
    is_valid_png() {
      # PNG magic bytes: 89 50 4E 47 0D 0A 1A 0A
      local magic
      magic=$(${pkgs.coreutils}/bin/od -An -tx1 -N8 "$WEATHER_PNG_TMP" 2>/dev/null \
              | tr -d ' \n')
      [ "$magic" = "89504e470d0a1a0a" ]
    }

    commit_png() {
      ${pkgs.coreutils}/bin/mv "$WEATHER_PNG_TMP" "$WEATHER_PNG"
    }

    # --- Detect location from a successful auto-fetch ---
    # wttr.in embeds the resolved location in PNG metadata (tEXt chunk "Comment")
    # but that requires exiftool. Instead we do a cheap parallel text query.
    detect_and_save_location() {
      local detected
      detected=$(
        ${pkgs.curl}/bin/curl -sf --max-time "$TIMEOUT" \
          -H "Accept-Language: en" \
          "https://wttr.in?format=%l" 2>/dev/null \
        | ${pkgs.gnused}/bin/sed 's/[[:space:]]*$//' \
        || true
      )
      if [ -n "$detected" ]; then
        echo "$detected" > "$LOCATION_FILE"
        log "Saved location: $detected"
      fi
    }

    # ---- Main logic ----

    # Attempt 1: auto-detect location (blank location = IP-based)
    AUTO_URL="${mkUrl ""}"
    if fetch_png "$AUTO_URL" && is_valid_png; then
      commit_png
      log "OK (auto) — $AUTO_URL"
      # Fire-and-forget: save location in background for fallback
      detect_and_save_location &
      exit 0
    fi

    log "Auto-detect failed, trying saved location fallback..."

    # Attempt 2: use last saved location
    SAVED_LOC=""
    if [ -f "$LOCATION_FILE" ]; then
      SAVED_LOC=$(${pkgs.coreutils}/bin/cat "$LOCATION_FILE")
    fi

    if [ -n "$SAVED_LOC" ]; then
      ENCODED_LOC=$(${pkgs.python3}/bin/python3 -c \
        "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" \
        "$SAVED_LOC")
      SAVED_URL="${
        # We can't call mkUrl with a shell var, so reconstruct inline
        let base = "https://wttr.in";
            opt  = if imageOptions == "" then ".png" else "_${imageOptions}.png";
        in "${base}/$ENCODED_LOC${opt}"
      }"
      if fetch_png "$SAVED_URL" && is_valid_png; then
        commit_png
        log "OK (saved: $SAVED_LOC) — geo-detection was blocked"
        exit 0
      fi
    fi

    # Attempt 3: nothing worked — keep cache untouched
    log "FAIL — network unavailable or wttr.in unreachable, cache unchanged"
    rm -f "$WEATHER_PNG_TMP"
    exit 0   # always exit 0 so systemd doesn't flag this as a failure
  '';

in {
  options.services.wttr-cache = {
    enable = lib.mkEnableOption "wttr.in weather PNG cache for hyprlock";

    interval = lib.mkOption {
      type    = lib.types.str;
      default = "30min";
      description = ''
        How often to refresh the weather PNG.
        Accepts systemd time span syntax, e.g. "15min", "1h".
      '';
    };

    format = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = "v2";
      description = ''
        wttr.in image variant. Common values:
          null  — standard 3-day forecast
          "1"   — current conditions + today only
          "v2"  — data-rich (moon phase, dawn/dusk, coordinates)
          "v2d" — v2 with Nerd Fonts (day palette)
          "v2n" — v2 with Nerd Fonts (night palette)
      '';
    };

    transparent = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = "Request a transparent PNG background (recommended for lockscreen overlays).";
    };

    lang = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = "en";
      description = "Language code for wttr.in output, e.g. \"de\", \"nl\", \"fr\".";
    };

    timeoutSeconds = lib.mkOption {
      type    = lib.types.int;
      default = 15;
      description = "curl timeout in seconds per fetch attempt.";
    };

    resumeDelay = lib.mkOption {
      type    = lib.types.str;
      default = "20s";
      description = ''
        How long to wait after suspend resume before fetching.
        Gives NetworkManager time to reconnect.
        Accepts systemd time span syntax, e.g. "20s", "1min".
      '';
    };

    cacheDir = lib.mkOption {
      type    = lib.types.str;
      default = "%h/.cache/wttr";   # %h = $HOME in systemd user units
      description = "Directory where the PNG and metadata are cached. %h expands to $HOME.";
    };
  };

  config = lib.mkIf cfg.enable {

    # The oneshot service that runs the update script
    systemd.user.services.wttr-cache = {
      Unit = {
        Description = "Update wttr.in weather PNG cache";
        After       = [ "network-online.target" ];
        Wants       = [ "network-online.target" ];
      };
      Service = {
        Type       = "oneshot";
        ExecStart  = "${updateScript}";
        # Don't let a stale tmp file linger on crash
        ExecStartPre = "-${pkgs.coreutils}/bin/rm -f ${cfg.cacheDir}/weather.png.tmp";
      };
    };

    # Timer: on login + every N minutes
    systemd.user.timers.wttr-cache = {
      Unit.Description  = "Refresh wttr.in weather PNG every ${cfg.interval}";
      Timer = {
        OnBootSec        = "2min";
        OnUnitActiveSec  = cfg.interval;
        Unit             = "wttr-cache.service";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    # Post-suspend refresh — fires after every resume
    systemd.user.services.wttr-cache-resume = {
      Unit = {
        Description = "Refresh wttr.in cache after suspend resume";
        After       = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
      };
      Service = {
        Type           = "oneshot";
        ExecStartPre   = "${pkgs.coreutils}/bin/sleep ${cfg.resumeDelay}";
        ExecStart      = "${updateScript}";
      };
      Install.WantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
    };
  };
}
