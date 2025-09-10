{
  pkgs,
  config,
  lib,
  ...
}:
{
  # Ensure required packages are installed
  home.packages = with pkgs; [
    yazi # Terminal file manager
    papers # PDF viewer (GNOME Papers)
    nomacs # Image viewer
    kdePackages.okular # Alternative PDF viewer
    evince # Another PDF viewer
  ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Web browsers and HTML
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];

      # File management
      "inode/directory" = [ "yazi.desktop" ];
      "application/x-directory" = [ "yazi.desktop" ];

      # Documents - PDF (multiple options as fallbacks)
      "application/pdf" = [
        "org.gnome.Papers.desktop"
        "org.kde.okular.desktop"
        "org.gnome.Evince.desktop"
      ];

      # Images
      "image/png" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/jpeg" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/gif" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/webp" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/bmp" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/svg+xml" = [ "org.nomacs.ImageLounge.desktop" ];
    };

    associations = {
      added = {
        # Web browsers and HTML (explicitly added associations)
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/chrome" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "application/x-extension-htm" = [ "firefox.desktop" ];
        "application/x-extension-html" = [ "firefox.desktop" ];
        "application/x-extension-shtml" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
        "application/x-extension-xhtml" = [ "firefox.desktop" ];
        "application/x-extension-xht" = [ "firefox.desktop" ];
      };

      removed = {
        "application/pdf" = [ "calibre-ebook-viewer.desktop" ];
      };
    };
  };
}
