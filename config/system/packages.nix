{ pkgs, config, inputs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow Insecure Packages
  nixpkgs.config.permittedInsecurePackages = [
     "electron-27.3.11"
     ];

  # List System Programs
  environment.systemPackages = with pkgs; [
    wget 
    jq
    curl 
    git 
    cmatrix 
    lolcat 
    neofetch 
    macchina 
    fastfetch
    htop 
    btop 
    libvirt
    polkit_gnome 
    lm_sensors 
    unzip 
    unrar 
    libnotify 
    eza
    v4l-utils 
    ydotool 
    wl-clipboard 
    socat 
    cowsay 
    lsd 
    lshw
    pkg-config 
    gnumake 
    noto-fonts-color-emoji 
    material-icons 
    brightnessctl
    virt-viewer 
    swappy 
    ripgrep 
    appimage-run 
    networkmanagerapplet 
    yad 
    playerctl 
    nh
    podman-compose
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    nano.enable = false;
    steam.gamescopeSession.enable = false;
    dconf.enable = true;
    seahorse.enable=true;
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
    };
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    virt-manager.enable = true;
  };

  virtualisation.libvirtd.enable = true;
}
