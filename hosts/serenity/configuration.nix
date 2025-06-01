# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "serenity"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtkdsMIF3pQw4oLv+7ShT3UtHexFxzx/mEz/cIAPXvTxhRK6UMYu7Ku7ioeFibnSPKxk9d095W192jbIPoriFLkpiHbDqmfJ3I/X6xPhkFxknxRFSHm5GCOzY9Q4Gt+ObpuJOGOsLtXcQ0Ug/icXVijAbfAyOGwgWljl1Nf8W4b7qBMpzQMbSwZqGV7JN7lvWafVh4vLAi/smPcd9fD7MC5oGo7rmRsYMGbvRN2h/W5g/UvRMd3bk24FPpd8scFoLrVJBXWV7KSIIrCCK084mGG2PhAkegX0doewyIjfnpAcbVge2X5ujB9z0UcSXXp1U/zwHAzD24WbAdoIogs76d matt@xenity"
    ];
    initialHashedPassword = "$6$wcCw6lVWoVCRuHY/$j79gSaJrk6/PZH/74FZSYdfExCrkL5pD1qSWDfBReTweKyUkhFKXZIN598tXc1666x12s5IlRoSO1I.E3m1eL1";

    packages = with pkgs; [
      helix
      neovim
    ];
  };
  users.users.root = {
    initialHashedPassword = "$6$Jpz0eIcFOo9ln0Ap$5AMBBL1kkBo3EkLeDHFvgquxngDiglTTZyFGEx8Cxw6AfClgSHZo7Hq4MnFRieRLQxYXEWg0YAGCU57NDEBgj/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtkdsMIF3pQw4oLv+7ShT3UtHexFxzx/mEz/cIAPXvTxhRK6UMYu7Ku7ioeFibnSPKxk9d095W192jbIPoriFLkpiHbDqmfJ3I/X6xPhkFxknxRFSHm5GCOzY9Q4Gt+ObpuJOGOsLtXcQ0Ug/icXVijAbfAyOGwgWljl1Nf8W4b7qBMpzQMbSwZqGV7JN7lvWafVh4vLAi/smPcd9fD7MC5oGo7rmRsYMGbvRN2h/W5g/UvRMd3bk24FPpd8scFoLrVJBXWV7KSIIrCCK084mGG2PhAkegX0doewyIjfnpAcbVge2X5ujB9z0UcSXXp1U/zwHAzD24WbAdoIogs76d matt@xenity"
    ];

  };
  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  virtualisation.docker.enable = true;
  nixpkgs.config.allowUnfree = true;
  # allow nix command
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
