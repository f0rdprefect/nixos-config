{ pkgs, config, ... }:

{
  # Starship Prompt
  stylix.targets.starship.enable = false;
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    settings = builtins.fromTOML (builtins.readFile ./files/starship-matt.toml);
  };
}
