{pkgs, inputs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/greenscreen.yaml";
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/f0rdprefect/my-wallpaper/e97260d56e008664febd7309b912b41c4ea507dc/Neon_Cities_4-C0750.jpg";
      sha256 = "GGAACIUFyDGvwG2dgE02aMK46I3yo0+r+BtrV199emU=";
    };
    fonts = {
      serif = {
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };
      sansSerif = {
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd;
        name = "SFProText Nerd Font";
      };
      monospace = {
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono-nerd;
        name = "SFMono Nerd Font";
      };

      sizes = {
        applications = 13;
        terminal = 15;
        desktop = 12;
        popups = 13;
      };
    };
  };
}
