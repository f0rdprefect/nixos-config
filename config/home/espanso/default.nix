{
  pkgs,
  config,
  ...
}:

{
  home.packages = with pkgs; [
    kdotool
    #  fd
  ];

  services.espanso = {
    enable = true;
    #package = pkgs.espanso-wayland;
    package = pkgs.espanso-wayland;
    configs = {
      default = {
        toggle_key = "ALT";
        keyboard_layout = {
          layout = "us";
        };
      };
    };
  };
  home.file.".config/espanso/match" = {
        source = ./match;
        recursive = true;
    };

}
