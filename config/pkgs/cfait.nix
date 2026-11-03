{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wayland,
  libxkbcommon,
  vulkan-loader,
  libGL,
  fontconfig,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cfait";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/trougnouf/cfait/releases/download/v${finalAttrs.version}/cfait-linux-v${finalAttrs.version}.tar.gz";
    sha256 = "019b8f46a061c2e040e2ffcc1eb2356a80c3e1219a312756677abdce5303dacd";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    wayland
    libxkbcommon
    vulkan-loader
    libGL
    fontconfig
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 cfait cfait-gui -t $out/bin
    install -Dm644 cfait.desktop -t $out/share/applications
    install -Dm644 cfait.svg -t $out/share/icons/hicolor/scalable/apps

    wrapProgram $out/bin/cfait-gui \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
          vulkan-loader
          libGL
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Fast, offline-first CalDAV and local task manager";
    homepage = "https://git.disroot.org/trougnouf/cfait";
    changelog = "https://git.disroot.org/trougnouf/cfait/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cfait";
  };
})
