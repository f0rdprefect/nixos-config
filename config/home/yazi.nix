{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      git = pkgs.yaziPlugins.git;
    };
    settings = {
      mgr.ratio = [
        2
        4
        3
      ];
      mgr.showhidden = true;
    };

  };
}
