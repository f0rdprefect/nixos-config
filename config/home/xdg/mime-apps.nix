{ pkgs, config, lib, ... }:

{
  # Ensure required packages are installed
  home.packages = with pkgs; [
    yazi            # Terminal file manager (even though also in programs.yazi)
    papers          # PDF viewer
    nomacs          # Image viewer
    kdePackages.okular  # Alternative PDF viewer
    evince          # Another PDF viewer
    mupdf           # Lightweight PDF viewer
  ];
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # File management - explicit package reference
      "inode/directory" = [ "${pkgs.yazi}/share/applications/yazi.desktop" ];
      "application/x-directory" = [ "${pkgs.yazi}/share/applications/yazi.desktop" ];
      
      # Documents - PDF
      "application/pdf" = [ 
        "${pkgs.papers}/share/applications/org.gnome.Papers.desktop"
        "${pkgs.kdePackages.okular}/share/applications/org.kde.okular.desktop"
        "${pkgs.evince}/share/applications/org.gnome.Evince.desktop"
      ];
      
      # Images
      "image/png" = [ "${pkgs.nomacs}/share/applications/org.nomacs.ImageLounge.desktop" ];
      "image/jpeg" = [ "${pkgs.nomacs}/share/applications/org.nomacs.ImageLounge.desktop" ];
      "image/gif" = [ "${pkgs.nomacs}/share/applications/org.nomacs.ImageLounge.desktop" ];
      "image/webp" = [ "${pkgs.nomacs}/share/applications/org.nomacs.ImageLounge.desktop" ];
      "image/bmp" = [ "${pkgs.nomacs}/share/applications/org.nomacs.ImageLounge.desktop" ];
      "image/svg+xml" = [ "${pkgs.nomacs}/share/applications/org.nomacs.ImageLounge.desktop" ];
      
      # Add more MIME types as needed
    };
    
    associations.removed = {
      "application/pdf" = [ "calibre-ebook-viewer.desktop" ];
    };
  };
}