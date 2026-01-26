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
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.fastfetch
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
        firefox
      ];
    };
  };
  networking.hostName = "ook"; # Define your hostname
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  system.stateVersion = "26.05";
}
