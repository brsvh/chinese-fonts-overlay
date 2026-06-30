{
  fetchurl,
  lib,
  p7zip,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  version = "4.1.0";

  src = fetchurl {
    hash = "sha256-Erp4sv25qqnXBR4VGCcKTHOqZmx5P+xlCMkROlSo/mE=";
    url = "http://cheonhyeong.com/File/TH-Sung-T${version}.7z";
  };

  meta = {
    description = "TH-Sung-T Songti font from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Sung-T Songti font.

      This package treats the fonts as non-redistributable because
      the glyph copyright status is unclear. Do not redistribute the
      font files or publish them through a binary cache.
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

  pname = "tianheng-sung-t";

  nativeBuildInputs = [
    p7zip
  ];

  unpackPhase = ''
    runHook preUnpack

    7z x $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/tianheng \
      TH-Sung-TP0.ttf \
      TH-Sung-TP2.ttf

    runHook postInstall
  '';
}
