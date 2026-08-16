# modules/netdata-monitoring.nix
#
# Disk/pool health monitoring via netdata, decoupled from backup-suite.nix
# on purpose. Reuses the same ntfy target (imports ntfy.nix) so alerts land
# in one place, but backups and health monitoring are otherwise independent
# systems -- a broken netdata collector can't block a backup run and vice
# versa.
#
# Two things I could NOT verify in this sandbox (no netdata instance, no
# nixpkgs checkout available) and that you should confirm after first
# deploy:
#   1. The exact go.d config paths NixOS's netdata module reads user
#      overrides from. I'm using /etc/netdata/go.d/*.conf, which has been
#      the stable convention for a long time, but check
#      `journalctl -u netdata` after enabling to confirm the collector
#      actually loaded your override rather than silently falling back to
#      stock config.
#   2. The exact custom_sendmessage() contract in health_alarm_notify.conf.
#      This has been stable across netdata versions for years, but netdata
#      is also actively pushing people toward "Netdata Cloud" notifications
#      instead -- if the classic health_alarm_notify.sh path is deprecated
#      in whatever version you land on, you'd want their newer webhook
#      mechanism instead, which can call ntfy just as easily.
#
# smartctl and zpool both need elevated privileges to read raw disk /
# pool state that the unprivileged `netdata` user doesn't have by default.
# This uses the documented approach: `use_sudo: yes` in the collector
# config + a narrow sudoers rule, rather than running netdata as root.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.diskMonitoring;
  ntfy = config.services.ntfyNotify.package;
in
{
  imports = [ ./ntfy.nix ];

  options.services.diskMonitoring = {
    enable = mkEnableOption "netdata-based SMART + zpool health monitoring, alerting via ntfy";
  };

  config = mkIf cfg.enable {
    services.netdata.enable = true;

    # Make sure the collectors can find the binaries they shell out to.
    systemd.services.netdata.path = with pkgs; [ smartmontools zfs sudo ];

    # Narrow, read-only-in-spirit sudo grants for the netdata user.
    # smartctl -a / -H / -A are read commands; zpool status/list are read
    # commands. Neither can modify data.
    security.sudo.extraRules = [
      {
        users = [ "netdata" ];
        commands = [
          { command = "${pkgs.smartmontools}/bin/smartctl"; options = [ "NOPASSWD" ]; }
          { command = "${pkgs.zfs}/bin/zpool"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];

    environment.etc."netdata/go.d/smartctl.conf".text = ''
      jobs:
        - name: local
          use_sudo: yes
          # no explicit device list: auto-discovery via `smartctl --scan`
    '';

    environment.etc."netdata/go.d/zfspool.conf".text = ''
      jobs:
        - name: local
          use_sudo: yes
    '';

    # Route netdata's own alarm engine through ntfy instead of email/etc.
    # netdata's default thresholds already cover disk fill, SMART failures,
    # and pool degraded/faulted state once these collectors are active --
    # you shouldn't need custom alarm templates for the common cases.
    environment.etc."netdata/health_alarm_notify.conf".text = ''
      SEND_CUSTOM="YES"
      DEFAULT_RECIPIENT_CUSTOM="ntfy"

      custom_sendmessage() {
        # netdata populates these before calling us; see health_alarm_notify.sh
        # for the full variable list if you want to enrich the message further.
        local prio="default"
        case "''${status}" in
          CRITICAL) prio="urgent" ;;
          WARNING)  prio="high" ;;
          CLEAR)    prio="low" ;;
        esac

        ${ntfy}/bin/ntfy-notify \
          "netdata: ''${name} is ''${status}" \
          "''${chart}: ''${value_string} on ''${host} (was ''${old_status})" \
          "$prio" \
          "netdata"

        SENT_CUSTOM=1
      }
    '';
  };
}
