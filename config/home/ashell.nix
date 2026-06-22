{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.ashell = {
    enable = true;
    settings = {
      log_level = "warn";
      region = "de-DE";
      position = "Top";
      appearance = {
        scale_factor = 1.5;
      };
      notifications = {
        format = "%m/%d %H:%M";
        show_timestamps = true;
        show_bodies = false;
        grouped = true;
        toast = true;
        toast_position = "top_right";
        toast_timeout = 4000;
        toast_limit = 5;
        toast_max_height = 150;
        blocklist = [
          "blueman"
          "^org\\.gnome\\."
        ];
      };
      modules = {
        center = [
          [
            "Workspaces"
            "Tempo"
          ]
        ];
        left = [
          [
            "WindowTitle"
          ]
        ];
        right = [
          [
            "Notifications"
            "SystemInfo"
            "Privacy"
            "Tray"
            "Settings"
          ]
        ];
      };

      tempo = {
        clock_format = "%a %d %b %R";
      };

      window_title = {
        mode = "Title";
        truncate_title_after_length = 42;
      };
    };
  };
}
