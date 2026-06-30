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

  version = "1.001-beta-unstable-2026-01-12";

  src = fetchurl {
    curlOptsList = [
      "--referer"
      "https://www.alibabafonts.com/"
      "--user-agent"
      "Mozilla/5.0"
    ];

    hash = "sha256-8ZEGYRev53A18Xm62VvYdfDgZXqSo/1f3tXOgHQkALQ=";
    url = "https://fonts.alibabadesign.com/AlimamaDaoLiTi.zip";
  };

  meta = {
    description = "Alimama DaoLiTi font family";
    homepage = "https://www.alibabafonts.com/#/more";
    license = licenses.alimama-daoliti-license;

    longDescription = ''
      Provides the Alimama DaoLiTi font family.

      Accept the Alimama DaoLiTi Legal Statement before use. After
      accepting it, do not redistribute the font files or publish
      them through a binary cache.
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

  pname = "alimama-daoliti";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/alimama \
      AlimamaDaoLiTi.ttf

    runHook postInstall
  '';
}
