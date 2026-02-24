{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.microsoft-edge ];

  home.file.".config/microsoft-edge/edge-flags.conf".text = ''
    --ozone-platform=wayland
    --enable-features=UseOzonePlatform
    --gtk-version=4
  '';
}
