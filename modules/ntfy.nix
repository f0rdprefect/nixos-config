# modules/ntfy.nix
#
# Shared ntfy notification helper. Import this into any module that needs
# to push a message to ntfy -- backup-suite.nix and netdata-monitoring.nix
# both use it, so the topic/url/token is configured in exactly one place.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ntfyNotify;
in
{
  options.services.ntfyNotify = {
    url = mkOption { type = types.str; description = "Base URL of your ntfy instance, no trailing slash."; };
    topic = mkOption { type = types.str; default = "ook-alerts"; description = "ntfy topic to publish to."; };
    tokenFile = mkOption {
      type = types.str;
      default = "";
      description = "Path to a file (e.g. a sops-nix secret) containing an ntfy access token. Empty = no auth header.";
    };

    package = mkOption {
      type = types.package;
      readOnly = true;
      description = "The generated ntfy-notify script, callable as <pkg>/bin/ntfy-notify <title> <message> [priority] [tags]";
    };
  };

  config = {
    assertions = [{ assertion = cfg.url != ""; message = "services.ntfyNotify.url must be set."; }];

    services.ntfyNotify.package = pkgs.writeShellApplication {
      name = "ntfy-notify";
      runtimeInputs = [ pkgs.curl ];
      text = ''
        title="''${1:?title required}"
        message="''${2:?message required}"
        priority="''${3:-default}"
        tags="''${4:-}"

        auth_args=()
        if [ -n "${cfg.tokenFile}" ] && [ -r "${cfg.tokenFile}" ]; then
          token="$(cat "${cfg.tokenFile}")"
          auth_args=(-H "Authorization: Bearer $token")
        fi

        tag_args=()
        if [ -n "$tags" ]; then
          tag_args=(-H "Tags: $tags")
        fi

        curl -fsS --max-time 15 \
          "''${auth_args[@]}" \
          -H "Title: $title" \
          -H "Priority: $priority" \
          "''${tag_args[@]}" \
          -d "$message" \
          "${cfg.url}/${cfg.topic}" \
          >/dev/null
      '';
    };

    environment.systemPackages = [ cfg.package ];

    # Generic OnFailure=-target unit, usable by ANY systemd service:
    #   onFailure = [ "notify-failure@%n.service" ];
    systemd.services."notify-failure@" = {
      description = "ntfy alert for failed unit %i";
      serviceConfig.Type = "oneshot";
      script = ''
        ${cfg.package}/bin/ntfy-notify \
          "job failed: %i" \
          "systemd unit %i failed on $(hostname). journalctl -u %i --since -1h for details." \
          high \
          "warning,x"
      '';
    };
  };
}
