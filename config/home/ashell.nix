{
  config,
  lib,
  pkgs,
  ...
}:

{
  stylix.targets.ashell.opacity.enable = false;
  programs.ashell = {
    enable = true;
    settings = {
      region = "de-DE";
      position = "Top";
      indicators = [
        "Battery"
        "Bluetooth"
        "Network"
        "Audio"
        "Microphone"
        "Brightness"
      ];
      battery_format = "IconAndTime";
      bluetooth_more_cmd = "blueman-manager";
      appearance = {
        scale_factor = 1.3;
      };
      notifications = {
        format = "%m/%d %H:%M";
        show_timestamps = true;
        show_bodies = false;
        grouped = true;
        toast = true;
        toast_position = "TopRight";
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
        weather_location = {
          City = "Dortmund";
        };
      };

      window_title = {
        mode = "Title";
        truncate_title_after_length = 42;
      };
      workspaces = {
        visibility_mode = "MonitorSpecific";
        enable_workspace_filling = false;
      };
    };
  };
}
