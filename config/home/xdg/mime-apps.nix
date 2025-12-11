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
        "org.gnome.Evince.desktop"
        "org.kde.okular.desktop"
      ];

      # Images
      "image/png" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/jpeg" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/gif" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/webp" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/bmp" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/svg+xml" = [ "org.nomacs.ImageLounge.desktop" ];

      # Office Documents
      "application/msword" = [ "writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
        "writer.desktop"
      ];
      "application/vnd.ms-excel" = [ "calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
        "impress.desktop"
      ];
      "application/rtf" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
      "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
      "application/vnd.oasis.opendocument.formula" = [ "math.desktop" ];
      "application/vnd.oasis.opendocument.base" = [ "base.desktop" ];
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

        # Office Documents
        "application/msword" = [ "writer.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "writer.desktop"
        ];
        "application/vnd.ms-excel" = [ "calc.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
        "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
          "impress.desktop"
        ];
        "application/rtf" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
        "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
        "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
        "application/vnd.oasis.opendocument.formula" = [ "math.desktop" ];
        "application/vnd.oasis.opendocument.base" = [ "base.desktop" ];
      };

      removed = {
        "application/pdf" = [ "calibre-ebook-viewer.desktop" ];
      };
    };
  };
}
