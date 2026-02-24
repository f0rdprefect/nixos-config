{
  config,
  lib,
  pkgs,
  ...
}:

let
  host = config.networking.hostName;
  inherit (import ../../../hosts/${host}/options.nix) theKernel;
in
lib.mkIf (theKernel == "lqx") {
  boot.kernelPackages = pkgs.linuxPackages_lqx;
}
