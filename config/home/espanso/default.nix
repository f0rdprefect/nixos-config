{
  pkgs,
  pkgs-stable,
  ...
}:

{
  home.packages = with pkgs-stable; [
    kdotool
  ];

  services.espanso = {
    enable = true;
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
