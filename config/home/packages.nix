{ pkgs, config, username, host, ... }:

let 
  inherit (import ../../hosts/${host}/options.nix) 
    browser wallpaperDir wallpaperGit flakeDir;
in {
  # Install Packages For The User
  home.packages = with pkgs; [
    calibre
    gparted
    #####shell stuff####
    #fzf
    fd
    #####python stuff#####
    poetry
    ####Office#######
    inkscape
    gimp
    nomacs
    libreoffice
    logseq
    evince
    okular
    mupdf
    pandoc
    texliveFull
    ####Media Ripping###
    asunder
    #handbrake
    lame
    ####File sharing###
    nextcloud-client
    localsend
    git-annex
    ####Communication####
    signal-desktop
    element-desktop-wayland
    fractal
    rambox
    ####bitwarden related###
    bitwarden # will be replaced by bitwarden-desktop
    rofi-rbw
    rbw
    pinentry-rofi
    pinentry-gnome3
    dotool
    cliphist
    #######
    pkgs."${browser}" 
    libvirt 
    swww 
    grim 
    slurp 
    gnome.file-roller
    swaynotificationcenter 
    rofi-wayland 
    imv 
    transmission-gtk 
    mpv
    gimp 
    rustup 
    audacity 
    pavucontrol 
    tree protonup-qt
    font-awesome 
    spotify 
    swayidle 
    neovide 
    swaylock-effects
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # Import Scripts
    (import ./../scripts/emopicker9000.nix { inherit pkgs; })
    (import ./../scripts/task-waybar.nix { inherit pkgs; })
    (import ./../scripts/squirtle.nix { inherit pkgs; })
    (import ./../scripts/wallsetter.nix { inherit pkgs; inherit wallpaperDir;
      inherit username; inherit wallpaperGit; })
    (import ./../scripts/themechange.nix { inherit pkgs; inherit flakeDir; inherit host; })
    (import ./../scripts/theme-selector.nix { inherit pkgs; })
    (import ./../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ./../scripts/web-search.nix { inherit pkgs; })
    (import ./../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./../scripts/screenshootin.nix { inherit pkgs; })
    (import ./../scripts/list-hypr-bindings.nix { inherit pkgs; inherit host; })
  ];

  programs.gh.enable = true;
}
