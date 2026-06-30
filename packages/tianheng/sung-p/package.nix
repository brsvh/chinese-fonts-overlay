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

  version = "4.0.0";

  src = fetchurl {
    hash = "sha256-UuAgX7xIRW340VSBYlpswZIw7qCoeo8HGk9tNHSpoIs=";
    url = "http://cheonhyeong.com/File/TH-Sung-P${version}.7z";
  };

  meta = {
    description = "TH-Sung-P Biaosong font from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Sung-P Biaosong font.

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

  pname = "tianheng-sung-p";

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
      TH-Sung-PP0.ttc \
      TH-Sung-PP2.ttc

    runHook postInstall
  '';
}
