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
  #  qt = {
  #   enable = true;
  # style.name = lib.mkForce "adwaita-dark";
  #platformTheme.name = lib.mkForce "gtk3";
  #};
}
