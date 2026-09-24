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

  browserAppId = if hostConfig.browser == "google-chrome" then "google-chrome" else "firefox";

  terminalCmd =
    if lib.hasAttr hostConfig.terminal pkgs then
      lib.getExe pkgs.${hostConfig.terminal}
    else
      hostConfig.terminal;

  namedWorkspaces = [
    "main"
    "web"
    "chat"
    "dev"
    "tmp"
  ];

  # "main" <-> 1, "web" <-> 2, "dev" <-> 3, "chat" <-> 4, "tmp" <-> 5
  workspaceBind = n: name: "Mod+${n} { focus-workspace \"${name}\"; }";
  workspaceMoveBind = n: name: "Mod+Shift+${n} { move-column-to-workspace \"${name}\"; }";

  workspaceBinds = lib.imap0 (
    i: name:
    let
      n = toString (i + 1);
    in
    ''
      ${workspaceBind n name}
      ${workspaceMoveBind n name}
    ''
  ) namedWorkspaces;

  # Numerische Workspaces 1-12 via F1-F12 zusätzlich zu den benannten.
  workspaceNumberBinds =
    lib.concatMapStringsSep "\n"
      (ws: ''
        Mod+${ws.key} { focus-workspace ${toString ws.num}; }
        Mod+Shift+${ws.key} { move-column-to-workspace ${toString ws.num}; }
      '')
      [
        {
          key = "F1";
          num = 1;
        }
        {
          key = "F2";
          num = 2;
        }
        {
          key = "F3";
          num = 3;
        }
        {
          key = "F4";
          num = 4;
        }
        {
          key = "F5";
          num = 5;
        }
        {
          key = "F6";
          num = 6;
        }
        {
          key = "F7";
          num = 7;
        }
        {
          key = "F8";
          num = 8;
        }
        {
          key = "F9";
          num = 9;
        }
        {
          key = "F10";
          num = 10;
        }
        {
          key = "F11";
          num = 11;
        }
        {
          key = "F12";
          num = 12;
        }
      ];

  # Sprechende Titel für den Hotkey-Overlay statt roher nix-Store-Pfade.
  hkt = t: "hotkey-overlay-title=\"${t}\"";
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
                        click-method "clickfinger"
                        natural-scroll
                        scroll-method "two-finger"
                        accel-speed 0.5
                        accel-profile "adaptive"
                    }
                    mouse {
                        natural-scroll
                        accel-speed 0.5
                        accel-profile "adaptive"

                    }

                    focus-follows-mouse
                    workspace-auto-back-and-forth
                }

                layout {
                    gaps 4
                    center-focused-column "never"
                    always-center-single-column
                    border {
                        width 1
                        active-color "#${theme.base0D}"
                        inactive-color "#${theme.base03}"
                        urgent-color "#${theme.base08}"
                    }

                    focus-ring {
                        width 2
                        active-gradient from="#${theme.base0D}" to="#${theme.base07}" angle=45 relative-to="workspace-view"
                        inactive-color "#00000000"
                        urgent-color "#${theme.base08}"
                    }

                    shadow {
                        on
                        draw-behind-window true
                        softness 18
                        spread 4
                        offset x=0 y=4
                        color "#00000080"
                        inactive-color "#00000040"
                    }
                }

                blur {
                    passes 3
                    offset 3.0
                    noise 0.02
                    saturation 1.5
                }

                overview {
                    zoom 0.6
                    backdrop-color "#${theme.base00}"

                    workspace-shadow {
                        softness 40
                        spread 10
                        offset x=0 y=10
                        color "#00000050"
                    }
                }

            ${lib.concatMapStringsSep "\n" (name: "workspace \"${name}\"") namedWorkspaces}

                window-rule {
                    match app-id=".*"
                    geometry-corner-radius 5
                }

      window-rule {
                    match app-id="imv"
                    match app-id="loupe"
                    open-floating true
                    open-maximized-to-edges true
                }

                window-rule {
                    match app-id="${browserAppId}"
                    default-column-width { proportion 0.5; }
                    open-on-workspace "web"
                }

                window-rule {
                    match app-id="discord"
                    match app-id="org.telegram.desktop"
                    open-on-workspace "chat"
                }

                window-rule {
                    match app-id="mpv"
                    match app-id="io.github.celluloid_player.Celluloid"
                    open-maximized-to-edges true
                }

                prefer-no-csd
                screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

                hotkey-overlay {
                    hide-not-bound
                }

                animations {
                    workspace-switch {
                        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
                    }
                    horizontal-view-movement {
                        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
                    }
                    window-open {
                        duration-ms 150
                        curve "ease-out-expo"
                    }
                    window-close {
                        duration-ms 150
                        curve "ease-out-quad"
                    }
                    window-movement {
                        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
                    }
                    window-resize {
                        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
                    }
                    overview-open-close {
                        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
                    }
                    screenshot-ui-open {
                        duration-ms 200
                        curve "ease-out-quad"
                    }
                }

                environment {
                    NIXOS_OZONE_WL "1"
                    NIXPKGS_ALLOW_UNFREE "1"
                    XDG_CURRENT_DESKTOP "niri"
                    XDG_SESSION_TYPE "wayland"
                    XDG_SESSION_DESKTOP "niri"
                    MOZ_ENABLE_WAYLAND "1"
                    QT_QPA_PLATFORM "wayland;xcb"
                    QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
                    QT_AUTO_SCREEN_SCALE_FACTOR "1"
                    SDL_VIDEODRIVER "wayland"
                    GDK_BACKEND "wayland"
                    CLUTTER_BACKEND "wayland"
                }

                spawn-at-startup "${terminalCmd}"
                spawn-at-startup "ashell"
                spawn-at-startup "${lib.getExe pkgs.wayland-pipewire-idle-inhibit}"
                spawn-at-startup "nextcloud"
                spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
                spawn-sh-at-startup "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
                spawn-sh-at-startup "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} store"
                spawn-sh-at-startup "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} store"
                spawn-sh-at-startup "[ -n \"$POLKIT_BIN\" ] && \"$POLKIT_BIN\""

                binds {
                    Mod+Return ${hkt "Terminal öffnen"} { spawn "${terminalCmd}"; }
                    Mod+W ${hkt "Browser öffnen"} { spawn "${browserCmd}"; }
                    Mod+E ${hkt "Dateimanager (yazi)"} { spawn "${lib.getExe pkgs.kitty}" "--title" "File Manager" "-e" "${lib.getExe pkgs.yazi}"; }
                    Mod+T ${hkt "Dateimanager (Thunar)"} { spawn "${lib.getExe pkgs.thunar}"; }
                    Mod+S ${hkt "Screenshot (Skript)"} { spawn "screenshootin"; }
                    Mod+D ${hkt "App-Suche (rofi)"} { spawn "rofi-launcher"; }
                    Mod+Shift+W ${hkt "Web-Suche"} { spawn "web-search"; }
                    Mod+Shift+T ${hkt "To-dos"} { spawn "${lib.getExe pkgs.todofi-sh}" "-d" "~/Nextcloud/todo/todo.cfg"; }
                    Mod+Shift+E ${hkt "Espanso neustarten"} { spawn "systemctl" "restart" "--user" "espanso"; }
                    Ctrl+Alt+P ${hkt "Passwort aus Bitwarden"} { spawn "rofi-rbw"; }
                    Ctrl+Alt+V ${hkt "Zwischenablage-Verlauf"} { spawn-sh "${lib.getExe pkgs.cliphist} list | rofi -dmenu | ${lib.getExe pkgs.cliphist} decode | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"; }

                    Print hotkey-overlay-title="Screenshot" { screenshot; }
                    Ctrl+Print hotkey-overlay-title="Screenshot: Bildschirm" { screenshot-screen; }
                    Mod+Shift+S hotkey-overlay-title="Screenshot: Fenster" { screenshot-window show-pointer=true; }

                    Mod+Q repeat=false { close-window; }
                    Mod+F { maximize-column; }
                    Mod+Shift+F { fullscreen-window; }
                    Mod+P { toggle-column-tabbed-display; }
                    Mod+Shift+C hotkey-overlay-title="Niri beenden" { quit; }

                    Mod+L ${hkt "Bildschirm sperren"} { spawn-sh "pkill -9  ${lib.getExe pkgs.hyprlock};  ${lib.getExe pkgs.hyprlock}"; }
                    Mod+Ctrl+Shift+L ${hkt "Suspend"} { spawn "systemctl" "suspend"; }

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
                    Mod+Slash { show-hotkey-overlay; }

                ${lib.concatStringsSep "\n" workspaceBinds}
                ${workspaceNumberBinds}

                    Mod+Ctrl+Alt+Left  ${hkt "Workspace zu linkem Monitor"} { move-workspace-to-monitor-left; }
                    Mod+Ctrl+Alt+Right ${hkt "Workspace zu rechtem Monitor"} { move-workspace-to-monitor-right; }
                    Mod+Ctrl+Alt+Up    ${hkt "Workspace zu oberem Monitor"} { move-workspace-to-monitor-up; }
                    Mod+Ctrl+Alt+Down  ${hkt "Workspace zu unterem Monitor"} { move-workspace-to-monitor-down; }

                    XF86AudioRaiseVolume hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%+"; }
                    XF86AudioLowerVolume hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
                    XF86AudioMute hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
                    XF86AudioMicMute hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
                    XF86AudioPlay hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} play-pause"; }
                    XF86AudioPause hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} play-pause"; }
                    XF86AudioNext hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} next"; }
                    XF86AudioPrev hotkey-overlay-title=null allow-when-locked=true { spawn-sh "${lib.getExe pkgs.playerctl} previous"; }
                    XF86MonBrightnessDown hotkey-overlay-title=null allow-when-locked=true { spawn "${lib.getExe pkgs.brightnessctl}" "set" "5%-"; }
                    XF86MonBrightnessUp hotkey-overlay-title=null allow-when-locked=true { spawn "${lib.getExe pkgs.brightnessctl}" "set" "+5%"; }
                }
    '';
  };

  # niri.service zieht xdg-desktop-autostart.target hoch; dadurch würde
  # blueman.desktop (aus services.blueman) automatisch mitgestartet.
  # User-Override mit Hidden=true unterdrückt den Autostart, so dass sich
  # niri hier wie hyprland verhält (blueman nur bei Bedarf).
  xdg.configFile."autostart/blueman.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Blueman Applet
    Hidden=true
  '';
}
