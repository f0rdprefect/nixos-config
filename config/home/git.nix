{ config, pkgs, ... }:

{
  programs.git-credential-oauth.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}
