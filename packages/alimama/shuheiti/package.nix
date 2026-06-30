{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "1.005-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-+7S38cpfO2BDKlbDKdqY5ZY4hYZBPczN3ZdxejtDzOQ=";
    url = "https://fonts.alibabadesign.com/AlimamaShuHeiTi.zip";
  };

  meta = {
    description = "Alimama ShuHeiTi font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-shuheiti-license;

    longDescription = ''
      Provides the Alimama ShuHeiTi font family.

      Accept the Alimama ShuHeiTi 1.0 Legal Statement before use.
      After accepting it, do not redistribute the font files or
      publish them through a binary cache.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "alimama-shuheiti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/alimama \
      AlimamaShuHeiTi-Bold.otf

    runHook postInstall
  '';
}
