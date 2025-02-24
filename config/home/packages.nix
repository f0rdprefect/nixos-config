{
  pkgs,
  username,
  host,
  ...
}:

let
  inherit (import ../../hosts/${host}/options.nix)
    browser
    wallpaperDir
    wallpaperGit
    flakeDir
    ;
in
{
  # Install Packages For The User
  home.packages = with pkgs; [
    calibre
    super-slicer
    orca-slicer
    #####system maintenance stuff
    gparted
    usbutils
    sops
    rustic
    caligula
    #####shell stuff####
    #fzf
    fd
    nix-search-cli
    nixfmt-rfc-style
    #####python stuff#####
    poetry
    uv
    ####Office#######
    evince
    gimp
    inkscape
    libreoffice
    logseq
    mupdf
    nomacs
    okular
    pandoc
    texliveFull
    typst
    code-cursor
    ####Media Ripping###
    asunder
    handbrake
    lame
    yt-dlp
    vlc
    ffmpeg-full
    ####File sharing###
    nextcloud-client
    localsend
    git-annex
    ####Communication####
    signal-desktop
    zapzap
    fractal
    paper-plane
    wl-mirror
    ####bitwarden related###
    bitwarden # will be replaced by bitwarden-desktop
    rofi-rbw
    rbw
    pinentry-rofi
    pinentry-gnome3
    dotool
    cliphist
    #######
    cosmic-files
    pkgs."${browser}"
    libvirt
    swww
    grim
    slurp
    file-roller
    swaynotificationcenter
    rofi-wayland
    imv
    mpv
    gimp
    rustup
    audacity
    pavucontrol
    tree
    nix-tree
    protonup-qt
    glib
    spotify
    swayidle
    swaylock-effects
    #fonts
    nerd-fonts.jetbrains-mono
    fantasque-sans-mono
    font-awesome
    roboto
    source-sans-pro
    # Import Scripts
    (import ./../scripts/emopicker9000.nix { inherit pkgs; })
    (import ./../scripts/task-waybar.nix { inherit pkgs; })
    (import ./../scripts/squirtle.nix { inherit pkgs; })
    (import ./../scripts/wallsetter.nix {
      inherit pkgs;
      inherit wallpaperDir;
      inherit username;
      inherit wallpaperGit;
    })
    (import ./../scripts/themechange.nix {
      inherit pkgs;
      inherit flakeDir;
      inherit host;
    })
    (import ./../scripts/theme-selector.nix { inherit pkgs; })
    (import ./../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ./../scripts/web-search.nix { inherit pkgs; })
    (import ./../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./../scripts/screenshootin.nix { inherit pkgs; })
    (import ./../scripts/togglekbd.nix { inherit pkgs; })
  ];

  fonts.fontconfig.enable = true;

  programs.direnv.enable = true;
  programs.gh.enable = true;
}
