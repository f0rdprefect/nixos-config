# Font baseline shared by every desktop user.
#
# Deliberately takes only `pkgs` so this module can be imported standalone by
# hosts that do not get the full specialArgs set (see users/yilian/home.nix).
#
# home-manager has no `fonts.packages` option, so fonts land in `home.packages`.
# `fonts.fontconfig.enable` makes fontconfig scan the home profile, which is what
# actually registers them.
{ pkgs, ... }:

let
  # Nerd Fonts patch upstream families that baseFontPackages already ships.
  # Having both means two fonts claiming the same family name, and fontconfig
  # resolves that duplicate arbitrarily. Keep the plain one, drop the nerd one.
  nerdFontExclusions = [
    "adwaita-mono"
    "caskaydia-cove"
    "caskaydia-mono"
    "dejavu-sans-mono"
    "fantasque-sans-mono"
    "jetbrains-mono"
    "liberation"
    "noto"
    "sauce-code-pro"
  ];

  nerdFonts = builtins.removeAttrs (builtins.removeAttrs pkgs.nerd-fonts [
    "override"
    "overrideDerivation"
    "recurseForDerivations"
  ]) nerdFontExclusions;

  baseFontPackages = with pkgs; [
    # generic sans/serif/mono fallbacks for fontconfig, GTK, Qt and X11
    dejavu_fonts
    # metric-compatible with Arial, Times New Roman, Courier New, Calibri and
    # Cambria so office documents render the way they were authored
    liberation_ttf
    carlito
    caladea
    # pan-unicode workhorse: Latin, Greek, Cyrillic, Hebrew, Arabic, math
    noto-fonts
    # emoji, both the color and the monochrome variant
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    # icon fonts used by desktop shells and app toolbars
    font-awesome
    material-icons
    # UI text and coding
    source-sans-pro
    source-code-pro
    jetbrains-mono
    roboto
    # reading and document work: sans, serif and math faces for self-made
    # handouts and lecture material, picked per document in LibreOffice
    inter
    lato
    open-sans
    source-serif
    libertinus
    merriweather
    atkinson-hyperlegible
    stix-two
    # last-resort fallback so no glyph is ever a tofu box
    unifont
  ];
in
{
  fonts.fontconfig.enable = true;

  home.packages = baseFontPackages ++ builtins.attrValues nerdFonts;
}
