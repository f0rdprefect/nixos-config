{
  config,
  pkgs,
  inputs,
  lib,
  host,
  gtkThemeFromScheme,
  ...
}:
let
  inherit (import ./../../hosts/${host}/options.nix)
    gitUsername
    gitEmail
    theme
    browser
    wallpaperDir
    wallpaperGit
    flakeDir
    waybarStyle
    ;
  username = "berenice";

in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  # Set The Colorscheme
  colorScheme = inputs.nix-colors.colorSchemes."${theme}";

  # Import Program Configurations
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-colors.homeManagerModules.default
    ./../../config/home
    ./packages.nix
  ];

  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = lib.mkDefault 24;
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
