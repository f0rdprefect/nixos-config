{
  pkgs,
  config,
  username,
  ...
}:

let
  host = config.networking.hostName;
  inherit (import ../../hosts/${host}/options.nix) wallpaperDir wallpaperGit;
in
{
  # system.userActivationScripts = {
  #   gitwallpapers.text = ''
  #   '';
  # };
}
