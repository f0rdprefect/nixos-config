{
  config,
  lib,
  pkgs,
  ...
}:

let
  host = config.networking.hostName;
  inherit (import ../../hosts/${host}/options.nix) distrobox;
in
lib.mkIf (distrobox == true) {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  environment.systemPackages = [ pkgs.distrobox ];
}
