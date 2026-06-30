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
    hash = "sha256-33SRtSmE90RCmxyTOsZL0hchFtwoUWj4YUn5s6vd75w=";
    url = "http://cheonhyeong.com/File/TH-Khaai-T${version}.7z";
  };

  meta = {
    description = "TH-Khaai-T Kaiti font from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Khaai-T Kaiti font.

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

  pname = "tianheng-khaai-t";

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
      TH-Khaai-TP0.ttf \
      TH-Khaai-TP2.ttf \
      TH-Khaai-TP16.ttf

    runHook postInstall
  '';
}
