{ config, pkgs, ... }:

{
    services.audiobookshelf = {
        enable = true;
        openFirewall = true;
        host = "0.0.0.0";
        port = 8888;
    };
}
