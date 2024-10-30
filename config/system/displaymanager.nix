{ pkgs, config, host, inputs,... }:

let inherit (import ../../hosts/${host}/options.nix) theKBDVariant
theKBDLayout theSecondKBDLayout; in
{
  services.libinput.enable = true;
  environment.systemPackages = [ 
    inputs.iio-hyprland.packages.${pkgs.system}.default
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
