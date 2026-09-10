{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

let
  theme = config.colorScheme.palette;

  browserCmd =
    if hostConfig.browser == "google-chrome" then "google-chrome-stable" else hostConfig.browser;

  terminalCmd =
    if lib.hasAttr hostConfig.terminal pkgs then
      lib.getExe pkgs.${hostConfig.terminal}
    else
      hostConfig.terminal;
in
{
  imports = [ ../../../modules/wttr-cache.nix ];

  home.packages = with pkgs; [
    hypridle
    hyprlock
    nirimon
    wayland-pipewire-idle-inhibit
  ];

  services.wttr-cache.enable = true;

  wayland.windowManager.niri = {
    enable = true;
    extraConfig = ''
            input {
                keyboard {
                    xkb {
                        layout "${hostConfig.theKBDLayout},${hostConfig.theSecondKBDLayout}"
                        options "grp:alt_shift_toggle,compose:caps"
                    }
                }

                touchpad {
                    dwt
                    natural-scroll
                    accel-speed 0.5
                    accel-profile "adaptive"
                }
                mouse {
                    natural-scroll
                    accel-speed 0.5
                    accel-profile "adaptive"

                }

                focus-follows-mouse
            }

            layout {
                gaps 4
                center-focused-column "never"
                always-center-single-column
                border {
                    width 2
                    active-color "#${theme.base0D}"
                    inactive-color "#${theme.base03}"
                    urgent-color "#${theme.base08}"
                }

                focus-ring {
                    off
                }

                shadow {
                    on
                    draw-behind-window true
                    softness 18
                    spread 4
                    offset x=0 y=4
                    color "#00000080"
                }
            }

            prefer-no-csd
            screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

            spawn-at-startup "${terminalCmd}"
            spawn-at-startup "ashell"
            spawn-at-startup "${lib.getExe pkgs.wayland-pipewire-idle-inhibit}"
            spawn-at-startup "nextcloud"
            spawn-at-startup "iio-hyprland"
            spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
            spawn-sh-at-startup "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            spawn-sh-at-startup "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} store"
            spawn-sh-at-startup "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} store"
            spawn-sh-at-startup "[ -n \"$POLKIT_BIN\" ] && \"$POLKIT_BIN\""

            binds {
                Mod+Return { spawn "${terminalCmd}"; }
                Mod+W { spawn "${browserCmd}"; }
                Mod+E { spawn "${lib.getExe pkgs.kitty}" "--title" "File Manager" "-e" "${lib.getExe pkgs.yazi}"; }
                Mod+T { spawn "${lib.getExe pkgs.thunar}"; }
                Mod+S { spawn "screenshootin"; }
                Mod+D { spawn "rofi-launcher"; }
                Mod+Shift+W { spawn "web-search"; }
                Mod+Shift+T { spawn "${lib.getExe pkgs.todofi-sh}" "-d" "~/Nextcloud/todo/todo.cfg"; }
                Mod+Shift+E { spawn "systemctl" "restart" "--user" "espanso"; }
                Ctrl+Alt+P { spawn "rofi-rbw"; }
                Ctrl+Alt+V { spawn-sh "${lib.getExe pkgs.cliphist} list | rofi -dmenu | ${lib.getExe pkgs.cliphist} decode | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"; }

                Mod+Q repeat=false { close-window; }
                Mod+F { maximize-column; }
                Mod+Shift+F { fullscreen-window; }
                Mod+P { toggle-column-tabbed-display; }
                Mod+Shift+C { quit; }

                Mod+L { spawn-sh "pidof ${lib.getExe pkgs.hyprlock} || ${lib.getExe pkgs.hyprlock}"; }
                Mod+Ctrl+Shift+L { spawn "systemctl" "suspend"; }

                Mod+Left  { focus-column-left; }
                Mod+Right { focus-column-right; }
                Mod+Down  { focus-window-down; }
                Mod+Up    { focus-window-up; }
                Mod+H     { focus-column-left; }
                Mod+J     { focus-window-down; }
                Mod+K     { focus-window-up; }

                Mod+Shift+Left  { move-column-left; }
                Mod+Shift+Right { move-column-right; }
                Mod+Shift+Down  { move-window-down; }
                Mod+Shift+Up    { move-window-up; }
                Mod+Shift+H     { move-column-left; }
                Mod+Shift+J     { move-window-down; }
                Mod+Shift+K     { move-window-up; }
                Mod+Shift+L     { move-column-right; }

                Mod+Ctrl+Right { focus-workspace-up; }
                Mod+Ctrl+Left  { focus-workspace-down; }
                Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
                Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

                Alt+Tab { focus-workspace-previous; }
                Mod+Space repeat=false { toggle-overview; }
                Mod+Shift+Space { toggle-window-floating; }

                Mod+1 { focus-workspace 1; }
                Mod+2 { focus-workspace 2; }
                Mod+3 { focus-workspace 3; }
                Mod+4 { focus-workspace 4; }
                Mod+5 { focus-workspace 5; }
                Mod+6 { focus-workspace 6; }
                Mod+7 { focus-workspace 7; }
                Mod+8 { focus-workspace 8; }
                Mod+9 { focus-workspace 9; }
                Mod+0 { focus-workspace 10; }

                Mod+Shift+1 { move-window-to-workspace 1; }
                Mod+Shift+2 { move-window-to-workspace 2; }
                Mod+Shift+3 { move-window-to-workspace 3; }
                Mod+Shift+4 { move-window-to-workspace 4; }
                Mod+Shift+5 { move-window-to-workspace 5; }
                Mod+Shift+6 { move-window-to-workspace 6; }
                Mod+Shift+7 { move-window-to-workspace 7; }
                Mod+Shift+8 { move-window-to-workspace 8; }
                Mod+Shift+9 { move-window-to-workspace 9; }
                Mod+Shift+0 { move-window-to-workspace 10; }

                XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%+"; }
                XF86AudioLowerVolume allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
                XF86AudioMute allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
                XF86AudioMicMute allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
                XF86AudioPlay allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} play-pause"; }
                XF86AudioPause allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} play-pause"; }
                XF86AudioNext allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} next"; }
                XF86AudioPrev allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} previous"; }
                XF86MonBrightnessDown allow-when-locked=true { spawn "${lib.getExe pkgs.brightnessctl}" "set" "5%-"; }
                XF86MonBrightnessUp allow-when-locked=true { spawn "${lib.getExe pkgs.brightnessctl}" "set" "+5%"; }
            }
    '';
  };
}
