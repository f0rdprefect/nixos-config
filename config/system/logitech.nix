{
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.logitech {
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}
