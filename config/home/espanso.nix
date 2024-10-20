{ pkgs, config,  ... }:

{
  #home.packages = with pkgs; [
  #  fzf
  #  fd
  #];
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
    matches = {
      base = {
        matches = [
          {
            trigger = ":now";
            replace = "It's {{currentdate}} {{currenttime}}";
          }
          {
            trigger = ":hello";
            replace = "line1\nline2";
          }
        ];
      };
      global_vars = {
        global_vars = [
          {
            name = "currentdate";
            type = "date";
            params = {format = "%d/%m/%Y";};
          }
          {
            name = "currenttime";
            type = "date";
            params = {format = "%R";};
          }
        ];
      };
    };
  };
}
