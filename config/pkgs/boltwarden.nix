{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  fontconfig,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  libxcb,
  wayland,
}:
let
  runtimeLibs = [
    fontconfig
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    libxcb
    wayland
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "boltwarden";
  version = "1.0.0-rc.7";

  src = fetchurl {
    url = "https://github.com/vleeuwenmenno/boltwarden/releases/download/v${finalAttrs.version}/boltwarden-${finalAttrs.version}-x86_64-linux.tar.gz";
    sha256 = "de50b117f746c270f810fbd4ed91bde42801162c253b08a7434d57fd24f1d389";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [ stdenv.cc.cc.lib ] ++ runtimeLibs;

  desktopItems = [
    (makeDesktopItem {
      name = "boltwarden-daemon";
      desktopName = "Boltwarden Daemon";
      genericName = "Password Manager Daemon";
      comment = "Start the Boltwarden background daemon";
      exec = "boltwarden --daemon";
      icon = "dialog-password";
      terminal = false;
      categories = [ "Utility" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 boltwarden -t $out/bin
    install -Dm644 LICENSE THIRD_PARTY_NOTICES.txt -t $out/share/doc/boltwarden

    wrapProgram $out/bin/boltwarden \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}

    runHook postInstall
  '';

  meta = {
    description = "Linux quick-access GUI for Bitwarden and Vaultwarden vaults";
    homepage = "https://github.com/vleeuwenmenno/boltwarden";
    changelog = "https://github.com/vleeuwenmenno/boltwarden/releases/tag/v${finalAttrs.version}";
    license = {
      fullName = "MIT License with Commons Clause License Condition v1.0";
      url = "https://github.com/vleeuwenmenno/boltwarden/blob/v${finalAttrs.version}/LICENSE";
      free = false;
    };
    platforms = [ "x86_64-linux" ];
    mainProgram = "boltwarden";
  };
})
