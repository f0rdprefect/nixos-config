{ lib, pkgs, ... }:
{
  # Immich service
  services.immich = {
    enable = true;
    host = "0.0.0.0"; # Listen on all interfaces
    port = 2283;

    # Media storage location
    mediaLocation = "/srv/twoflower/immich/library";

    # Database configuration
    database = {
      enable = true;
      createDB = true;
      # PostgreSQL will use /var/lib/postgresql by default
      # We'll override this below to use our ZFS dataset
    };

    # Machine learning for face recognition, object detection
    machine-learning = {
      enable = true;
    };

    # Environment variables
    environment = {
      IMMICH_MEDIA_LOCATION = "/srv/twoflower/immich/library";
      UPLOAD_LOCATION = "/srv/twoflower/immich/uploads";
    };
  };

  # Override PostgreSQL data directory to use ZFS
  services.postgresql = {
    dataDir = "/srv/twoflower/immich/database";
  };

  # Ensure proper permissions on ZFS datasets
  systemd.tmpfiles.rules = [
    # Library - owned by immich user
    "d /srv/twoflower/immich/library 0750 immich immich -"

    # Uploads - owned by immich user
    "d /srv/twoflower/immich/uploads 0750 immich immich -"

    # Database - owned by postgres user
    "d /srv/twoflower/immich/database 0750 postgres postgres -"
  ];

  # Make services wait for ZFS mounts
  systemd.services.immich-server = {
    unitConfig = {
      RequiresMountsFor = [
        "/srv/twoflower/immich/library"
        "/srv/twoflower/immich/uploads"
        "/srv/twoflower/immich/database"
      ];
    };
  };

  systemd.services.immich-machine-learning = {
    unitConfig = {
      RequiresMountsFor = [ "/srv/twoflower/immich/library" ];
    };
  };

  systemd.services.postgresql = {
    unitConfig = {
      RequiresMountsFor = [ "/srv/twoflower/immich/database" ];
    };
  };

  # Optional: Enable hardware acceleration for Intel N100
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD
      intel-vaapi-driver # i965 (older)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Add immich user to video group for hardware acceleration
  users.users.immich = {
    extraGroups = [
      "video"
      "render"
    ];
  };

  # Optional: Firewall rules
  networking.firewall = {
    allowedTCPPorts = [ 2283 ];
  };
}
