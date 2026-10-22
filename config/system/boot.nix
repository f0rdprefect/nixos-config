{ lib, config, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };
  boot.tmp.useTmpfs = false;
  boot.tmp.tmpfsSize = "25%";

  # This is for OBS Virtual Cam Support - v4l2loopback setup
  # Disabled due to kernel module compatibility issues with linux 7.2.11+
  # Re-enable when nixpkgs/v4l2loopback version compatibility is resolved
  # boot.kernelModules = [ "v4l2loopback" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
}
