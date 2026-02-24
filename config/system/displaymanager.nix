{
  pkgs,
  config,
  ...
}:

let
  host = config.networking.hostName;
  inherit (import ../../hosts/${host}/options.nix)
    theKBDVariant
    theKBDLayout
    theSecondKBDLayout
    ;
in
{
  services.libinput.enable = true;
  environment.systemPackages = [
    pkgs.iio-hyprland
  ];
  services.xserver = {
    enable = true;
    xkb = {
      variant = "${theKBDVariant}";
      layout = "${theKBDLayout}, ${theSecondKBDLayout}";
    };
  };
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "doom";
      hide_borders = true;
    };
  };

}
