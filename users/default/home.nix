{
  config,
  pkgs,
  inputs,
  username,
  lib,
  host,
  hostConfig,
  gtkThemeFromScheme,
  ...
}:
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  # Set The Colorscheme
  colorScheme = inputs.nix-colors.colorSchemes.${hostConfig.theme};

  # Import Program Configurations
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-colors.homeManagerModules.default
    ./../../config/home
  ];

  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = lib.mkDefault 24;
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = hostConfig.gitUsername;
        email = hostConfig.gitEmail;
      };
    };
  };

  # Create XDG Dirs
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    systemDirs = {
      data = [ "$HOME/.nix-profile/share" ];
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  programs.home-manager.enable = true;
}
