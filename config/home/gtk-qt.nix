{
  pkgs,
  config,
  lib,
  ...
}:

{
  # Styling Options
  gtk = {
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style = "kvantum";
    platformTheme.name = lib.mkForce "qt5ct";
    kvantum.enable = true;
  };
}
