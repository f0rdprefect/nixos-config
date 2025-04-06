{ config, pkgs, ... }:

let
  libbluray = pkgs.libbluray.override {
    withAACS = true;
    withBDPlus = true;
  };
  vlc = pkgs.vlc.override { inherit libbluray; };
in
{
  home.packages = [ vlc ];
}
