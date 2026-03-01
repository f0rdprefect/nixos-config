# vdb.nix – Home Manager module for vdb sqlite viewer
# Drop into your HM config and add: imports = [ ./vdb.nix ];
# Then enable with: programs.raith.vdb.enable = true;
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.raith.vdb;

  # Map terminal package names to their exec-flag.
  # Override with terminalExecFlag if your terminal isn't listed here
  # or if you need non-default behaviour (e.g. kitty --hold).
  knownTerminalFlags = {
    "alacritty"      = "-e";
    "foot"           = "-e";
    "kitty"          = "-e";
    "cool-retro-term" = "-e";
    "yakuake"        = "--hold -e";
    "wezterm"        = "start --";
    "ghostty"        = "-e";
    "warp-terminal"  = ""; # not supported, will fail gracefully
  };

  # Derive the exec flag: explicit override wins, then lookup table, then "-e" as sane default
  resolvedExecFlag =
    if cfg.terminalExecFlag != null
    then cfg.terminalExecFlag
    else knownTerminalFlags.${cfg.terminalBin} or "-e";

  # ---------------------------------------------------------------------------
  # Validation helpers embedded in the scripts
  # ---------------------------------------------------------------------------
  validateDb = ''
    validate_db() {
      local db="$1"

      if [[ -z "$db" ]]; then
        echo "error: no database path provided." >&2
        echo "usage: $(basename "$0") <file.db>" >&2
        exit 1
      fi

      if [[ ! -f "$db" ]]; then
        echo "error: file not found: $db" >&2
        exit 1
      fi

      # Check SQLite magic bytes (first 16 bytes spell "SQLite format 3")
      local magic
      magic=$(head -c 16 "$db" 2>/dev/null)
      if [[ "$magic" != "SQLite format 3"* ]]; then
        echo "error: '$db' does not appear to be a valid SQLite database." >&2
        exit 1
      fi

      # Check that the expected table exists
      if ! ${pkgs.sqlite}/bin/sqlite3 "$db" \
          "select 1 from sqlite_master where type='table' and name='vdb_data';" \
          2>/dev/null | grep -q 1; then
        echo "error: '$db' does not contain the required 'vdb_data' table." >&2
        echo "       Make sure this is a raith_app-compatible database." >&2
        exit 1
      fi
    }
  '';

  # ---------------------------------------------------------------------------
  # vdb-topic – dump all key=value pairs for a given topic to stdout + clipboard
  # Called by vdb/vdbg after topic selection.
  # Column order assumed: topic | item | value | modified (adjust cut fields if needed)
  # ---------------------------------------------------------------------------
  vdb-topic-script = pkgs.writeShellScriptBin "vdb-topic" ''
    set -euo pipefail

    if [[ -z "''${1:-}" || -z "''${2:-}" ]]; then
      echo "error: usage: vdb-topic <file.db> <topic>" >&2
      exit 1
    fi

    db="$1"
    topic="$2"

    if [[ ! -f "$db" ]]; then
      echo "error: file not found: $db" >&2
      exit 1
    fi

    # Query all usr=0 rows for this topic, ordered by item
    # Columns assumed: topic(1) | item(2) | value(3) | modified(4)
    rows=$(
      ${pkgs.sqlite}/bin/sqlite3 "$db" \
        "select item, value from vdb_data
         where usr = 0 and topic = '$topic'
         order by item asc;"
    )

    if [[ -z "$rows" ]]; then
      echo "error: no entries found for topic '$topic'" >&2
      exit 1
    fi

    # Output key=value lines only – header [topic] is prepended by the caller.
    # Strip null bytes that sqlite occasionally emits into command substitution.
    output=""
    while IFS='|' read -r key value; do
      output+="''${key}=''${value}"$'\n'
    done <<< "$(printf '%s' "$rows" | tr -d '\\000')"

    printf '%s' "$output"
  '';

  # ---------------------------------------------------------------------------
  # vdb – fzf variant, runs inline in the calling terminal
  # ---------------------------------------------------------------------------
  vdb-script = pkgs.writeShellScriptBin "vdb" ''
    set -euo pipefail

    ${validateDb}
    validate_db "''${1:-}"

    db="$1"

    result=$(
      ${pkgs.sqlite}/bin/sqlite3 "$db" \
        "select * from vdb_data where usr = 0 order by topic asc, item asc, modified desc;" \
      | ${pkgs.fzf}/bin/fzf
    )

    if [[ -z "$result" ]]; then
      echo "info: no entry selected." >&2
      exit 0
    fi

    topic="''${result%%|*}"
    content=$(vdb-topic "$db" "$topic")
    output=$(printf '[%s]\n%s' "$topic" "$content")

    # Wayland clipboard via wl-clipboard
    printf '%s' "$output" | ${pkgs.wl-clipboard}/bin/wl-copy
    printf '%s\n' "$output"
  '';

  # ---------------------------------------------------------------------------
  # vdbt – opens vdb in a new terminal window (fzf results visible there)
  # ---------------------------------------------------------------------------
  vdbt-script = pkgs.writeShellScriptBin "vdbt" ''
    set -euo pipefail

    ${validateDb}
    validate_db "''${1:-}"

    # kitty: override close_on_child_death in case user config sets it to no
    # other terminals: the exec flag + vdb exit is sufficient
    case "${cfg.terminalBin}" in
      kitty)
        exec ${cfg.terminal}/bin/${cfg.terminalBin} \
          --override close_on_child_death=yes \
          ${resolvedExecFlag} vdb "$@"
        ;;
      *)
        exec ${cfg.terminal}/bin/${cfg.terminalBin} ${resolvedExecFlag} vdb "$@"
        ;;
    esac
  '';

  # ---------------------------------------------------------------------------
  # vdbg – rofi/dmenu variant (GUI picker, no extra terminal needed)
  # ---------------------------------------------------------------------------
  vdbg-script = pkgs.writeShellScriptBin "vdbg" ''
    set -euo pipefail

    ${validateDb}
    validate_db "''${1:-}"

    db="$1"

    result=$(
      ${pkgs.sqlite}/bin/sqlite3 "$db" \
        "select * from vdb_data where usr = 0 order by topic asc, item asc, modified desc;" \
      | ${pkgs.rofi}/bin/rofi -dmenu -i -multi-select -p "vdb"
    )

    if [[ -z "$result" ]]; then
      echo "info: no entry selected." >&2
      exit 0
    fi

    topic="''${result%%|*}"
    content=$(vdb-topic "$db" "$topic")
    output=$(printf '[%s]\n%s' "$topic" "$content")

    printf '%s' "$output" | ${pkgs.wl-clipboard}/bin/wl-copy
    printf '%s\n' "$output"
  '';

