{
  pkgs,
  pkgs-stable,
  inputs,
  host,
  username,
  lib,
  ...
}:

let
  inherit (import ../../hosts/${host}/options.nix)
    gitUsername
    gitEmail
    theme
    wallpaperDir
    wallpaperGit
    flakeDir # refactor me away
    ;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  #targets.genericLinux.enable = true;
  imports = [

    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-colors.homeManagerModules.default
    ../../config/home/bash.nix
    ../../config/home/espanso
    ../../config/home/fzf.nix
    #../../config/home/gtk-qt.nix
    ../../config/home/git.nix
    ../../config/home/hyprland
    ../../config/home/kitty.nix
    ../../config/home/neovim
    ../../config/home/rofi.nix
    ../../config/home/starship.nix
    ../../config/home/waybar.nix
    ../../config/home/wlogout.nix
    ../../config/home/swappy.nix
    ../../config/home/swaylock.nix
    ../../config/home/swaync.nix
    ../../config/home/stylix.nix
    #../../config/home/vlc.nix did not work but make rebuild slow as hell
    ../../config/home/xdg # XDG configuration (portal, mime apps)
    ../../config/home/yazi.nix
    ../../config/home/zsh.nix

    #Place Home Files Like Pictures
    ../../config/home/files.nix

  ];
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  colorScheme = inputs.nix-colors.colorSchemes."${theme}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    (with pkgs; [
      nextcloud-client
      gparted-full
      sops
      rustic
      caligula
      fd
      papers
      libreoffice
      mupdf

      kitty
      brave
      chromium
      firefox
      libreoffice
      opencode
      logseq
      sleek-todo
      fzf
      gimp
      git
      git-credential-oauth
      hamster
      kdePackages.falkon
      nixfmt
      nomacs
      pandoc
      pokeget-rs
      quickemu
      signal-desktop
      texliveBasic
      typst
      uv
      yt-dlp
      zapzap
      rustic
      swaynotificationcenter
      imagemagick
      highlight
      engrampa
      thunar
      blueman
      wl-mirror

      ####bitwarden related###
      bitwarden-desktop # will be replaced by bitwarden-desktop
      rofi-rbw
      rbw
      pinentry-rofi
      pinentry-gnome3
      dotool
      wtype
      cliphist
      swww
      grim
      slurp
      file-roller
      swaynotificationcenter
      pavucontrol
      tree
      nix-tree
      protonup-qt
      #fonts
      nerd-fonts.jetbrains-mono
      fantasque-sans-mono
      font-awesome
      roboto
      source-sans-pro
    ])
    ++ (with pkgs-stable; [
      freeplane
      microsoft-edge
      ganttproject-bin
      inkscape-with-extensions
    ])
    ++ [

      # Import Scripts
      (import ../../config/scripts/emopicker9000.nix { inherit pkgs; })
      (import ../../config/scripts/task-waybar.nix { inherit pkgs; })
      (import ../../config/scripts/squirtle.nix { inherit pkgs; })
      (import ../../config/scripts/wallsetter.nix {
        inherit pkgs;
        inherit wallpaperDir;
        inherit username;
        inherit wallpaperGit;
      })
      (import ../../config/scripts/themechange.nix {
        inherit pkgs;
        inherit flakeDir;
        inherit host;
      })
      (import ../../config/scripts/theme-selector.nix { inherit pkgs; })
      (import ../../config/scripts/rofi-launcher.nix { inherit pkgs; })
      (import ../../config/scripts/screenshootin.nix { inherit pkgs; })
    ];

  fonts.fontconfig.enable = true;
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
  # Create a directory in your home folder for scripts
  home.file."bin" = {
    source = ./bin; # This references a 'bin' directory next to your configuration
    recursive = true;
    executable = true;
  };

  # Add the bin directory to your PATH
  home.sessionPath = [
    "$HOME/bin"
  ];

  home.language = {
    base = "en_US.UTF-8";
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    LANG = "en_US.UTF-8";
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo:$TERMINFO_DIRS";
    #LC_ALL = "en_US.UTF-8";
  };
  home.shellAliases = {
    microsoft-edge-stable = "microsoft-edge";
  };

  programs.nh = {
    enable = true;
  };
  programs.bash = {
    enable = true;
  };
  programs.zsh = {
    enable = false;

  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = false;
  };

  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = lib.mkDefault 24;
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "${gitUsername}";
        email = "${gitEmail}";
      };
    };
  };

  # Create XDG Dirs
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    systemDirs = {
      data = [ "$HOME/.nix-profile/share" ];
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  programs.home-manager.enable = true;
}
