{ pkgs, config, lib, host, ... }:

let inherit (import ../../hosts/${host}/options.nix) gpuType; in
lib.mkIf ("${gpuType}" == "intel") { 
  nixpkgs.config.packageOverrides =
    pkgs: {
      intel-vaapi-driver = pkgs.intel-vaapi-driver.override { 
        enableHybridCodec = true; 
      };
      vaapiIntel = pkgs.vaapiIntel.override {
      enableHybridCodec = true;
    };
  };

  # OpenGL
  hardware.graphics = {
    extraPackages = with pkgs; [
      #intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { 
    LIBVA_DRIVER_NAME = "iHD"; 
  }; # Force intel-media-driver
}
