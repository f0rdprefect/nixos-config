{
  lib,
  options,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.ntp {
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
}
