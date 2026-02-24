{
  modulesPath,
  lib,
  pkgs,
  cfgoptions,
  inputs,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/disko/zfs-single.nix
    ../../config/system
  ];
  boot = {
    kernelParams = [
      "quiet"
      "splash"
      #      "intremap=on"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
    ];
    extraModulePackages = [ ];
    initrd.systemd.enable = true;
    initrd.verbose = false;
    initrd.kernelModules = [ "virtio_gpu" ]; # amdgpu auf dem echten eisen
    consoleLogLevel = 0;
    plymouth.enable = true;
    plymouth.font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
    plymouth.logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";

    loader = {
      grub = {
        # no need to set devices, disko will add all devices that have a EF02 partition to the list already
        # devices = [ ];
        efiSupport = true;
        efiInstallAsRemovable = true;
        zfsSupport = true;
        extraConfig = ''
          set gfxmode=auto
          set gfxplayload=keep
        '';
      };

      efi.canTouchEfiVariables = false;
      systemd-boot.enable = false;
    };
    supportedFilesystems = [
      "bcachefs"
      "zfs"
    ];
    zfs = {
      devNodes = "/dev/disk/by-partlabel";
      package = pkgs.zfs_unstable;
      requestEncryptionCredentials = true;
    };
    kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;
    kernel.sysctl."vm.swappiness" = 10;
  };
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
    priority = 100;
  };
  services.openssh.enable = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.fastfetch
    pkgs.bcachefs-tools
    pkgs.btrfs-progs
    pkgs.tmux
    pkgs.pv
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
    hostName = cfgoptions.host; # Define your hostname
    networkmanager.enable = true;
    firewall.enable = true;
    #hostId = builtins.substring 0 8 (builtins.hashString "md5" "nook");
    hostId = "4e98920d";
  };
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly"; # or "weekly" if you prefer
    };
  };
  services.tailscale = {
    enable = true;
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
