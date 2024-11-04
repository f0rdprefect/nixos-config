{ pkgs, config, nixvim-conf, ... }:

{
  home.packages = with pkgs; [
     nixvim-conf.packages.${system}.default
    ];
}
