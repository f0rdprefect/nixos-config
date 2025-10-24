{ pkgs, config, ... }:

{
  # Place Files Inside Home Directory
  home.file.".emoji".source = ./files/emoji;
  home.file.".base16-themes".source = ./files/base16-themes;
  home.file.".face".source = ./files/face.jpg; # For GDM
  home.file.".face.icon".source = ./files/face.jpg; # For SDDM
  home.file.".config/rofi/rofi.jpg".source = ./files/rofi.jpg;
  #  home.file.".config/starship.toml".source = ./files/starship.toml;
  home.file.".config/rofi-rbw.rc".source = ./files/rofi-rbw.rc;
  home.file.".config/Yubico/u2f_keys".source = ./files/u2f_keys;
  home.file.".local/share/fonts" = {
    source = ./files/fonts;
    recursive = true;
  };
  home.file.".config/wlogout/icons" = {
    source = ./files/wlogout;
    recursive = true;
  };
  home.file.".config/obs-studio" = {
    source = ./files/obs-studio;
    recursive = true;
  };
}
