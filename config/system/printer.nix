{
  pkgs,
lib,
config,
  ...
}:
{
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother-QL-600";
        deviceUri = "usb://Brother/QL-600?serial=000G2G887410";
        location = "Desk Matt";
        description = "Brother QL-600";
        model = "ptouch-driver/Brother-QL-600-ptouch-ql.ppd.gz";
        # Alternative if the above doesn't work:
        # model = "drv:///sample.drv/generic.ppd";
      }
            #      {
            #        name = "Kyocera-ECOSYS-M5521cdw";
            #        deviceUri = "ipp://Kyocera%20ECOSYS%20M5521cdw._ipp._tcp.local/?uuid=4509a320-00dd-0108-006c-002507526632"; #dnssd did not work when not at home
            #        location = "Office Bérénice";
            #        description = "Kyocera ECOSYS M5521cdw";
            #        model = "everywhere"; # Modern Kyocera printers support IPP Everywhere
            #        # Alternative: model = "kyocera-ecosys-m5521cdw.ppd";
            #      }
      {
        name = "Canon-IR-OG1";
        deviceUri = "socket://pr-do-og1";
        location = "Raith HQ OG1";
        model = "CNRCUPSIRADVC3525ZK.ppd";
      }
    ];

        #    ensureDefaultPrinter = "Kyocera-ECOSYS-M5521cdw";
  };
  services = {
    printing = {
      enable = true;
      #logLevel = "debug";

      drivers = [
        pkgs.cups-kyocera-ecosys-m552x-p502x
        pkgs.canon-cups-ufr2
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

  users.groups.lp.members = builtins.attrNames (
  lib.filterAttrs (_: u: u.isNormalUser) config.users.users
);
users.groups.scanner.members = builtins.attrNames (
  lib.filterAttrs (_: u: u.isNormalUser) config.users.users
);
}
