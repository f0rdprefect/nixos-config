{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  libayatana-appindicator,
  libsoup_3,
  webkitgtk_4_1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mouzi";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/hsr88/mouzi/releases/download/v${finalAttrs.version}/Mouzi_${finalAttrs.version}_amd64.deb";
    sha256 = "ae47db65e7b10731a5bc0ebd97267589d131d939caa088a5c754a33838fa9394";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];

  # Tray icon support is dlopen'ed at runtime, so it needs an explicit rpath entry.
  runtimeDependencies = [ libayatana-appindicator ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/mouzi -t $out/bin
    install -Dm644 usr/share/applications/Mouzi.desktop -t $out/share/applications

    for size in 32x32 128x128; do
      install -Dm644 "usr/share/icons/hicolor/$size/apps/mouzi.png" \
        "$out/share/icons/hicolor/$size/apps/mouzi.png"
    done
    # The deb ships its 256px icon in a bogus "256x256@2" directory.
    install -Dm644 usr/share/icons/hicolor/256x256@2/apps/mouzi.png \
      $out/share/icons/hicolor/256x256/apps/mouzi.png

    runHook postInstall
  '';

  meta = {
    description = "Privacy-first automatic file organizer that sorts your Downloads folder from the system tray";
    homepage = "https://github.com/hsr88/mouzi";
    changelog = "https://github.com/hsr88/mouzi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "mouzi";
  };
})
