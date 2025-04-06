{ pkgs, config, ... }:

{
  imports = [
    # Enable &/ Configure Programs
    ./alacritty.nix
    ./bash.nix
    ./espanso.nix
    ./fzf.nix
    #    ./gtk-qt.nix
    ./hyprland
    ./kdenlive.nix
    ./kitty.nix
    ./neovim
    ./packages.nix
    ./rofi.nix
    ./starship.nix
    ./waybar.nix
    ./wlogout.nix
    ./swappy.nix
    ./swaylock.nix
    ./swaync.nix
    ./vifm
        #./vlc.nix did not work but make rebuild slow as hell
    ./wezterm.nix
    ./zeroad.nix
    ./zsh.nix

    # Place Home Files Like Pictures
    ./files.nix
  ];
}
