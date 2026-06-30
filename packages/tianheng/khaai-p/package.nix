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
    hash = "sha256-ijfTLLWVlRNlHdRCvKa/bNRmn0ecoiLojHKiBmgnIS8=";
    url = "http://cheonhyeong.com/File/TH-Khaai-P${version}.7z";
  };

  meta = {
    description = "TH-Khaai-P Biaokai font from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Khaai-P Biaokai font.

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

  pname = "tianheng-khaai-p";

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
      TH-Khaai-PP0.ttf \
      TH-Khaai-PP2.ttf

    runHook postInstall
  '';
}
