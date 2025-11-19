{ config, pkgs, ... }:

{
  services.music-assistant = {
    enable = true;

    # Specify the providers you want to use
    providers = [
            #"airplay"
      "apple_music"
      "audible"
      "audiobookshelf"
      "bluesound"
      "builtin"
      "builtin_player"
      "chromecast"
      "deezer"
      "dlna"
      "fanarttv"
      "filesystem_local"
      "filesystem_smb"
      "fully_kiosk"
      "gpodder"
      "hass"
      "hass_players"
      "ibroadcast"
      "itunes_podcasts"
      "jellyfin"
      "lastfm_scrobble"
      "listenbrainz_scrobble"
      "musicbrainz"
      "opensubsonic"
      "player_group"
      "plex"
      "podcastfeed"
      "qobuz"
      "radiobrowser"
      "siriusxm"
      "snapcast"
      "sonos"
      "sonos_s1"
      "soundcloud"
      "spotify"
      "spotify_connect"
      "squeezelite"
      "template_player_provider"
      "test"
      "theaudiodb"
      "tidal"
      "tunein"
      "ytmusic"
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
