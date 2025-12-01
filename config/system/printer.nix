{
  config,
  lib,
  pkgs,
  username,
  host,
  ...
}:
{
  services = {
    printing = {
      enable = true;
      #logLevel = "debug";

      drivers = [
        pkgs.cups-kyocera-ecosys-m552x-p502x
        pkgs.ptouch-driver
        pkgs.cups-filters
        pkgs.cups-browsed
        pkgs.ghostscript
        pkgs.poppler-utils
        pkgs.cups-pdf-to-pdf
      ];
      extraConf = ''
        # Set ghostscript as default renderer for all printers
        DefaultOption pdftops-renderer=ghostscript
      '';

    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    disabledDefaultBackends = [ "escl" ];
  };
  programs.system-config-printer.enable = true;
  users.users.${username}.extraGroups = [
    "scanner"
    "lp"
  ];
}
