{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.blender {
  home.packages = with pkgs; [
    pkgs.blender-hip
  ];
}
