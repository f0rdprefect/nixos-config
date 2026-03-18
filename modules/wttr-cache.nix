# modules/home/wttr-cache.nix
#
# home-manager module: wttr.in weather text cache for hyprlock
#
# Usage:
#   imports = [ ./modules/home/wttr-cache.nix ];
#   services.wttr-cache.enable = true;
#
# hyprlock.conf:
#   label {
#     text = cmd[update:0] cat /home/YOU/.cache/wttr/weather.txt
#     ...
#   }
#
# Script is available in PATH as: wttr-cache-update
# Debug log: ~/.cache/wttr/weather.log

{ config, lib, pkgs, ... }:

let
  cfg = config.services.wttr-cache;

  # Nix-time: build the format parameter string
  # If cfg.format is e.g. "3" → "format=3"
  # If cfg.format is a %-string e.g. "%l:+%c+%t" → "format=%l:+%c+%t"
  formatParam = "format=${cfg.format}";

  updateScript = pkgs.writeShellScriptBin "wttr-cache-update" ''
    set -euo pipefail

    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/wttr"
    WEATHER_FILE="$CACHE_DIR/weather.txt"
    LOCATION_FILE="$CACHE_DIR/location.txt"
    LOG_FILE="$CACHE_DIR/weather.log"
    TIMEOUT="${toString cfg.timeoutSeconds}"
    VERBOSE="${if cfg.verbose then "1" else "0"}"

    mkdir -p "$CACHE_DIR"

    log() {
      echo "[$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
      # Rotate log above 100 KB
      local size
      size=$(${pkgs.coreutils}/bin/stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
      if [ "$size" -gt 102400 ]; then
        ${pkgs.coreutils}/bin/tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp"
        ${pkgs.coreutils}/bin/mv "$LOG_FILE.tmp" "$LOG_FILE"
      fi
    }

    vlog() {
      [ "$VERBOSE" = "1" ] && log "DEBUG: $*" || true
    }

    fetch() {
      local url="$1"
      vlog "curl → $url"
      ${pkgs.curl}/bin/curl -sf --max-time "$TIMEOUT" "$url"
    }

    detect_and_save_location() {
      vlog "Detecting location via wttr.in?format=%l"
      local detected
      detected=$(fetch "https://wttr.in?format=%l" || true)
      vlog "Location response: '$detected'"
      if [ -n "$detected" ]; then
        echo "$detected" > "$LOCATION_FILE"
        log "Saved location: $detected"
      fi
    }

    # --- Attempt 1: auto-detect via IP ---
    vlog "Attempt 1: auto-detect"
    RESULT=$(fetch "https://wttr.in?${formatParam}" || true)
    vlog "Auto result: '$RESULT'"

    if [ -n "''${RESULT}" ]; then
      echo "$RESULT" > "$WEATHER_FILE"
      log "OK (auto): $RESULT"
      detect_and_save_location &
      exit 0
    fi

    log "Auto-detect failed, trying saved location..."

    # --- Attempt 2: saved location ---
    SAVED_LOC=""
    if [ -f "$LOCATION_FILE" ]; then
      SAVED_LOC=$(${pkgs.coreutils}/bin/cat "$LOCATION_FILE")
      vlog "Loaded saved location: '$SAVED_LOC'"
    else
      vlog "No location file found at $LOCATION_FILE"
    fi

    if [ -n "''${SAVED_LOC}" ]; then
      ENCODED_LOC=$(${pkgs.python3}/bin/python3 -c \
        "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" \
        "''${SAVED_LOC}")
      SAVED_URL="https://wttr.in/''${ENCODED_LOC}?${formatParam}"
      vlog "Attempt 2: $SAVED_URL"
      RESULT=$(fetch "''${SAVED_URL}" || true)
      vlog "Saved-location result: '$RESULT'"

      if [ -n "''${RESULT}" ]; then
        echo "$RESULT" > "$WEATHER_FILE"
        log "OK (saved: ''${SAVED_LOC}): $RESULT"
        exit 0
      fi
    fi

    # --- Attempt 3: keep cache untouched ---
    log "FAIL — network unavailable, cache unchanged"
    exit 0
  '';

in {
  options.services.wttr-cache = {
    enable = lib.mkEnableOption "wttr.in weather text cache for hyprlock";

    format = lib.mkOption {
      type    = lib.types.str;
      default = "4";
      description = ''
        wttr.in format string. Preset numbers or custom %-notation:
          "1"              — icon + temp
          "2"              — icon + temp + wind
          "3"              — city + icon + temp  (default)
          "4"              — city + icon + temp + wind
          "%l:+%c+%t+%h"  — custom: city, icon, temp, humidity
        See https://wttr.in/:help for all % tokens.
      '';
    };

    interval = lib.mkOption {
      type    = lib.types.str;
      default = "30min";
      description = "How often to refresh. Systemd time span, e.g. \"15min\", \"1h\".";
    };

    timeoutSeconds = lib.mkOption {
      type    = lib.types.int;
      default = 10;
      description = "curl timeout in seconds per fetch attempt.";
    };

    resumeDelay = lib.mkOption {
      type    = lib.types.str;
      default = "20s";
      description = "Wait time after suspend resume before fetching.";
    };

    verbose = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = "Write DEBUG lines to the log file for troubleshooting.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Make wttr-cache-update available in PATH
    home.packages = [ updateScript ];

    systemd.user.services.wttr-cache = {
      Unit = {
        Description = "Update wttr.in weather text cache";
        After       = [ "network-online.target" ];
        Wants       = [ "network-online.target" ];
      };
      Service = {
        Type      = "oneshot";
        ExecStart = "${updateScript}/bin/wttr-cache-update";
      };
    };

    systemd.user.timers.wttr-cache = {
      Unit.Description = "Refresh wttr.in weather cache every ${cfg.interval}";
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
        ExecStart    = "${updateScript}/bin/wttr-cache-update";
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
