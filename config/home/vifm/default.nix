{ pkgs, config, ... }:

{
  #home.packages = with pkgs; [
  #  fzf
  #  fd
  #];
  programs.vifm = {
    enable = true;
  };
  home.file.".config/vifm/scripts/ffprobe.sh".source = ./ffprobe.sh;
  home.file.".config/vifm/colors/hunter.vifm".source = ./hunter.vifm;
  home.file.".config/vifm/colors/hunterv2.vifm".source = ./hunterv2.vifm;
  home.file.".config/vifm/vifmrc".source = ./vifmrc;
}
