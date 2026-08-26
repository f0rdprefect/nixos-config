{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.enableZeroAD {
  home.packages = with pkgs; [
    zeroad
  ];
}
