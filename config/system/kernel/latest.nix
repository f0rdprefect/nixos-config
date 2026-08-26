{
  lib,
  pkgs,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.theKernel == "latest") {
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
