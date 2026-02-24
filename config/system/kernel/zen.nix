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
lib.mkIf (theKernel == "zen") {
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
