{
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.syncthing {
  services = {
    syncthing = {
      enable = true;
      user = hostConfig.username;
      dataDir = hostConfig.userHome; # Default folder for new synced folders
      configDir = "${hostConfig.userHome}/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };
}
