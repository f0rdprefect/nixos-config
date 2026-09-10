{ pkgs, ... }:

{
  # Use Home Manager's XDG portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gnome
      xdg-desktop-portal-termfilechooser
    ];
    config = {
      common = {
        default = [
          "hyprland"
          "niri"
          "gtk"
        ];
      };
      hyprland = {
        default = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };
  };
  
  # Configure termfilechooser to use yazi
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [file_chooser]
    cmd=yazi-file-picker
  '';
}