in
{
  # ---------------------------------------------------------------------------
  # Options
  # ---------------------------------------------------------------------------
  options.programs.raith.vdb = {
    enable = mkEnableOption "vdb sqlite viewer (raith_app.db)";

    terminal = mkOption {
      type = types.package;
      default = pkgs.kitty;
      defaultText = literalExpression "pkgs.kitty";
      description = ''
        Terminal emulator package used by the <command>vdbt</command> wrapper.
        The package must be available in nixpkgs.
        Known terminals with auto-detected exec flags: alacritty, foot, kitty,
        cool-retro-term, yakuake, wezterm, ghostty.
      '';
    };

    terminalBin = mkOption {
      type = types.str;
      default = cfg.terminal.meta.mainProgram or (lib.getName cfg.terminal);
      defaultText = literalExpression ''terminal.meta.mainProgram or (lib.getName terminal)'';
      description = ''
        Name of the terminal binary inside the package's bin/ directory.
        Derived automatically from the package's meta.mainProgram (or package name
        as fallback). Only override this if the binary name genuinely differs.
      '';
    };

    terminalExecFlag = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "--hold -e";
      description = ''
        Flag(s) passed to the terminal to execute a command, e.g. "-e" or "start --".
        When null (the default) the module auto-detects the flag based on terminalBin.
        Set explicitly to override the auto-detection.
      '';
    };

    registerMimeType = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Register application/vnd.sqlite3 and application/x-sqlite3 MIME types
        so that .db files open with vdbg (rofi variant) by default.
        Requires xdg.enable = true in your Home Manager config.
      '';
    };

    useRofi = mkOption {
      type = types.bool;
      default = true;
      description = "Install the vdbg rofi/dmenu variant. Requires rofi in your config.";
    };
  };

  # ---------------------------------------------------------------------------
  # Config
  # ---------------------------------------------------------------------------
  config = mkIf cfg.enable {

    home.packages = flatten [
      vdb-topic-script
      vdb-script
      vdbt-script
      pkgs.fzf
      pkgs.sqlite
      pkgs.wl-clipboard
      cfg.terminal
      (optional cfg.useRofi vdbg-script)
      (optional cfg.useRofi pkgs.rofi)
    ];

    # MIME type registration – replaces handlr.
    # Uses vdbg (rofi) if useRofi = true, otherwise falls back to vdbt (terminal + fzf).
    xdg.mimeApps = mkIf cfg.registerMimeType {
      enable = true;
      defaultApplications =
        let handler = if cfg.useRofi then "vdbg.desktop" else "vdbt.desktop";
        in {
          "application/vnd.sqlite3" = [ handler ];
          "application/x-sqlite3"   = [ handler ];
        };
    };

    xdg.desktopEntries = mkIf cfg.registerMimeType (
      {
        vdbt = {
          name = "VDB Viewer (terminal)";
          comment = "Browse and copy entries from a raith_app SQLite database (fzf)";
          exec = "vdbt %f";
          terminal = false;
          mimeType = [ "application/vnd.sqlite3" "application/x-sqlite3" ];
          categories = [ "Utility" ];
        };
      } // optionalAttrs cfg.useRofi {
        vdbg = {
          name = "VDB Viewer (rofi)";
          comment = "Browse and copy entries from a raith_app SQLite database (rofi)";
          exec = "vdbg %f";
          terminal = false;
          mimeType = [ "application/vnd.sqlite3" "application/x-sqlite3" ];
          categories = [ "Utility" ];
        };
      }
    );
  };
}
