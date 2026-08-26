{
  lib,
  hostConfig,
  ...
}:

lib.mkIf (hostConfig.cpuType == "vm") {
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;
}
