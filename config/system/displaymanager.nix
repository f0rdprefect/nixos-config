{
  pkgs,
  hostConfig,
  ...
}:

{
  services.libinput.enable = true;
  environment.systemPackages = [
    pkgs.iio-hyprland
  ];
  services.xserver = {
    enable = true;
    xkb = {
      variant = hostConfig.theKBDVariant;
      layout = "${hostConfig.theKBDLayout}, ${hostConfig.theSecondKBDLayout}";
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
