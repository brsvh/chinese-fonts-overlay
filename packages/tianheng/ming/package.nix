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

  version = "5.0.0";

  src = fetchurl {
    hash = "sha256-cGX7yIjZIaf4ivIGFweyrEtXpvCyjoM0NM9ra9RY6N0=";
    url = "http://cheonhyeong.com/File/TH-Ming-${version}.7z";
  };

  meta = {
    description = "TH-Ming Hanazono Mingcho font from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Ming Hanazono Mingcho font.

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

  pname = "tianheng-ming";

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
      TH-Ming-P0.ttc \
      TH-Ming-P2.ttc

    runHook postInstall
  '';
}
