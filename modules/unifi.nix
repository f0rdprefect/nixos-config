{ pkgs, config, ... }:
{
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
    openFirewall = true; # Opens device communication ports

    initialJavaHeapSize = 1024;
    maximumJavaHeapSize = 2048;
  };

  # Add port 8443 for web interface access
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
