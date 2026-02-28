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
      recycle-bin = pkgs.yaziPlugins.recycle-bin;
      restore = pkgs.yaziPlugins.restore;
    };
    settings = {
      mgr = {
        ratio = [
          2
          4
          3
        ];
        show_hidden = false;
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
        {
          on = [
            "R"
            "z"
          ];
          run = "plugin restore";
          desc = "Restore from Trash";
        }
        {
          on = [
            "R"
            "o"
          ];
          run = "plugin recycle-bin -- open";
          desc = "Open Trash";
        }
        {
          on = [
            "R"
            "r"
          ];
          run = "plugin recycle-bin -- restore";
          desc = "Restore from Trash";
        }
        {
          on = [
            "R"
            "d"
          ];
          run = "plugin recycle-bin -- delete";
          desc = "Delete from Trash";
        }
        {
          on = [
            "R"
            "e"
          ];
          run = "plugin recycle-bin -- empty";
          desc = "Empty Trash";
        }
        {
          on = [
            "R"
            "D"
          ];
          run = "plugin recycle-bin -- emptyDays";
          desc = "Empty by Days";
        }
      ];
    };
    # Initialize the  plugins
    initLua = ''
      require("git"):setup()
      require("recycle-bin"):setup()
    '';
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
    trash-cli
  ];

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
}
