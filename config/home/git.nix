{ config, pkgs, ... }:

{
  programs.git-credential-oauth.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
  programs.difftastic.git.enable = true;
  programs.mergiraf.enableGitIntegration = true;
}
