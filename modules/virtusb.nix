{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.virtusb;
in {
  options.modules.virtusb = {
    enable = mkEnableOption "virtviewer/quickemu USB passthrough";

    username = mkOption {
      type = types.str;
      description = "Username der USB-Passthrough nutzen darf";
      example = "alice";
    };

    extraPackages = mkOption {
      type = types.bool;
      default = true;
      description = "quickemu, virt-viewer und spice-gtk installieren";
    };
  };

  config = mkIf cfg.enable {
    # libvirtd aktivieren
    virtualisation.libvirtd.enable = true;

    # Das offizielle NixOS-Modul für SPICE USB Redirection –
    # setzt cap_fowner auf spice-client-glib-usb-acl-helper
    virtualisation.spiceUSBRedirection.enable = true;

    # User in die nötigen Gruppen packen
    users.groups.plugdev = {};

    users.users.${cfg.username} = {
      extraGroups = [ "libvirtd" "kvm" "plugdev" ];
    };

    # udev-Regel: USB-Geräte für plugdev freigeben + uaccess Tag
    # damit systemd-logind dem eingeloggten User direkten Zugriff gibt
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", MODE="0664", GROUP="plugdev", TAG+="uaccess"
    '';

    # polkit: libvirt-Verwaltung für libvirtd-Gruppe erlauben
    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.libvirt.unix.manage" &&
            subject.isInGroup("libvirtd")) {
          return polkit.Result.YES;
        }
      });
    '';

    # Optionale Pakete
    environment.systemPackages = mkIf cfg.extraPackages (with pkgs; [
      quickemu
      virt-viewer
      # spice-gtk wird bereits von spiceUSBRedirection installiert,
      # hier nochmal explizit für spice-vdagent etc.
      spice-gtk
    ]);
  };
}
