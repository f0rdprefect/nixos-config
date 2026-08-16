# modules/backup-suite.nix
#
# Backup suite for `ook`. Import this + ntfy.nix into the ook host config.
# Extend nonZfsBackup.jobs / zfsReplication.jobs over time -- nothing else
# needs to change when you add a new source.
#
# Disk/pool health monitoring lives in netdata-monitoring.nix now, not here
# -- this module is backup + notification only.
#
# Design notes (see zfs-immich-mountpoint-incident.md):
#   - backup-pool is auto-imported (closes the incident doc's #1 TODO).
#   - Every zfs receive is pinned with an explicit mountpoint, never
#     inheriting the sent stream's embedded mountpoint property.
#   - Non-ZFS sources are rsync'd into their own dataset per source, then
#     sanoid snapshots that dataset on the same retention policy.
#   - Snapshot creation on zfsReplication SOURCE datasets is owned entirely
#     by sanoid, not by us. This matters for two reasons:
#       1. sanoid names the snapshots itself (autosnap_*), so its own
#          retention/pruning recognizes and cleans them up. An earlier
#          version of this module took its own manually-named snapshots
#          (backup-<timestamp>), which sanoid correctly refused to touch
#          since they weren't its own -- they'd have accumulated forever
#          on the PRODUCTION pool.
#       2. `quiesceServices` on a job is now implemented via sanoid's
#          pre_snapshot_script / post_snapshot_script hooks: stop the
#          listed systemd units, let sanoid take the snapshot, restart
#          them. This is what makes the Immich postgres snapshot
#          application-consistent instead of merely crash-consistent
#          (root cause of Incident 1's WAL corruption). Downtime is just
#          the stop -> snapshot -> start window (seconds), since
#          `zfs snapshot` is metadata-only -- the actual `zfs send`/
#          syncoid run happens afterward against the frozen snapshot,
#          services already back up.
#   - syncoid always runs with --no-sync-snap: it must never create its
#     own ad hoc snapshot at send time (which would bypass the quiesce
#     entirely). It only ever sends whatever snapshot sanoid already made.
#   - The replication target dataset gets sanoid too, but in prune-only
#     mode (autosnap = no) -- the useful snapshots there are the ones that
#     arrive via `zfs receive`, already named by the source's sanoid; we
#     just want the same retention policy applied to them.
#   - Immich's own nightly pg_dump can stay in place alongside this as a
#     second, independent recovery path -- cheap insurance, not required.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.backupSuite;
  ntfy = config.services.ntfyNotify.package;

  mkNotifiedService = { name, description, script, extraServiceConfig ? { }, after ? [ "zfs-import.target" ] }: {
    "${name}" = {
      inherit description after;
      onFailure = [ "notify-failure@%n.service" ];
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "0"; # long zfs sends / rsyncs shouldn't get killed early
      } // extraServiceConfig;
      path = with pkgs; [ zfs sanoid rsync coreutils gawk gnugrep systemd ];
      script = ''
        set -eu -o pipefail
        ${script}
      '';
    };
  };

  mkTimer = { name, onCalendar }: {
    "${name}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = onCalendar;
        Persistent = true;
        RandomizedDelaySec = "5min";
      };
    };
  };

  zfsJobType = types.submodule {
    options = {
      name = mkOption { type = types.str; description = "Short identifier, e.g. \"immich\"."; };
      source = mkOption { type = types.str; description = "Source dataset, e.g. \"immich-pool/immich\"."; };
      target = mkOption { type = types.str; description = "Destination dataset, e.g. \"backup-pool/selfhost/immich\"."; };
      quiesceServices = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          systemd units to stop (via sanoid's pre_snapshot_script) before
          this dataset's snapshot is taken, and restart (via
          post_snapshot_script) right after, for an application-consistent
          (not just crash-consistent) snapshot. Stopped in list order,
          restarted in reverse order.
          Example for Immich: [ "immich-server.service" "immich-machine-learning.service" "postgresql.service" ]
          -- app-level services stop first (no more new writes), postgres
          stops last (clean checkpoint), then postgres starts first back up.
        '';
      };
    };
  };

  rsyncJobType = types.submodule {
    options = {
      name = mkOption { type = types.str; description = "Short identifier, e.g. \"etc-nixos\"."; };
      source = mkOption { type = types.path; description = "Absolute path to back up."; };
      excludes = mkOption { type = types.listOf types.str; default = [ ]; description = "rsync --exclude patterns."; };
      targetDataset = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Full target dataset for this job, overriding the
          nonZfsBackup.datasetPrefix + name convention. Leave null to use
          "<nonZfsBackup.datasetPrefix>/<name>" as before; set this when a
          job needs to live under a different prefix or pool entirely.
        '';
      };
    };
  };

  # One pre + one post script per job that has quiesceServices set. Baked
  # per-job (not shared/generic) because each job's unit list is different
  # and is known at eval time -- no need to parse SANOID_TARGET to figure
  # out which units to touch.
  mkQuiesceScripts = job: {
    pre = pkgs.writeShellApplication {
      name = "sanoid-pre-${job.name}";
      runtimeInputs = [ pkgs.systemd ];
      text = ''
        echo "quiesce(${job.name}): stopping ${concatStringsSep " " job.quiesceServices} before snapshotting $SANOID_TARGET"
        systemctl stop ${concatStringsSep " " job.quiesceServices}
      '';
    };
    post = pkgs.writeShellApplication {
      name = "sanoid-post-${job.name}";
      runtimeInputs = [ pkgs.systemd ];
      text = ''
        echo "quiesce(${job.name}): restarting ${concatStringsSep " " (reverseList job.quiesceServices)} after snapshotting $SANOID_TARGET (pre-script failure: ''${SANOID_PRE_FAILURE:-0})"
        systemctl start ${concatStringsSep " " (reverseList job.quiesceServices)}
      '';
    };
  };

