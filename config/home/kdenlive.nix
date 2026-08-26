{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.kdenlive {
  home.packages = with pkgs; [
    pkgs.kdenlive
  ];
}
