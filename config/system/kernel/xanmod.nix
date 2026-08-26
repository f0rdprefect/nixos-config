{
  lib,
  pkgs,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.theKernel == "xanmod") {
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
}
