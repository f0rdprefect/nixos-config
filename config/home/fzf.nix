{ pkgs, config, ... }:

{
  #home.packages = with pkgs; [
  #  fzf
  #  fd
  #];
  programs.fzf = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
