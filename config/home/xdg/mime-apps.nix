{
  pkgs,
  config,
  lib,
  ...
}:

{
  # Ensure required packages are installed
  home.packages = with pkgs; [
    yazi # Terminal file manager (even though also in programs.yazi)
    papers # PDF viewer
    nomacs # Image viewer
    kdePackages.okular # Alternative PDF viewer
    evince # Another PDF viewer
    mupdf # Lightweight PDF viewer
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # File management - explicit package reference
      "inode/directory" = [ "yazi.desktop" ];
      "application/x-directory" = [ "yazi.desktop" ];

      # Documents - PDF
      "application/pdf" = [
        "org.gnome.Papers.desktop"
        "org.kde.okular.desktop"
        "$org.gnome.Evince.desktop"
      ];

      # Images
      "image/png" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/jpeg" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/gif" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/webp" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/bmp" = [ "org.nomacs.ImageLounge.desktop" ];
      "image/svg+xml" = [ "org.nomacs.ImageLounge.desktop" ];

      # Add more MIME types as needed
    };

    associations.removed = {
      "application/pdf" = [ "calibre-ebook-viewer.desktop" ];
    };
  };
}
