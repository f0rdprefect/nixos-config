{
  pkgs,
  pkgs-stable,
  ...
}:

{
  # Install Packages For The User
  home.packages =
    (with pkgs-stable; [
      chromium
    ])
    ++ (with pkgs; [
      pdfarranger
      ocrmypdf
      gnomeExtensions.dash-to-dock
      gnomeExtensions.gsconnect
      gnomeExtensions.workday-reminder
    ]);

}
