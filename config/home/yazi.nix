{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      git = pkgs.yaziPlugins.git;
    };
    settings = {
      mgr = {
        ratio = [
          2
          4
          3
        ];
        show_hidden = true;
      };
      # Git plugin fetchers
      plugin.prepend_fetchers = [
        {
          id = "git";
          name = "*";
          run = "git";
        }
        {
          id = "git";
          name = "*/";
          run = "git";
        }
      ];
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "Mount/unmount devices";
        }
      ];
    };
    # Initialize the git plugin
    initLua = ''
      require("git"):setup()
    '';
  };

  # Use Home Manager's XDG portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-termfilechooser
    ];
    config = {
      common = {
        default = [ "hyprland" ];
      };
      hyprland = {
        default = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };
  };

  # Enhanced yazi file picker script
  home.packages = with pkgs; [
    (writeShellScriptBin "yazi-file-picker" ''
      # Parse command line arguments for file chooser mode
      MULTIPLE=""
      DIRECTORY=""
      TITLE="Select File"

      while [[ $# -gt 0 ]]; do
        case $1 in
          --multiple)
            MULTIPLE="--choose-files"
            TITLE="Select Files"
            shift
            ;;
          --directory)
            DIRECTORY="--choose-dir"
            TITLE="Select Directory"
            shift
            ;;
          --save)
            TITLE="Save File"
            shift
            ;;
          --title=*)
            TITLE="''${1#*=}"
            shift
            ;;
          *)
            break
            ;;
        esac
      done

      TMPFILE=$(mktemp)

      # Determine yazi chooser mode
      if [ -n "$DIRECTORY" ]; then
        CHOOSER_ARG="--chooser-dir=$TMPFILE"
      elif [ -n "$MULTIPLE" ]; then
        CHOOSER_ARG="--chooser-files=$TMPFILE"
      else
        CHOOSER_ARG="--chooser-file=$TMPFILE"
      fi

      # Launch yazi in kitty with proper title
      ${pkgs.kitty}/bin/kitty --title="$TITLE" -e ${pkgs.yazi}/bin/yazi $CHOOSER_ARG "$@"

      # Output selected files/directories
      if [ -f "$TMPFILE" ] && [ -s "$TMPFILE" ]; then
        cat "$TMPFILE"
      fi
      rm -f "$TMPFILE"
    '')
  ];

  # Configure termfilechooser to use yazi
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [file_chooser]
    cmd=yazi-file-picker
  '';

  # Create desktop entry for yazi as file manager
  xdg.desktopEntries.yazi = {
    name = "Yazi File Manager";
    comment = "Blazing fast terminal file manager";
    exec = "yazi-file-picker %U";
    icon = "folder";
    categories = [
      "System"
      "FileTools"
      "FileManager"
    ];
    mimeType = [
      "inode/directory"
      "application/x-directory"
    ];
    terminal = false;
  };

  # Set yazi as default file manager todo move to separate file?
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
      "application/x-directory" = [ "yazi.desktop" ];
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
    };
    associations.removed = {
      "application/pdf" = [ "calibre-ebook-viewer.desktop" ];
    };
  };
}
