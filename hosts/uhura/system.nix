{
  inputs,
  config,
  pkgs,
  username,
  host,
  lib,
  ...
}:

let
  inherit (import ./options.nix)
    theLocale
    theTime:zone
    gitUsername
    theShell
    wallpaperDir
    wallpaperGit
    theLCVariables
    theKBDLayout
    flakeDir
    theme
    ;
in
{
  imports = [
    ./hardware.nix
    ./backup.nix
    ../../config/system
    ../../users/users.nix
  ];

  # Enable networking
  networking.hostName = "${host}"; # Define your hostname
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "${theTimezone}";

  # Select internationalisation properties
  i18n.defaultLocale = "${theLocale}";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${theLCVariables}";
    LC_IDENTIFICATION = "${theLCVariables}";
    LC_MEASUREMENT = "${theLCVariables}";
    LC_MONETARY = "${theLCVariables}";
    LC_NAME = "${theLCVariables}";
    LC_NUMERIC = "${theLCVariables}";
    LC_PAPER = "${theLCVariables}";
    LC_TELEPHONE = "${theLCVariables}";
    LC_TIME = "${theLCVariables}";
  };

  console.keyMap = "${theKBDLayout}";

  # Define a user account.
  users = {
    mutableUsers = true;
  };

  environment.variables = {
    FLAKE = "${flakeDir}";
    ZANEYOS_VERSION = "1.0";
    POLKIT_BIN = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    #EDITOR = "nvim";
  };

  # Optimization settings and garbage collection automation
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
  # https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
  system.stateVersion = "24.11";
}
