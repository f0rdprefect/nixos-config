{
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.nfs {
  fileSystems."${hostConfig.nfsMountPoint}" = {
    device = hostConfig.nfsDevice;
    fsType = "nfs";
  };
  services = {
    rpcbind.enable = true;
    nfs.server.enable = true;
  };
}
