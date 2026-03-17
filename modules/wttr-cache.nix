# modules/home/wttr-cache.nix
#
# home-manager module: wttr.in weather PNG cache for hyprlock
#
# Usage:
#   imports = [ ./modules/home/wttr-cache.nix ];
#   services.wttr-cache = {
#     enable = true;
#     # all options are optional, defaults shown below
#   };
#
# hyprlock.conf:
#   image {
#     path = /home/YOU/.cache/wttr/weather.png
#     size = 320
#     ...
#   }

{ config, lib, pkgs, ... }:

let
  cfg = config.services.wttr-cache;

  # Build the options suffix for the PNG URL.
  # e.g. "v2_t_lang=de" or "v2_t" or "v2"
  imageOptions = lib.concatStringsSep "_" (
    lib.optional (cfg.format != null) cfg.format
    ++ lib.optional cfg.transparent "t"
    ++ lib.optional (cfg.lang != null) "lang=${cfg.lang}"
  );

  # PNG URL suffix — evaluated at Nix time, inlined as a literal in the script.
  # e.g. "_v2_t.png" or ".png" if no options
  pngSuffix = if imageOptions == "" then ".png" else "_${imageOptions}.png";

  # Auto-detect URL: slash + options, no location — wttr.in uses IP geo.
  autoUrl = "https://wttr.in/${pngSuffix}";

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
        --output "$WEATHER_PNG_TMP" \
        "$url"
    }

    is_valid_png() {
      local magic
      magic=$(${pkgs.coreutils}/bin/od -An -tx1 -N8 "$WEATHER_PNG_TMP" 2>/dev/null \
              | tr -d ' \n')
      [ "$magic" = "89504e470d0a1a0a" ]
    }

    commit_png() {
      ${pkgs.coreutils}/bin/mv "$WEATHER_PNG_TMP" "$WEATHER_PNG"
    }

    # Simple location detection — no lang/format params needed, just %l
    detect_and_save_location() {
      local detected
      detected=$(
        ${pkgs.curl}/bin/curl -sf --max-time "$TIMEOUT" \
          "https://wttr.in?format=%l" 2>/dev/null \
        || true
      )
      if [ -n "$detected" ]; then
        echo "$detected" > "$LOCATION_FILE"
        log "Saved location: $detected"
      fi
    }

    # --- Attempt 1: auto-detect via IP ---
    if fetch_png "${autoUrl}" && is_valid_png; then
      commit_png
      log "OK (auto) — ${autoUrl}"
      detect_and_save_location &
      exit 0
    fi

    log "Auto-detect failed, trying saved location fallback..."

    # --- Attempt 2: saved location ---
    SAVED_LOC=""
    if [ -f "$LOCATION_FILE" ]; then
      SAVED_LOC=$(${pkgs.coreutils}/bin/cat "$LOCATION_FILE")
    fi

    if [ -n "''${SAVED_LOC}" ]; then
      ENCODED_LOC=$(${pkgs.python3}/bin/python3 -c \
        "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" \
        "''${SAVED_LOC}")
      SAVED_URL="https://wttr.in/''${ENCODED_LOC}${pngSuffix}"
      if fetch_png "''${SAVED_URL}" && is_valid_png; then
        commit_png
        log "OK (saved: ''${SAVED_LOC}) — geo-detection was blocked"
        exit 0
      fi
    fi

    # --- Attempt 3: nothing worked, keep cache untouched ---
    log "FAIL — network unavailable or wttr.in unreachable, cache unchanged"
    rm -f "$WEATHER_PNG_TMP"
    exit 0
  '';

in {
  options.services.wttr-cache = {
    enable = lib.mkEnableOption "wttr.in weather PNG cache for hyprlock";

    interval = lib.mkOption {
      type    = lib.types.str;
      default = "30min";
      description = "How often to refresh. Systemd time span syntax, e.g. \"15min\", \"1h\".";
    };

    format = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = "v2";
      description = ''
        wttr.in image variant:
          null  — standard 3-day forecast
          "1"   — current conditions + today only
          "v2"  — data-rich: moon phase, dawn/dusk, coords (default)
          "v2d" — v2 with Nerd Fonts, day palette
          "v2n" — v2 with Nerd Fonts, night palette
      '';
    };

    transparent = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = "Request a transparent PNG background.";
    };

    lang = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = null;
      description = "Language code for wttr.in labels, e.g. \"de\", \"nl\". null = wttr.in default (English).";
    };

    timeoutSeconds = lib.mkOption {
      type    = lib.types.int;
      default = 15;
      description = "curl timeout in seconds per fetch attempt.";
    };

    resumeDelay = lib.mkOption {
      type    = lib.types.str;
      default = "20s";
      description = "How long to wait after suspend resume before fetching. Systemd time span syntax.";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.wttr-cache = {
      Unit = {
        Description = "Update wttr.in weather PNG cache";
        After       = [ "network-online.target" ];
        Wants       = [ "network-online.target" ];
      };
      Service = {
        Type         = "oneshot";
        ExecStartPre = "-${pkgs.coreutils}/bin/rm -f %h/.cache/wttr/weather.png.tmp";
        ExecStart    = "${updateScript}";
      };
    };

    systemd.user.timers.wttr-cache = {
      Unit.Description = "Refresh wttr.in weather PNG every ${cfg.interval}";
      Timer = {
        OnBootSec       = "2min";
        OnUnitActiveSec = cfg.interval;
        Unit            = "wttr-cache.service";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.wttr-cache-resume = {
      Unit = {
        Description = "Refresh wttr.in cache after suspend resume";
        After = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
      };
      Service = {
        Type         = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep ${cfg.resumeDelay}";
        ExecStart    = "${updateScript}";
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
