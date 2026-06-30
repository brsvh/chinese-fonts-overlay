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
    hash = "sha256-vcuTCBLy+8tYNylUlnvpfs1jWa1QlwLQV/FQvX7qqvo=";
    url = "http://cheonhyeong.com/File/TH-Sy-${version}.7z";
  };

  meta = {
    description = "TH-Sy Shusong font from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Sy Shusong font.

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

  pname = "tianheng-sy";

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
      TH-Sy-P0.ttf \
      TH-Sy-P2.ttf \
      TH-Sy-P16.ttf

    runHook postInstall
  '';
}
