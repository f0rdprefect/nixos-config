{
  pkgs,
  config,
  lib,
  host,
  ...
}:

let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  inherit (import ../../hosts/${host}/options.nix) bar-number clock24h;
in
with lib;
{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [
          "hyprland/workspaces"
          "clock"

        ];
        modules-left = [
          "custom/startmenu"
          "hyprland/window"
          "pulseaudio"
          "cpu"
          "memory"
          "disk"
          "idle_inhibitor"
        ];
        modules-right = [
          "custom/hyprbindings"
          "custom/notification"
          "battery"
          "tray"
          "custom/exit"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format = if clock24h == true then "  {:L%H:%M}" else " {:L%I:%M %p}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 32;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 5;
          format = " {}% ";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2} % ";
          tooltip = true;
        };
        "disk" = {
          format = " {free} ";
          tooltip = true;
        };
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "{bandwidthDownOctets} ";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = false;
        };
        "tray" = {
          spacing = 1;
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source} ";
          format-bluetooth-muted = " {icon} {format_source} ";
          format-muted = " {format_source} ";
          format-source = " {volume}% ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            hands-free = " ";
            headset = " ";
            phone = " ";
            portable = " ";
            car = " ";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = " ";
          # exec = "rofi -show drun";
          on-click = "sleep 0.1 && rofi-launcher";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          on-click = "togglekbd";
          format = " (On/Off)";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='green'>🗪</span>"; # 󰃳 nf-md-bell-badge
            none = "🗪"; # 󰖔 nf-md-bell-outline
            dnd-notification = "<span foreground='gray'>🗪</span>";
            dnd-none = "🗪"; # nf-md-bell-cancel
            inhibited-notification = "<span foreground='red'>🗪</span>";
            inhibited-none = "🗪";
            dnd-inhibited-notification = "<span foreground='red'>🗪</span>";
            dnd-inhibited-none = "🗪";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}{capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 { capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = false;
        };
      }
    ];
    style = ''
      * {
        font-size: 20px;
      }
      .modules-right * {
        margin: 4px 2px;
        padding: 0px 8px;
      }
      #tray {
        padding: 0px 10px;
      }
      #tray > .passive {
        -gtk-icon-effect: dim;
      }
    '';

  };
}
