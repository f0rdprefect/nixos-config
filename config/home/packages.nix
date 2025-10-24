{
  pkgs,
  pkgs-stable,
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
  home.packages =
    (with pkgs-stable; [
      calibre
      nextcloud-client

    ])
    ++ (with pkgs; [
      mcpelauncher-ui-qt
      super-slicer
      orca-slicer
      #####system maintenance stuff
      gparted
      usbutils
      sops
      rustic
      caligula
      #####shell stuff####
      fd
      nix-search-cli
      nixfmt-rfc-style
      #####python stuff#####
      uv
      ####Office#######
      papers
      gimp
      inkscape
      libreoffice
      mupdf
      nomacs
      kdePackages.okular
      pandoc
      texliveFull
      typst
      xournalpp
      sleek-todo
      opencode
      ####Media Ripping###
      asunder
      handbrake
      makemkv
      lame
      yt-dlp
      vlc
      ffmpeg-full
      ####File sharing###
      localsend
      git-annex
      ####Communication####
      signal-desktop
      zapzap
      fractal
      materialgram

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
      pkgs."${browser}"
      libvirt
      swww
      grim
      slurp
      file-roller
      swaynotificationcenter
      rofi
      imv
      mpv
      gimp
      #  audacity
      pavucontrol
      tree
      nix-tree
      protonup-qt
      glib
      spotify
      sysz
      navi
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
    ]);

  fonts.fontconfig.enable = true;

  programs.direnv.enable = true;
}
