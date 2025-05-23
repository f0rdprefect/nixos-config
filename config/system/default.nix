{ config, pkgs, ... }:

{
  imports = [
    ./amd-gpu.nix
    ./appimages.nix
    ./autorun.nix
    ./boot.nix
    ./displaymanager.nix
    ./distrobox.nix
    ./fido.nix
    ./flatpak.nix
    ./hwclock.nix
    ./intel-amd.nix
    ./intel-gpu.nix
    ./intel-nvidia.nix
    ./kernel.nix
    ./logitech.nix
    ./mullvad.nix
    ./nfs.nix
    ./ntp.nix
    ./nvidia.nix
    ./packages.nix
    ./polkit.nix
    ./python.nix
    ./printer.nix
    ./services.nix
    ./tailscale.nix
    #./steam.nix
    ./syncthing.nix
    ./vm.nix
  ];
}
