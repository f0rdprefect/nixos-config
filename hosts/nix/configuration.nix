# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #../../config/system/homebox.nix
    ../../modules/unifi.nix
    ../../modules/audiobookshelf
    ../../modules/newt.nix

  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  # allow nix command
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  services.avahi = {
    enable = true;
  };
  services.openssh = {
    enable = true;
    #settings = {
    #   passwordAuthentication = false;
    #   kbdInteractiveAuthentication = false;
    #};
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    description = "matt";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDD9YL64de3Qw9yu7fZu4l0KI13UThZrfupLIvX6hz2yAAAABHNzaDo= black-solo
"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtkdsMIF3pQw4oLv+7ShT3UtHexFxzx/mEz/cIAPXvTxhRK6UMYu7Ku7ioeFibnSPKxk9d095W192jbIPoriFLkpiHbDqmfJ3I/X6xPhkFxknxRFSHm5GCOzY9Q4Gt+ObpuJOGOsLtXcQ0Ug/icXVijAbfAyOGwgWljl1Nf8W4b7qBMpzQMbSwZqGV7JN7lvWafVh4vLAi/smPcd9fD7MC5oGo7rmRsYMGbvRN2h/W5g/UvRMd3bk24FPpd8scFoLrVJBXWV7KSIIrCCK084mGG2PhAkegX0doewyIjfnpAcbVge2X5ujB9z0UcSXXp1U/zwHAzD24WbAdoIogs76d matt@xenity"
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDD9YL64de3Qw9yu7fZu4l0KI13UThZrfupLIvX6hz2yAAAABHNzaDo= black-solo
"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtkdsMIF3pQw4oLv+7ShT3UtHexFxzx/mEz/cIAPXvTxhRK6UMYu7Ku7ioeFibnSPKxk9d095W192jbIPoriFLkpiHbDqmfJ3I/X6xPhkFxknxRFSHm5GCOzY9Q4Gt+ObpuJOGOsLtXcQ0Ug/icXVijAbfAyOGwgWljl1Nf8W4b7qBMpzQMbSwZqGV7JN7lvWafVh4vLAi/smPcd9fD7MC5oGo7rmRsYMGbvRN2h/W5g/UvRMd3bk24FPpd8scFoLrVJBXWV7KSIIrCCK084mGG2PhAkegX0doewyIjfnpAcbVge2X5ujB9z0UcSXXp1U/zwHAzD24WbAdoIogs76d matt@xenity"
    ];
  };

  #enable qemu/kvm interactions
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Enable automatic login for the user.
  services.getty.autologinUser = "matt";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    tmux
    git
    git-annex
    btrfs-progs
    #  wget
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
    };

  };

  services.jellyfin = {
    package = pkgs.jellyfin;
    enable = true;
    group = "users";
    user = "matt";
    openFirewall = true;
    #    dataDir   = /srv/MQ03UBB300/config/jellyfin/data;
    #    configDir = /srv/MQ03UBB300/config/jellyfin/config;
    #    cacheDir  = /srv/MQ03UBB300/config/jellyfin/cache;
    #    logDir    = /srv/MQ03UBB300/config/jellyfin/log;

  };

  services.paperless = {
    enable = false;
    package = pkgs.paperless-ngx;
    consumptionDirIsPublic = true;
    dataDir = "/srv/MQ03UBB300/tank/paperless-nix";
    #address = "paperless.example.com";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
      };
    };
  };
  services.tailscale = {
    enable = true;
  };

  # ...

  # Samba
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "ak121";
        "server string" = "nix";
        "netbios name" = "nix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.178. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/srv/MQ03UBB300/tank/paperless/consume";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "matt";
        "force group" = "users";
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 6052 ];
  networking.firewall.allowedUDPPorts = [ 6052 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
