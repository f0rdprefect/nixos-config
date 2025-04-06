{
  pkgs,
  config,
  lib,
  inputs,
  host,
  ...
}:

let
  theme = config.colorScheme.palette;
  inherit (import ../../../hosts/${host}/options.nix)
    browser
    cpuType
    gpuType
    wallpaperDir
    borderAnim
    theKBDLayout
    terminal
    theSecondKBDLayout
    theKBDVariant
    sdl-videodriver
    ;
in
with lib;
{
  home.packages = with pkgs; [
        hypridle
        hyprlock
        wayland-pipewire-idle-inhibit
    ];
  stylix.targets.hyprland.enable = false;
  stylix.targets.hyprlock.enable = false;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
            pkgs.hyprlandPlugins.hyprtrails
            pkgs.hyprlandPlugins.hyprgrass
    ];
    extraConfig =
      let
        modifier = "SUPER";
      in
      concatStrings [
        ''
                monitor = eDP-1,preferred,0x0,1.2500
                monitor = ,preferred,auto-left,1
                xwayland {
                   force_zero_scaling = true
                }
                general {
                  gaps_in = 6
                  gaps_out = 8
                  border_size = 2
                  col.active_border = rgba(${theme.base0C}ff) rgba(${theme.base0D}ff) rgba(${theme.base0B}ff) rgba(${theme.base0E}ff) 45deg
                  col.inactive_border = rgba(${theme.base00}cc) rgba(${theme.base01}cc) 45deg
                  layout = dwindle
                  resize_on_border = true
                }

                input {
                  kb_layout = ${theKBDLayout}, ${theSecondKBDLayout}
                  kb_options = grp:alt_shift_toggle
                  kb_options=compose:caps
                  follow_mouse = 1
                  natural_scroll = true
                  touchpad {
                    drag_lock = false
                    disable_while_typing = true
                    natural_scroll = true
                    tap-to-click = false
                    clickfinger_behavior = true
                    scroll_factor = 0.5
                  }
                  sensitivity = 0.5 # -1.0 - 1.0, 0 means no modification.
                  accel_profile = adaptive
                  touchdevice {
                     enabled = true
                  }
                }
                $LAPTOP_KB_ENABLED = true
                device {
                    name = at-translated-set-2-keyboard
                    enabled = $LAPTOP_KB_ENABLED
                }
                env = NIXOS_OZONE_WL, 1
                env = NIXPKGS_ALLOW_UNFREE, 1
                env = XDG_CURRENT_DESKTOP, Hyprland
                env = XDG_SESSION_TYPE, wayland
                env = XDG_SESSION_DESKTOP, Hyprland
                env = GDK_BACKEND, wayland
                env = CLUTTER_BACKEND, wayland
                env = SDL_VIDEODRIVER, ${sdl-videodriver}
                env = QT_QPA_PLATFORM, wayland;xcb
                env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
                env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
                env = MOZ_ENABLE_WAYLAND, 1
                ${
                  if cpuType == "vm" then
                    ''
                      env = WLR_NO_HARDWARE_CURSORS,1
                      env = WLR_RENDERER_ALLOW_SOFTWARE,1
                    ''
                  else
                    ''''
                }
                ${
                  if gpuType == "nvidia" then
                    ''
                      env = WLR_NO_HARDWARE_CURSORS,1
                    ''
                  else
                    ''''
                }
                gestures {
                  workspace_swipe = true
                  workspace_swipe_fingers = 3
                  workspace_swipe_distance = 500
                  workspace_swipe_invert = true
                  workspace_swipe_min_speed_to_force = 30
                  workspace_swipe_cancel_ratio = 0.5
                  workspace_swipe_create_new = true
                  workspace_swipe_forever = true
                }
                misc {
                  mouse_move_enables_dpms = true
                  key_press_enables_dpms = false
                }
                animations {
                  enabled = yes
                  bezier = wind, 0.05, 0.9, 0.1, 1.05
                  bezier = winIn, 0.1, 1.1, 0.1, 1.1
                  bezier = winOut, 0.3, -0.3, 0, 1
                  bezier = liner, 1, 1, 1, 1
                  animation = windows, 1, 6, wind, slide
                  animation = windowsIn, 1, 6, winIn, slide
                  animation = windowsOut, 1, 5, winOut, slide
                  animation = windowsMove, 1, 5, wind, slide
                  animation = border, 1, 1, liner
                  ${
                    if borderAnim == true then
                      ''
                        animation = borderangle, 1, 30, liner, loop
                      ''
                    else
                      ''''
                  }
                  animation = fade, 1, 10, default
                  animation = workspaces, 1, 5, wind
                }
                decoration {
                  rounding = 5
                  active_opacity = 1.0
                  inactive_opacity = 0.9
                  fullscreen_opacity = 1.0

                  dim_inactive = true
                  dim_strength = 0.1
                  dim_special = 0.8

                  shadow {
                    enabled = true
                    range = 6
                    render_power = 1

                    color =  rgba(${theme.base0A}ff)
                    color_inactive = 0x50000000
                  }
                  blur {
                    enabled = true
                    size = 6
                    passes = 2
                    ignore_opacity = true
                    new_optimizations = true
                    special = true
                  }
                }
                plugin {
                  hyprtrails {
                    color = rgba(${theme.base0A}ff)
                  }
                }

                binds {
                  workspace_back_and_forth = true
                  allow_workspace_cycles = true
                  pass_mouse_when_bound = false
                }
                exec-once = $POLKIT_BIN
                exec-once = dbus-update-activation-environment --systemd --all
                exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
                exec-once = swww init
                exec-once = waybar
                exec-once = swaync
                exec-once = wallsetter
                exec-once = nm-applet --indicator
                exec-once = hypridle
                exec-once = wayland-pipewire-idle-inhibit
                exec-once = iio-hyprland
                exec-once = wl-paste --type text --watch cliphist store #Stores only text data
                exec-once = wl-paste --type image --watch cliphist store #Stores only image data

                dwindle {
                  pseudotile = true
                  preserve_split = true
                }
                #master {
                #  new_is_master = true
                #}
                bind = CTRLALT,P,exec,rofi-rbw
                bind = ${modifier}, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
                bind = ${modifier},Return,exec,${terminal}
                bind = ${modifier},D,exec,rofi-launcher
                bind = ${modifier}SHIFT,W,exec,web-search
                bind = ${modifier}SHIFT,N,exec,swaync-client -rs
                ${
                  if browser == "google-chrome" then
                    ''
                      bind = ${modifier},W,exec,google-chrome-stable
                    ''
                  else
                    ''
                      bind = ${modifier},W,exec,${browser}
                    ''
                }
                bind = ${modifier},E,exec,cosmic-files
                bind = ${modifier},S,exec,screenshootin
                bind = ${modifier},O,exec,obs
                bind = ${modifier},G,exec,gimp
                bind = ${modifier}SHIFT,G,exec,godot4
                bind = ${modifier},T,exec,thunar
                bind = ${modifier},M,exec,spotify
                bind = ${modifier},Q,killactive,
                bind = ${modifier},P,pseudo,
                bind = ${modifier}SHIFT,I,togglesplit,
                bind = ${modifier},F,fullscreen,
                bind = ${modifier}SHIFT,F,togglefloating,
                bind = ${modifier}SHIFT,C,exit,
                bind = ${modifier}SHIFT,left,movewindow,l
                bind = ${modifier}SHIFT,right,movewindow,r
                bind = ${modifier}SHIFT,up,movewindow,u
                bind = ${modifier}SHIFT,down,movewindow,d
                bind = ${modifier}SHIFT,h,movewindow,l
                bind = ${modifier}SHIFT,l,movewindow,r
                bind = ${modifier}SHIFT,k,movewindow,u
                bind = ${modifier}SHIFT,j,movewindow,d
                bind = ${modifier},left,movefocus,l
                bind = ${modifier},right,movefocus,r
                bind = ${modifier},up,movefocus,u
                bind = ${modifier},down,movefocus,d
                bind = ${modifier},h,movefocus,l
                bind = ${modifier},l,exec,pidof hyprlock || hyprlock
                bind = ${modifier},k,movefocus,u
                bind = ${modifier},j,movefocus,d
                bind = ${modifier},1,workspace,1
                bind = ${modifier},2,workspace,2
                bind = ${modifier},3,workspace,3
                bind = ${modifier},4,workspace,4
                bind = ${modifier},5,workspace,5
                bind = ${modifier},6,workspace,6
                bind = ${modifier},7,workspace,7
                bind = ${modifier},8,workspace,8
                bind = ${modifier},9,workspace,9
                bind = ${modifier},0,workspace,10
                bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
                bind = ${modifier},SPACE,togglespecialworkspace
                bind = ${modifier}SHIFT,1,movetoworkspace,1
                bind = ${modifier}SHIFT,2,movetoworkspace,2
                bind = ${modifier}SHIFT,3,movetoworkspace,3
                bind = ${modifier}SHIFT,4,movetoworkspace,4
                bind = ${modifier}SHIFT,5,movetoworkspace,5
                bind = ${modifier}SHIFT,6,movetoworkspace,6
                bind = ${modifier}SHIFT,7,movetoworkspace,7
                bind = ${modifier}SHIFT,8,movetoworkspace,8
                bind = ${modifier}SHIFT,9,movetoworkspace,9
                bind = ${modifier}SHIFT,0,movetoworkspace,10
                bind = ${modifier}CONTROL,right,workspace,e+1
                bind = ${modifier}CONTROL,left,workspace,e-1
                bind = ${modifier},mouse_down,workspace, e+1
                bind = ${modifier},mouse_up,workspace, e-1
                bindm = ${modifier},mouse:272,movewindow
                bindm = ${modifier},mouse:273,resizewindow
                bind = ALT,Tab,cyclenext
                bind = ALT,Tab,bringactivetotop
                bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
                bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
                bind = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                bind = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
                bind = ,XF86AudioPlay, exec, playerctl play-pause
                bind = ,XF86AudioPause, exec, playerctl play-pause
                bind = ,XF86AudioNext, exec, playerctl next
                bind = ,XF86AudioPrev, exec, playerctl previous
                bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
                bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%
                source = ~/.config/hypr/adhoc.conf
        ''
      ];
  };

  programs.hyprlock = {
        enable = true;
        extraConfig = concatStrings [
            ''

            general {
                grace = 1
            }

            background {
                monitor =
                # NOTE: use only 1 path
            	path = screenshot   # screenshot of your desktop
            	#path = $HOME/.config/hypr/wallpaper_effects/.wallpaper_modified   # NOTE only png supported for now
                #path = $HOME/.config/hypr/wallpaper_effects/.wallpaper_current # current wallpaper

                #color = $color7

                # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
                blur_size = 5
                blur_passes = 2 # 0 disables blurring
                noise = 0.0117
                contrast = 1.3000 # Vibrant!!!
                brightness = 0.8000
                vibrancy = 0.2100
                vibrancy_darkness = 0.0
            }

            input-field {
                monitor =
                size = 250, 50
                outline_thickness = 3
                dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
                dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
                dots_center = true
                outer_color = rgba(${theme.base05}ff)
                inner_color = rgba(${theme.base00}ff)
                font_color = rgba(${theme.base0C}ff)
                fade_on_empty = true
                placeholder_text = <i>Password...</i> # Text rendered in the input box when it's empty.
                hide_input = false

                position = 0, 80
                halign = center
                valign = bottom
            }

            # Date
            label {
                monitor =
                text = cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"
                color = rgba(${theme.base0C}ff)
                font_size = 34
                font_family = JetBrains Mono Nerd Font 10
                position = 0, -80
                halign = center
                valign = top
            }

            # Hour-Time
            label {
                monitor =
                text = cmd[update:1000] echo "$(date +"%H")"
            #    text = cmd[update:1000] echo "$(date +"%I")" #AM/PM
                color = rgba(255, 185, 0, .8)
                font_size = 150
                font_family = JetBrains Mono Nerd Font Mono ExtraBold
                position = 0, -200
                halign = center
                valign = top
            }

            # Minute-Time
            label {
                monitor =
                text = cmd[update:1000] echo "$(date +"%M")"
                color = rgba(15, 10, 222, .8)
                font_size = 150
                font_family = JetBrains Mono Nerd Font Mono ExtraBold
                position = 0, -450
                halign = center
                valign = top
            }

            # Seconds-Time
            label {
                monitor =
                text = cmd[update:1000] echo "$(date +"%S")"
            #    text = cmd[update:1000] echo "$(date +"%S %p")" #AM/PM
                color = rgba(${theme.base07}ff)
                font_size = 20
                font_family = JetBrains Mono Nerd Font Mono ExtraBold
                position = 0, -450
                halign = center
                valign = top
            }

            # User
            label {
                monitor =
                text =    $USER
                color = rgba(${theme.base0A}ff)
                font_size = 18
                font_family = Inter Display Medium

                position = 0, 20
                halign = center
                valign = bottom
            }

            # uptime
            label {
                monitor =
                text = cmd[update:60000] echo "<b> "$(uptime | cut -f 1 -d "," |cut -f 4-8 -d " ")" </b>"
                color = rgba(${theme.base0A}ff)
                font_size = 24
                font_family = JetBrains Mono Nerd Font 10
                position = 0, 0
                halign = right
                valign = bottom
            }

            # weather edit the scripts for locations
            # weather scripts are located in ~/.config/hypr/UserScripts Weather.sh and/or Weather.py
            # see https://github.com/JaKooLit/Hyprland-Dots/wiki/TIPS#%EF%B8%8F-weather-app-related-for-waybar-and-hyprlock
            label {
                monitor =
                text = cmd[update:3600000] [ -f ~/.cache/.weather_cache ] && cat  ~/.cache/.weather_cache
                color = rgba(${theme.base0A}ff)
                font_size = 24
                font_family = JetBrains Mono Nerd Font 10
                position = 50, 0
                halign = left
                valign = bottom
            }

            ''
        ];

  };
 services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
          };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

}
