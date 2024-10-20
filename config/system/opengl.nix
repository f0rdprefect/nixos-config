{ pkgs, config, lib, ... }:

{
  # OpenGL
  hardware.graphics = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}
