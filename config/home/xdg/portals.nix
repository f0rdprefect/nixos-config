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

  # Force GTK apps to ask the portal for their file dialogs so that they end
  # up in yazi via xdg-desktop-portal-termfilechooser.
  home.sessionVariables = {
    GTK_USE_PORTAL = "1";
  };

  # Qt apps keep their Stylix qtct/kvantum theming, but route QFileDialog
  # through the XDG portal (-> termfilechooser -> yazi) instead of showing
  # the built-in Qt dialog.
  stylix.targets.qt.standardDialogs = "xdgdesktopportal";

  # Apps built with `rfd` (e.g. pdfcraft) fall back to zenity when they
  # cannot reach the portal over D-Bus; without it the dialog silently
  # vanishes. The missing dbus library path is added in
  # config/system/services.nix so the portal backend is preferred.
  home.packages = with pkgs; [
    zenity
  ];

  # Configure termfilechooser to use yazi
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [file_chooser]
    cmd=yazi-file-picker
  '';
}
