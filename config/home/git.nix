{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitSVN;
    settings = {
      credential = {
        helper = [ "cache --timeout=28800" ]; # Timeout in Sekunden
      };
    };
  };
  programs.git-credential-oauth.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
  programs.difftastic.git.enable = true;
  programs.mergiraf.enableGitIntegration = true;
  programs.lazygit = {
    enable = true;
    enableBashIntegration = true;

  };
}
