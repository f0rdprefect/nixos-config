{
  lib,
  pkgs,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.theKernel == "default") {
  boot.kernelPackages = pkgs.linuxPackages;
}
