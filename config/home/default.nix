{ pkgs, config, ... }:

{
  imports = [
    # Enable &/ Configure Programs
    ./alacritty.nix
    ./bash.nix
    ./espanso
    ./fzf.nix
    #    ./gtk-qt.nix
    ./git.nix
    ./vifm
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
    ./xdg      # XDG configuration (portal, mime apps)
    ./yazi.nix
    ./zeroad.nix
    ./zsh.nix

    # Place Home Files Like Pictures
    ./files.nix
  ];
}
