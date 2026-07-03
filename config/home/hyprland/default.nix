# hyprland-lua.nix
#
# Lua-basierter Hyprland-Config für Home Manager (stateVersion >= 26.05).
# Nutzt wayland.windowManager.hyprland.settings — das eingebaute Nix→Lua
# Mapping, statt rohe Lua-Strings zu schreiben. Jedes Attribut wird zu
# hl.<name>(...). Listen erzeugen mehrere Calls. _args für positionale
# Multi-Argument-Calls (z.B. bind). mkLuaInline für rohe Lua-Ausdrücke
# (Funktionen, lokale Variablen-Referenzen etc.)
#
# Toggle: useNewLuaConfig = true/false in hosts/<host>/options.nix

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

  browserCmd = if browser == "google-chrome" then "google-chrome-stable" else browser;

  terminalCmd = if lib.hasAttr terminal pkgs then lib.getExe pkgs.${terminal} else terminal; # Fallback falls terminal kein pkgs-Attribut ist (z.B. schon ein voller Befehl)

  inherit (lib.generators) mkLuaInline;

  # Helper: erzeugt einen hl.bind(...)-Eintrag über _args (positionale Argumente,
  # nicht ein Tabellen-Argument). Optional ein 3. Argument (flags-Tabelle).
  mkBind = keys: dispatcher: flags: {
    _args = [
      keys
      (mkLuaInline dispatcher)
    ]
    ++ lib.optional (flags != null) flags;
  };

  # Helper: erzeugt einen hl.bind(...)-Eintrag mit exec_cmd-Dispatcher.
  mkExecBind =
    keys: cmd: flags:
    mkBind keys ''hl.dsp.exec_cmd("${cmd}")'' flags;

