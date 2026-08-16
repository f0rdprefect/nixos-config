# Example: how to wire the three modules into ook's host config.
{ config, ... }:
{
  imports = [
    ../../modules/ntfy.nix # shared notification target
    ../../modules/backup-suite.nix # replication + rsync, no disk health
    ../../modules/netdata-monitoring.nix # SMART + zpool health, via netdata
  ];

  #sops.secrets.ntfy-token = {
  #sopsFile = ../../secrets/secrets.yaml;
  #owner = "root";
  #};

  # Configured once, used by both backup-suite and netdata-monitoring.
  services.ntfyNotify = {
    url = "https://ntfy.berse.xyz";
    topic = "ook-alerts";
    tokenFile = "";
    # tokenFile = config.sops.secrets.ntfy-token.path;
    # anonymous topic on your LAN/VPN? leave tokenFile = ""; and drop the
    # sops secret above entirely.
  };

  services.backupSuite = {
    enable = true;
    backupPool.name = "backup-pool";

    zfsReplication.jobs = [
      {
        name = "immich";
        source = "ultrastic/immich";
        target = "backup-pool/selfhost/immich";
        # stop -> snapshot -> restart, so the snapshot is
        # application-consistent instead of merely crash-consistent.
        # app-level services first (stop new writes), postgres last
        # (clean checkpoint); restarts in reverse.
        quiesceServices = [
          "immich-server.service"
          "immich-machine-learning.service"
          "postgresql.service"
        ];
      }
      # more zfs-native sources later, same shape -- quiesceServices is
      # optional, leave it [] for datasets that don't need app-consistency
    ];

    nonZfsBackup.jobs = [
      {
        name = "music";
        source = "/srv/rincewind/music";
        targetDataset = "backup-pool/selfhost/rsync-music";
        excludes = [
          ".git"
          "result"
        ];
      }
      # add non-zfs paths here, one line each:
      # { name = "grafana"; source = "/var/lib/grafana"; }
    ];

    snapshotRetention = {
      daily = 14;
      weekly = 8;
      monthly = 6;
    };
  };

  services.diskMonitoring.enable = true;
}
