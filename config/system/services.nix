{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

{
  # List services that you want to enable:
  services.zram-generator.enable = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.power-profiles-daemon.enable = false; # for tlp and auto-cpufreq
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;

    };
  };
  services.auto-cpufreq.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire-pulse."92-low-latency" = {
      context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "32/48000";
            pulse.default.req = "32/48000";
            pulse.max.req = "32/48000";
            pulse.min.quantum = "32/48000";
            pulse.max.quantum = "32/48000";
          };
        }
      ];
      stream.properties = {
        node.latency = "32/48000";
        resample.quality = 1;
      };
    };
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  programs.thunar.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.gnome-keyring.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  services.smartd = {
    enable = false;
    autodetect = true;
  };
services.fwupd.enable = true;
  virtualisation.waydroid.enable = true;

  stylix = {
    enable = true;
    base16Scheme = inputs.nix-colors.colorSchemes.monokai.palette;
    image = pkgs.fetchurl {
      url = "https://github.com/f0rdprefect/my-wallpaper/blob/main/comet_still2.jpg?raw=true";
      sha256 = "LvWXiPoa+v1WGtLZjxKPjPYQsF1gNdye3QdMoFAaB3E=";
    };
    polarity = "dark";
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat Medium";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 12;
        popups = 12;
      };
    };
    cursor = {
      package = pkgs.graphite-cursors;
      name = "graphite-dark-nord";
      size = 24;
    };
    opacity = {
      terminal = 0.87;
    };

  };
services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
                #  devices = [
                #    "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
                #    "/dev/input/by-id/usb-Framework_Laptop_16_Keyboard_Module_-_ANSI_FRAKDKEN0100000000-event-kbd"
                #    "/dev/input/by-id/usb-Framework_Laptop_16_Keyboard_Module_-_ANSI_FRAKDKEN0100000000-if02-event-kbd"
                #  ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
           a s d f j k l ;
          )
          (defvar
           tap-time 150
           hold-time 200
          )
          (defalias
           a (tap-hold $tap-time $hold-time a lmet)
           s (tap-hold $tap-time $hold-time s lalt)
           d (tap-hold $tap-time $hold-time d lsft)
           f (tap-hold $tap-time $hold-time f lctl)
           j (tap-hold $tap-time $hold-time j rctl)
           k (tap-hold $tap-time $hold-time k rsft)
           l (tap-hold $tap-time $hold-time l ralt)
           ; (tap-hold $tap-time $hold-time ; rmet)
          )

          (deflayer base
           @a  @s  @d  @f  @j  @k  @l  @;
          )
        '';
      };
    };
  };
}
