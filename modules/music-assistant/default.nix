{ config, pkgs, ... }:

{
  services.music-assistant = {
    enable = true;

    # Specify the providers you want to use
    providers = [
      "spotify" # For your Spotify Premium account
      "filesystem_local" # For your local MP3 collection
      "hass" # Home Assistant integration
      "hass_players" # Home Assistant players
      "squeezelite" # Squeezelite protocol support
      "dlna" # For MoOde discovery via DLNA/UPnP
    ];

    # Optional: Add extra command line options
    extraOptions = [
      "--log-level=info"
    ];
  };

  # Open necessary ports
  networking.firewall.allowedTCPPorts = [ 8095 ];

  # Enable mDNS for device discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
