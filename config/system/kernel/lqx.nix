{
  lib,
  pkgs,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.theKernel == "lqx") {
  boot.kernelPackages = pkgs.linuxPackages_lqx;
}
