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
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      git = pkgs.yaziPlugins.git;
    };
    settings = {
      mgr.ratio = [
        2
        4
        3
      ];
      mgr.showhidden = true;

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

      -- Optional: Customize git status styling
      -- th.git = th.git or {}
      -- th.git.modified = ui.Style():fg("blue")
      -- th.git.deleted = ui.Style():fg("red"):bold()
      -- th.git.added = ui.Style():fg("green")
      -- th.git.untracked = ui.Style():fg("yellow")

      -- Optional: Customize git status signs
      -- th.git.modified_sign = "M"
      -- th.git.deleted_sign = "D"
      -- th.git.added_sign = "A"
      -- th.git.untracked_sign = "?"
    '';
  };
  home.packages = with pkgs; [
    xdg-desktop-portal-termfilechooser
    (writeShellScriptBin "yazi-file-picker" ''
      #!/bin/bash
      TMPFILE=$(mktemp)
      ${pkgs.kitty}/bin/kitty -e ${pkgs.yazi}/bin/yazi --chooser-file="$TMPFILE" "$@"

      if [ -f "$TMPFILE" ] && [ -s "$TMPFILE" ]; then
        cat "$TMPFILE"
      fi
      rm -f "$TMPFILE"
    '')
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

  # Set yazi as default file manager
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
      "application/x-directory" = [ "yazi.desktop" ];
    };
  };
}
