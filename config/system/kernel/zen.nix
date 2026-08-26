{
  lib,
  pkgs,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.theKernel == "zen") {
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
