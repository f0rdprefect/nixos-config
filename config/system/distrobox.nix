{
  lib,
  pkgs,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.distrobox {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  environment.systemPackages = [ pkgs.distrobox ];
}
