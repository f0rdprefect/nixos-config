# Home Manager config for yakari, which until now was a plain NixOS/GNOME
# machine without any user-level configuration.
#
# Deliberately minimal: yakari runs GNOME, so it gets the shared font baseline
# but none of the Wayland/Kitty/Rofi tooling from config/home.
{
  config,
  pkgs,
  lib,
  ...
}:

let
  username = "yilian";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "26.05";

  imports = [ ../../config/home/fonts.nix ];

  xdg.enable = true;

  programs.home-manager.enable = true;
}
