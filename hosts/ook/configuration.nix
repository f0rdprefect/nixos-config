{
  modulesPath,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/disko/btrfs-simple.nix
    ./immich.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.supportedFilesystems = [
    "bcachefs"
    "zfs"
  ];
  boot.zfs.extraPools = [ "immich-pool" ];
  boot.kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
    priority = 100;
  };
  boot.kernel.sysctl."vm.swappiness" = 10;
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.fastfetch
    pkgs.bcachefs-tools
    pkgs.btrfs-progs
  ];

  users.users.root = {
    openssh.authorizedKeys.keys = [
      # change this to your ssh key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIctR7J2PrwXqmEUSiDYh69/Dopy+1ZWPgih444JNEFc anywhere"
    ]
    ++ (args.extraPublicKeys or [ ]); # this is used for unit-testing this module and can be removed if not needed
    hashedPassword = "$y$j9T$nACs1O1c2vlQGIjLafidK0$.UlLcDIpm2d0yHaBDYdMlfRyx.BYFoaTledVKboN7H1";

  };
  users.users = {
    matt = {
      homeMode = "755";
      hashedPassword = "$y$j9T$nACs1O1c2vlQGIjLafidK0$.UlLcDIpm2d0yHaBDYdMlfRyx.BYFoaTledVKboN7H1";
      openssh.authorizedKeys.keys = [
        # change this to your ssh key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIctR7J2PrwXqmEUSiDYh69/Dopy+1ZWPgih444JNEFc anywhere"
      ];
      isNormalUser = true;
      description = "Matthias Berse";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "input"
        "cdrom"
      ];
      shell = pkgs.bash;
      ignoreShellProgramCheck = true;
      packages = with pkgs; [
        yazi
        neovim
      ];
    };
  };
  networking = {
    hostName = "ook"; # Define your hostname
    networkmanager.enable = true;
    firewall.enable = true;
    hostId = "ae4b736a";
  };
  services.bcachefs.autoScrub.enable = true;
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly"; # or "weekly" if you prefer
    };
  };
  services.tailscale = {
    enable = true;
  };

  fileSystems."/srv/rincewind" = {
    device = "/dev/disk/by-uuid/2631a330-d6eb-405d-acfb-403511ff363a";
    fsType = "bcachefs";
    options = [
      "defaults"
      "noatime"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/rincewind 0755 root root -"
  ];

  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/srv/rincewind/music";
      Address = "0.0.0.0"; # Listen on all interfaces for LAN access
      # The header that Pangolin sets with the username
      ExtAuth.UserHeader = "Remote-User"; # or whatever header Pangolin uses

      # Trust requests from Pangolin
      # If Pangolin is on the same machine:
      ExtAuth.TrustedSources = "nix";
    };
  };

  time.timeZone = "Europe/Berlin";

  nix = {
    settings = {
      trusted-users = [
        "root"
        "matt"
      ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"

      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

  };
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