in
{
  imports = [ ./ntfy.nix ];

  options.services.backupSuite = {
    enable = mkEnableOption "ook backup suite (zfs replication + non-zfs rsync, ntfy-notified)";

    backupPool = {
      name = mkOption { type = types.str; default = "backup-pool"; };
      autoImport = mkOption { type = types.bool; default = true; description = "Adds this pool to boot.zfs.extraPools."; };
    };

    zfsReplication = {
      enable = mkOption { type = types.bool; default = true; };
      onCalendar = mkOption {
        type = types.str;
        default = "*-*-* 03:00:00";
        description = "Must run AFTER backup-sanoid-prune's schedule, so a snapshot already exists to send.";
      };
      jobs = mkOption {
        type = types.listOf zfsJobType;
        default = [ ];
        example = [{
          name = "immich"; source = "immich-pool/immich"; target = "backup-pool/selfhost/immich";
          quiesceServices = [ "immich-server.service" "immich-machine-learning.service" "postgresql.service" ];
        }];
      };
    };

    nonZfsBackup = {
      enable = mkOption { type = types.bool; default = true; };
      onCalendar = mkOption { type = types.str; default = "*-*-* 02:30:00"; };
      datasetPrefix = mkOption { type = types.str; default = "backup-pool/selfhost/ook-files"; };
      jobs = mkOption { type = types.listOf rsyncJobType; default = [ ]; };
    };

    snapshotRetention = {
      hourly = mkOption { type = types.int; default = 0; };
      daily = mkOption { type = types.int; default = 14; };
      weekly = mkOption { type = types.int; default = 8; };
      monthly = mkOption { type = types.int; default = 6; };
    };

    quiesceScriptTimeout = mkOption {
      type = types.int;
      default = 60;
      description = ''
        sanoid's own default script_timeout is 5 seconds, too short for a
        clean postgresql stop under any real load. Applies to every
        pre/post snapshot script generated for quiesceServices jobs.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.zfs.extraPools = mkIf cfg.backupPool.autoImport [ cfg.backupPool.name ];
    environment.systemPackages = with pkgs; [ sanoid zfs rsync ];

    environment.etc."sanoid/sanoid.conf".text =
      let
        rsyncDataset = j: if j.targetDataset != null then j.targetDataset else "${cfg.nonZfsBackup.datasetPrefix}/${j.name}";

        # SOURCE side of each zfs replication job: this is where snapshots
        # actually get created, optionally quiesced.
        sourceSection = job: ''
          [${job.source}]
            use_template = ook_backup_source
        '' + optionalString (job.quiesceServices != [ ]) (
          let scripts = mkQuiesceScripts job; in ''
            pre_snapshot_script = ${scripts.pre}/bin/sanoid-pre-${job.name}
            post_snapshot_script = ${scripts.post}/bin/sanoid-post-${job.name}
            script_timeout = ${toString cfg.quiesceScriptTimeout}
            force_post_snapshot_script = yes
            no_inconsistent_snapshot = yes
          ''
        );

        # TARGET side: prune-only. Snapshots land here via `zfs receive`
        # (syncoid), already named by the source's sanoid -- we don't want
        # a second, independent autosnap happening on a receive target.
        targetSection = job: ''
          [${job.target}]
            use_template = ook_backup_target
        '';

        rsyncSection = ds: ''
          [${ds}]
            use_template = ook_backup_source
        '';
      in
      ''
        [template_ook_backup_source]
          hourly = ${toString cfg.snapshotRetention.hourly}
          daily = ${toString cfg.snapshotRetention.daily}
          weekly = ${toString cfg.snapshotRetention.weekly}
          monthly = ${toString cfg.snapshotRetention.monthly}
          autosnap = yes
          autoprune = yes

        [template_ook_backup_target]
          hourly = ${toString cfg.snapshotRetention.hourly}
          daily = ${toString cfg.snapshotRetention.daily}
          weekly = ${toString cfg.snapshotRetention.weekly}
          monthly = ${toString cfg.snapshotRetention.monthly}
          autosnap = no
          autoprune = yes

        ${concatStringsSep "\n" (map sourceSection cfg.zfsReplication.jobs)}
        ${concatStringsSep "\n" (map targetSection cfg.zfsReplication.jobs)}
        ${concatStringsSep "\n" (map (j: rsyncSection (rsyncDataset j)) cfg.nonZfsBackup.jobs)}
      '';

    systemd.services = mkMerge [
      (mkIf cfg.zfsReplication.enable
        (mkNotifiedService {
          name = "backup-zfs-replicate";
          description = "syncoid replication of sanoid-created snapshots to ${cfg.backupPool.name}";
          after = [ "zfs-import.target" "backup-sanoid-prune.service" ];
          script = ''
            ${concatMapStringsSep "\n" (job: ''
              echo "=== ${job.name}: replicating ${job.source} -> ${job.target} ==="
              ${pkgs.sanoid}/bin/syncoid \
                --no-privilege-elevation \
                --create-bookmark \
                --no-sync-snap \
                "${job.source}" "${job.target}"
            '') cfg.zfsReplication.jobs}
            ${ntfy}/bin/ntfy-notify \
              "zfs replication ok" \
              "Replicated: ${concatMapStringsSep ", " (j: j.name) cfg.zfsReplication.jobs}" \
              default
          '';
        })
      )

      (mkIf cfg.nonZfsBackup.enable
        (mkNotifiedService {
          name = "backup-nonzfs-rsync";
          description = "rsync non-zfs sources into their zfs datasets";
          script = ''
            ${concatMapStringsSep "\n" (job:
              let
                ds = if job.targetDataset != null then job.targetDataset else "${cfg.nonZfsBackup.datasetPrefix}/${job.name}";
                excludeArgs = concatMapStringsSep " " (e: "--exclude='${e}'") job.excludes;
              in ''
                echo "=== rsyncing ${job.source} -> ${ds} ==="
                zfs list -H -o name "${ds}" >/dev/null 2>&1 || \
                  zfs create -o mountpoint="/${ds}" -p "${ds}"
                # Dataset existing is not enough -- it could have
                # mountpoint=none/legacy or canmount=off, in which case
                # "/${ds}" is just a plain directory in the PARENT dataset
                # and rsync would silently write data into the wrong
                # place (same failure shape as the incident doc's
                # mountpoint collision). Refuse to proceed instead.
                if [ "$(zfs get -H -o value mounted "${ds}")" != "yes" ]; then
                  echo "ERROR: ${ds} exists but is not mounted at /${ds}; refusing to rsync into a path that isn't this dataset's mountpoint" >&2
                  exit 1
                fi
                rsync -aH --delete ${excludeArgs} "${job.source}/" "/${ds}/"
              '') cfg.nonZfsBackup.jobs}
            ${ntfy}/bin/ntfy-notify \
              "non-zfs backup ok" \
              "rsync'd: ${concatMapStringsSep ", " (j: j.name) cfg.nonZfsBackup.jobs}" \
              default
          '';
        })
      )

      (mkNotifiedService {
        name = "backup-sanoid-prune";
        description = "sanoid snapshot (incl. quiesce hooks) + prune per policy in /etc/sanoid/sanoid.conf";
        script = ''
          ${pkgs.sanoid}/bin/sanoid --cron --configdir=/etc/sanoid
        '';
      })
    ];

    systemd.timers = mkMerge [
      # backup-zfs-replicate declares an explicit After= on the prune
      # service for correct ordering if both ever fire close together
      # (e.g. manual runs); the calendar gap between the two is the
      # primary mechanism in normal scheduled operation.
      (mkIf cfg.zfsReplication.enable (mkTimer { name = "backup-zfs-replicate"; onCalendar = cfg.zfsReplication.onCalendar; }))
      (mkIf cfg.nonZfsBackup.enable (mkTimer { name = "backup-nonzfs-rsync"; onCalendar = cfg.nonZfsBackup.onCalendar; }))
      (mkTimer { name = "backup-sanoid-prune"; onCalendar = "*-*-* 01:00:00"; })
    ];
  };
}