in
with lib;
{
  imports = [ ../../../modules/wttr-cache.nix ];

  home.packages = with pkgs; [
    hypridle
    hyprlock
    hyprmon
    wayland-pipewire-idle-inhibit
  ];

  services.wttr-cache.enable = true;

  services.kdeconnect = {
    enable = true;
    package = pkgs.valent;
  };

  stylix.targets.hyprland.enable = true;
  stylix.targets.hyprlock.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = true;

    plugins = [
      # pkgs.hyprlandPlugins.hyprgrass
    ];

    settings = {

      # ── Lokale Lua-Variable für den Modifier ─────────────────────────────
      # _var erzeugt `local mod = "SUPER"` statt hl.mod(...)
      mod = {
        _var = "SUPER";
      };

      # ── monitor ───────────────────────────────────────────────────────────
      # Liste → mehrere hl.monitor(...)-Calls
      monitor = [
        {
          output = "desc:AU Optronics 0x2236";
          mode = "preferred";
          position = "0x0";
          scale = 1.25;
        }
        {
          output = "desc:BNQ BenQ PD3205U";
          mode = "3840x2160@60";
          position = "-3840x-1378";
          scale = 1.0;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto-left";
          scale = 1.0;
        }
      ];

      # ── env ───────────────────────────────────────────────────────────────
      # Liste → mehrere hl.env(...)-Calls. _args für positionale (key, value).
      env = [
        {
          _args = [
            "NIXOS_OZONE_WL"
            "1"
          ];
        }
        {
          _args = [
            "NIXPKGS_ALLOW_UNFREE"
            "1"
          ];
        }
        {
          _args = [
            "XDG_CURRENT_DESKTOP"
            "Hyprland"
          ];
        }
        {
          _args = [
            "XDG_SESSION_TYPE"
            "wayland"
          ];
        }
        {
          _args = [
            "XDG_SESSION_DESKTOP"
            "Hyprland"
          ];
        }
        {
          _args = [
            "GDK_BACKEND"
            "wayland"
          ];
        }
        {
          _args = [
            "CLUTTER_BACKEND"
            "wayland"
          ];
        }
        {
          _args = [
            "SDL_VIDEODRIVER"
            sdl-videodriver
          ];
        }
        {
          _args = [
            "QT_QPA_PLATFORM"
            "wayland;xcb"
          ];
        }
        {
          _args = [
            "QT_WAYLAND_DISABLE_WINDOWDECORATION"
            "1"
          ];
        }
        {
          _args = [
            "QT_AUTO_SCREEN_SCALE_FACTOR"
            "1"
          ];
        }
        {
          _args = [
            "MOZ_ENABLE_WAYLAND"
            "1"
          ];
        }
      ]
      ++ lib.optionals (cpuType == "vm") [
        {
          _args = [
            "WLR_NO_HARDWARE_CURSORS"
            "1"
          ];
        }
        {
          _args = [
            "WLR_RENDERER_ALLOW_SOFTWARE"
            "1"
          ];
        }
      ]
      ++ lib.optionals (gpuType == "nvidia") [
        {
          _args = [
            "WLR_NO_HARDWARE_CURSORS"
            "1"
          ];
        }
      ];

      # ── Konfigurationskategorien via hl.config({...}) ───────────────────
      # Alle Kategorien in einem einzigen hl.config({...})-Call.
      # Das ist der garantiert existierende generische Mechanismus.
      # Dedizierte Top-Level-Funktionen wie hl.decoration() existieren
      # teils nicht — hl.config() funktioniert immer.
      # Stylix fügt seinen eigenen hl.config()-Call hinzu, Hyprland merged beide.
      config = {
        # ── input ─────────────────────────────────────────────────────────────
        input = {
          kb_layout = "${theKBDLayout}, ${theSecondKBDLayout}";
          kb_options = "grp:alt_shift_toggle,compose:caps";
          follow_mouse = 1;
          natural_scroll = true;
          sensitivity = 0.5;
          accel_profile = "adaptive";

          touchpad = {
            drag_lock = false;
            disable_while_typing = true;
            natural_scroll = true;
            tap_to_click = false;
            clickfinger_behavior = true;
            scroll_factor = 0.5;
          };
          touchdevice = {
            enabled = true;
          };
        };


        general = {
          gaps_in = 3;
          gaps_out = 4;
          border_size = 2;
          layout = "dwindle";
          resize_on_border = true;
        };

        decoration = {
          rounding = 5;
          active_opacity = 1.0;
          inactive_opacity = 0.9;
          fullscreen_opacity = 1.0;
          dim_inactive = true;
          dim_strength = 0.1;
          dim_special = 0.8;

          shadow = {
            enabled = true;
            range = 6;
            render_power = 1;
            color_inactive = "0x50000000";
          };

          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            ignore_opacity = true;
            new_optimizations = true;
            special = true;
          };
        };

        gestures = {
          workspace_swipe_distance = 500;
          workspace_swipe_invert = true;
          workspace_swipe_min_speed_to_force = 30;
          workspace_swipe_cancel_ratio = 0.5;
          workspace_swipe_create_new = true;
          workspace_swipe_forever = true;
        };

        misc = {
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = false;
        };

        binds = {
          workspace_back_and_forth = true;
          allow_workspace_cycles = true;
          pass_mouse_when_bound = false;
        };

        dwindle = {
          preserve_split = true;
        };

        xwayland = {
          force_zero_scaling = false;
        };
      };

      # ── Bezier-Kurven ─────────────────────────────────────────────────────
      # hl.curve(name, {...}) — _args für (name, table)
      curve = [
        {
          _args = [
            "wind"
            {
              type = "bezier";
              points = [
                [
                  0.05
                  0.9
                ]
                [
                  0.1
                  1.05
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "winIn"
            {
              type = "bezier";
              points = [
                [
                  0.1
                  1.1
                ]
                [
                  0.1
                  1.1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "winOut"
            {
              type = "bezier";
              points = [
                [
                  0.3
                  (-0.3)
                ]
                [
                  0
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "liner"
            {
              type = "bezier";
              points = [
                [
                  1
                  1
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
      ];

      # ── Animationen ───────────────────────────────────────────────────────
      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 6;
          bezier = "wind";
          style = "slide";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 6;
          bezier = "winIn";
          style = "slide";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 5;
          bezier = "winOut";
          style = "slide";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 5;
          bezier = "wind";
          style = "slide";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 1;
          bezier = "liner";
        }
      ]
      ++ lib.optional borderAnim {
        leaf = "borderangle";
        enabled = true;
        speed = 30;
        bezier = "liner";
        style = "loop";
      }
      ++ [
        {
          leaf = "fade";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 5;
          bezier = "wind";
        }
      ];

      # ── window_rule ───────────────────────────────────────────────────────
      window_rule = [
        {
          name = "suppress-maximize-events";
          match = {
            class = ".*";
          };
          suppress_event = "maximize";
        }
        {
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
      ];

      # ── Autostart via hl.on("hyprland.start", function() ... end) ───────
      # Liste mit zwei Einträgen → zwei hl.on(...)-Calls. Hyprland ruft beim
      # Start alle registrierten "hyprland.start"-Handler auf, daher ist es
      # sauber möglich, Autostart-Programme und Workspace-Keybind-Loop in
      # getrennte Funktionen aufzuteilen statt alles in einen Riesenblock zu quetschen.
      on = [
        {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
                  -- SICHERHEITSNETZ: Kitty startet immer zuerst.
                  -- Entfernen sobald der Config stabil läuft.
                  hl.exec_cmd("${lib.getExe pkgs.kitty}")

                  hl.exec_cmd("${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all")
                  hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

                  hl.exec_cmd("ashell")
                  -- hl.exec_cmd("${lib.getExe pkgs.waybar}")

                  hl.exec_cmd("${lib.getExe pkgs.hypridle}")
                  hl.exec_cmd("${lib.getExe pkgs.wayland-pipewire-idle-inhibit}")
                  hl.exec_cmd("nextcloud")
                  hl.exec_cmd("iio-hyprland")

                  hl.exec_cmd("${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} store")
                  hl.exec_cmd("${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} store")

                  local polkit = os.getenv("POLKIT_BIN")
                  if polkit and polkit ~= "" then
                      hl.exec_cmd(polkit)
                  end
              end
            '')
          ];
        }
      ];

      # ── Keybindings ───────────────────────────────────────────────────────
      # WICHTIG: jeder Modifier braucht sein eigenes "+", auch zwischen mod
      # und dem nächsten Modifier. "SUPER SHIFT + h" ist UNGÜLTIG,
      # "SUPER + SHIFT + h" ist korrekt. hl.bindm existiert nicht — Maus-
      # Drag/Resize läuft über normales hl.bind(..., { mouse = true }).
      bind = [
                # Workspace-Keybind
        (mkBind (mkLuaInline ''mod .. " + 1 "'') "hl.dsp.focus({ workspace = 1 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 1 "'') "hl.dsp.window.move({ workspace = 1 })" null)
        (mkBind (mkLuaInline ''mod .. " + 2 "'') "hl.dsp.focus({ workspace = 2 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 2 "'') "hl.dsp.window.move({ workspace = 2 })" null)
        (mkBind (mkLuaInline ''mod .. " + 3 "'') "hl.dsp.focus({ workspace = 3 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 3 "'') "hl.dsp.window.move({ workspace = 3 })" null)
        (mkBind (mkLuaInline ''mod .. " + 4 "'') "hl.dsp.focus({ workspace = 4 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 4 "'') "hl.dsp.window.move({ workspace = 4 })" null)
        (mkBind (mkLuaInline ''mod .. " + 5 "'') "hl.dsp.focus({ workspace = 5 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 5 "'') "hl.dsp.window.move({ workspace = 5 })" null)
        (mkBind (mkLuaInline ''mod .. " + 6 "'') "hl.dsp.focus({ workspace = 6 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 6 "'') "hl.dsp.window.move({ workspace = 6 })" null)
        (mkBind (mkLuaInline ''mod .. " + 7 "'') "hl.dsp.focus({ workspace = 7 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 7 "'') "hl.dsp.window.move({ workspace = 7 })" null)
        (mkBind (mkLuaInline ''mod .. " + 8 "'') "hl.dsp.focus({ workspace = 8 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 8 "'') "hl.dsp.window.move({ workspace = 8 })" null)
        (mkBind (mkLuaInline ''mod .. " + 9 "'') "hl.dsp.focus({ workspace = 9 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 9 "'') "hl.dsp.window.move({ workspace = 9 })" null)
        (mkBind (mkLuaInline ''mod .. " + 0 "'') "hl.dsp.focus({ workspace = 0 })" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + 0 "'') "hl.dsp.window.move({ workspace = 0 })" null)
        # Anwendungen

        (mkExecBind (mkLuaInline ''mod .. " + Return"'') terminalCmd null)
        (mkExecBind (mkLuaInline ''mod .. " + W"'') browserCmd null)
        (mkExecBind (mkLuaInline ''mod .. " + E"'')
          "${lib.getExe pkgs.kitty} --title 'File Manager' -e ${lib.getExe pkgs.yazi}"
          null
        )
        (mkExecBind (mkLuaInline ''mod .. " + T"'') "${lib.getExe pkgs.xfce.thunar}" null)
        (mkExecBind (mkLuaInline ''mod .. " + S"'') "screenshootin" null)
        (mkExecBind (mkLuaInline ''mod .. " + D"'') "rofi-launcher" null)

        # Tools / Rofi
        (mkExecBind (mkLuaInline ''mod .. " + SHIFT + W"'') "web-search" null)
        (mkExecBind (mkLuaInline ''mod .. " + SHIFT + N"'') "swaync-client -rs" null)
        (mkExecBind (mkLuaInline ''mod .. " + SHIFT + T"'')
          "${lib.getExe pkgs.todofi-sh} -d ~/Nextcloud/todo/todo.cfg"
          null
        )
        (mkExecBind (mkLuaInline ''mod .. " + SHIFT + E"'') "systemctl restart --user espanso" null)
        (mkExecBind "CTRL + ALT + P" "rofi-rbw" null)
        (mkExecBind "CTRL + ALT + V"
          "${lib.getExe pkgs.cliphist} list | rofi -dmenu | ${lib.getExe pkgs.cliphist} decode | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
          null
        )

        # Fensterverwaltung
        (mkBind (mkLuaInline ''mod .. " + Q"'') "hl.dsp.window.close()" null)
        (mkBind (mkLuaInline ''mod .. " + P"'') "hl.dsp.window.pseudo()" null)
        (mkBind (mkLuaInline ''mod .. " + F"'') "hl.dsp.window.fullscreen()" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + F"'') ''hl.dsp.window.float({ action = "toggle" })'' null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + C"'') "hl.dsp.exit()" null)

        # Fokus
        (mkBind (mkLuaInline ''mod .. " + left"'') ''hl.dsp.focus({ direction = "left" })'' null)
        (mkBind (mkLuaInline ''mod .. " + right"'') ''hl.dsp.focus({ direction = "right" })'' null)
        (mkBind (mkLuaInline ''mod .. " + up"'') ''hl.dsp.focus({ direction = "up" })'' null)
        (mkBind (mkLuaInline ''mod .. " + down"'') ''hl.dsp.focus({ direction = "down" })'' null)
        (mkBind (mkLuaInline ''mod .. " + h"'') ''hl.dsp.focus({ direction = "left" })'' null)
        (mkBind (mkLuaInline ''mod .. " + k"'') ''hl.dsp.focus({ direction = "up" })'' null)
        (mkBind (mkLuaInline ''mod .. " + j"'') ''hl.dsp.focus({ direction = "down" })'' null)

        # Sperren / Suspend
        (mkExecBind (mkLuaInline ''mod .. " + l"'')
          "pidof ${lib.getExe pkgs.hyprlock} || ${lib.getExe pkgs.hyprlock}"
          null
        )
        (mkExecBind (mkLuaInline ''mod .. " + SHIFT + l"'') "systemctl suspend" null)

        # Fenster verschieben
        (mkBind (mkLuaInline ''mod .. " + SHIFT + left"'') ''hl.dsp.window.move({ direction = "left" })''
          null
        )
        (mkBind (mkLuaInline ''mod .. " + SHIFT + right"'') ''hl.dsp.window.move({ direction = "right" })''
          null
        )
        (mkBind (mkLuaInline ''mod .. " + SHIFT + up"'') ''hl.dsp.window.move({ direction = "up" })'' null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + down"'') ''hl.dsp.window.move({ direction = "down" })''
          null
        )
        (mkBind (mkLuaInline ''mod .. " + SHIFT + h"'') ''hl.dsp.window.move({ direction = "left" })'' null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + l"'') ''hl.dsp.window.move({ direction = "right" })''
          null
        )
        (mkBind (mkLuaInline ''mod .. " + SHIFT + k"'') ''hl.dsp.window.move({ direction = "up" })'' null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + j"'') ''hl.dsp.window.move({ direction = "down" })'' null)

        # Special Workspace
        (mkBind (mkLuaInline ''mod .. " + SPACE"'') "hl.dsp.workspace.toggle_special()" null)
        (mkBind (mkLuaInline ''mod .. " + SHIFT + SPACE"'')
          ''hl.dsp.window.move({ workspace = "special" })''
          null
        )

        # Workspace cycling — hl.dsp.focus akzeptiert workspace = "e+1"/"e-1"
        # laut Wiki-Beispiel: hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
        (mkBind (mkLuaInline ''mod .. " + CONTROL + right"'') ''hl.dsp.focus({ workspace = "e+1" })'' null)
        (mkBind (mkLuaInline ''mod .. " + CONTROL + left"'') ''hl.dsp.focus({ workspace = "e-1" })'' null)

        # Maus-Scroll
        (mkBind (mkLuaInline ''mod .. " + mouse_down"'') ''hl.dsp.focus({ workspace = "e+1" })'' null)
        (mkBind (mkLuaInline ''mod .. " + mouse_up"'') ''hl.dsp.focus({ workspace = "e-1" })'' null)

        # Alt+Tab — hl.dsp.focus kennt kein `cycle`-Feld. Laut Wiki-Beispiel
        # braucht das eine Lua-Funktion mit zwei Dispatches.
        (mkBind "ALT + Tab" ''
          function()
              hl.dispatch(hl.dsp.window.cycle_next())
              hl.dispatch(hl.dsp.window.bring_to_top())
          end
        '' null)

        # Maus-Drag/Resize (ersetzt das nicht-existente hl.bindm)
        (mkBind (mkLuaInline ''mod .. " + mouse:272"'') "hl.dsp.window.drag()" { mouse = true; })
        (mkBind (mkLuaInline ''mod .. " + mouse:273"'') "hl.dsp.window.resize()" { mouse = true; })

        # Lautstärke / Media (mit locked/repeating Flags)
        (mkExecBind "XF86AudioRaiseVolume"
          "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkExecBind "XF86AudioLowerVolume"
          "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          {
            locked = true;
            repeating = true;
          }
        )
        (mkExecBind "XF86AudioMute"
          "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle"
          { locked = true; }
        )
        (mkExecBind "XF86AudioMicMute"
          "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          { locked = true; }
        )
        (mkExecBind "XF86AudioPlay" "${lib.getExe pkgs.playerctl} play-pause" { locked = true; })
        (mkExecBind "XF86AudioPause" "${lib.getExe pkgs.playerctl} play-pause" { locked = true; })
        (mkExecBind "XF86AudioNext" "${lib.getExe pkgs.playerctl} next" { locked = true; })
        (mkExecBind "XF86AudioPrev" "${lib.getExe pkgs.playerctl} previous" { locked = true; })

        # Helligkeit
        (mkExecBind "XF86MonBrightnessDown" "${lib.getExe pkgs.brightnessctl} set 5%-" {
          locked = true;
          repeating = true;
        })
        (mkExecBind "XF86MonBrightnessUp" "${lib.getExe pkgs.brightnessctl} set +5%" {
          locked = true;
          repeating = true;
        })
      ];

    };
  };

  # ── hyprlock ─────────────────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 1;
        hide_cursor = true;
        ignore_empty_input = false;
      };
      animations = {
        enabled = true;
        fade_in = {
          duration = 300;
          bezier = "easeOutQuint";
        };
        fade_out = {
          duration = 300;
          bezier = "easeOutQuint";
        };
      };
      background = lib.mkForce [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 5;
          noise = 0.0117;
          contrast = 1.3000;
          brightness = 0.8000;
          vibrancy = 0.2100;
          vibrancy_darkness = 0.0;
        }
      ];
      label = [
        {
          text = ''cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"'';
          font_size = 34;
          position = "0, -80";
          halign = "center";
          valign = "top";
        }
        {
          text = ''cmd[update:60000] echo "$(date +"%H:%M")"'';
          font_size = 80;
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {
          text = "   $USER";
          color = "rgba(${theme.base0A}ff)";
          font_size = 24;
          font_family = "Inter Display Medium";
          position = "0, 20";
          halign = "center";
          valign = "bottom";
        }
        {
          text = ''cmd[update:60000] echo "<b> "$(uptime | cut -f 1 -d "," | cut -f 4-8 -d " ")" </b>"'';
          color = "rgba(${theme.base0A}ff)";
          font_size = 24;
          position = "0, 0";
          halign = "right";
          valign = "bottom";
        }
        {
          text = ''cmd[update:160000] echo "<b> "$(cat ~/.cache/wttr/weather.txt)" </b>"'';
          color = "rgba(${theme.base0A}ff)";
          font_size = 24;
          position = "0, 0";
          halign = "left";
          valign = "bottom";
        }
      ];
    };
  };

  # ── hypridle ─────────────────────────────────────────────────────────────
  services.hypridle = {
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

  # ── hyprpaper ────────────────────────────────────────────────────────────
  services.hyprpaper.settings = {
    wallpaper = [
      {
        path = "${wallpaperDir}";
        timeout = 900;
      }
    ];
  };
}
