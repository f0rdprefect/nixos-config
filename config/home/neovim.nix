{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
     inputs.nixvim.packages.${system}.default
    ];
}
