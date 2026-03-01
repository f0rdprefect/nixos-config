{ pkgs, config, ... }:

{
  # Starship Prompt
  stylix.targets.starship.enable = false;
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    presets = [
      "nerd-font-symbols"
      "catppuccin-powerline"
    ];
  };
}
