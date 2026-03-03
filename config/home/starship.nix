{ pkgs, config, ... }:

{
  # Starship Prompt
  stylix.targets.starship.enable = false;
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    presets = [
      "nerd-font-symbols"
      "gruvbox-rainbow"
    ];
    settings = {
      hostname = {
        ssh_only = true;
        style = "bg:color_orange fg:color_fg0";
        format = "[@$hostname ]($style)";
      };
    };
  };
}
