{
  config,
  pkgs,
  nixvim-conf,
  system,
  inputs,
  stylix,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  imports = [
    ../../config/home/neovim
    ../../config/home/vifm
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = "matt";
  home.homeDirectory = "/home/matt";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/greenscreen.yaml";
    image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    };

  };
  home.packages = [

    #inputs.nixvim-conf.packages.${system}.default
    pkgs.brave
    pkgs.chromium
    pkgs.code-cursor
    pkgs.firefox
    pkgs.freeplane
    pkgs.ganttproject-bin
    pkgs.gimp
    pkgs.git
    pkgs.git-credential-oauth
    pkgs.hamster
    pkgs.inkscape-with-extensions
    pkgs.libsForQt5.falkon
    pkgs.microsoft-edge
    pkgs.nixfmt-rfc-style
    pkgs.nomacs
    pkgs.ollama
    pkgs.pandoc
    pkgs.pokeget-rs
    pkgs.quickemu
    pkgs.signal-desktop
    pkgs.texliveBasic
    pkgs.typst
    pkgs.uv
    pkgs.yt-dlp
    pkgs.zapzap
    pkgs.rustic
    pkgs.swaynotificationcenter
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/matt/etc/profile.d/hm-session-vars.sh
  #
  home.language = {
    base = "en_US.UTF-8";
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    LANG = "en_US.UTF-8";
    #LC_ALL = "en_US.UTF-8";
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
    enableZshIntegration = true;
  };
  targets.genericLinux.enable = true;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
