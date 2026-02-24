{
  pkgs,
  ...
}:

{
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    ly.fprintAuth = false;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
  };
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="usb", ENV{PRODUCT}=="1209/beee/3c4", TAG+="uaccess", GROUP="plugdev", MODE="0660"
    ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="1209/beee/3c4" RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';
  services.pcscd.enable = true;
}
