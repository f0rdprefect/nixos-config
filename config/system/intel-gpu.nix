{
  pkgs,
  config,
  lib,
  host,
  ...
}:

let
  inherit (import ../../hosts/${host}/options.nix) gpuType;
in
lib.mkIf ("${gpuType}" == "intel") {
  # NixOS configuration for Intel UHD Graphics 620 with Vulkan support

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Intel media drivers
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
      intel-media-sdk

      # Vulkan support for Intel
      intel-compute-runtime # OpenCL support
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];

    # Enable 32-bit support if you need it (e.g., for games)
    enable32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    # Vulkan utilities for testing
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers

    # Mesa utilities
    mesa-demos
    glxinfo
  ];

  environment.sessionVariables = {
    # Force intel-media-driver
    LIBVA_DRIVER_NAME = "iHD";

    # Vulkan ICD (Installable Client Driver) path
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
  };

}
