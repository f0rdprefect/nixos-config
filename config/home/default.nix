{ pkgs, config, ... }:

{
  imports = [
    # Enable &/ Configure Programs
    ./alacritty.nix
    ./bash.nix
    ./espanso.nix
    ./fzf.nix
    ./gtk-qt.nix
    ./hyprland.nix
    ./kdenlive.nix
    ./kitty.nix
    ./neovim.nix
    ./packages.nix
    ./rofi.nix
    ./starship.nix
    ./waybar.nix
    ./wlogout.nix
    ./swappy.nix
    ./swaylock.nix
    ./swaync.nix
    ./wezterm.nix
    ./zeroad.nix
    ./zsh.nix

    # Place Home Files Like Pictures
    ./files.nix
  ];
}
