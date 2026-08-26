{
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.localHWClock {
  time.hardwareClockInLocalTime = true;
}
