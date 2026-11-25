{
  coreutils,
  fontconfig,
  freetype,
  guile,
  guile-json,
  lib,
  nix,
  pkg-config,
  stdenv,
  writeShellApplication,
}:
let
  inherit (lib)
    getExe
    ;

  scanFont = stdenv.mkDerivation {
    name = "chinese-fonts-overlay-scan-font";

    buildInputs = [
      fontconfig
      freetype
    ];

    buildPhase = ''
      runHook preBuild

      # shellcheck disable=SC2046,SC2086
      "$CC" $CPPFLAGS $CFLAGS -O2 -Wall -Wextra \
        $(pkg-config --cflags fontconfig freetype2) \
        ${./scan-font.c} \
        $LDFLAGS \
        $(pkg-config --libs fontconfig freetype2) \
        -o chinese-fonts-overlay-scan-font

      runHook postBuild
    '';

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 chinese-fonts-overlay-scan-font \
        "$out/bin/chinese-fonts-overlay-scan-font"

      runHook postInstall
    '';

    meta = {
      mainProgram = "chinese-fonts-overlay-scan-font";
    };

    nativeBuildInputs = [
      pkg-config
    ];
  };
in
writeShellApplication {
  meta = {
    mainProgram = "chinese-fonts-overlay-update-font-languages";
  };

  name = "chinese-fonts-overlay-update-font-languages";

  runtimeInputs = [
    coreutils
    nix
    scanFont
  ];

  text = ''
    exec ${getExe guile} --no-auto-compile \
      -L '${guile-json}/share/guile/site/3.0' \
      -e main -s '${./main.scm}' "$@"
  '';
}
