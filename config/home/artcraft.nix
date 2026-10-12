{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cadcraft
    deckcraft
    designcraft
    effectcraft
    filmcraft
    gridcraft
    lightcraft
    pdfcraft
    photocraft
    soundcraft
    vectorcraft
    wordcraft
  ];
}
