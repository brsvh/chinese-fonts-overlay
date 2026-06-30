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
    hash = "sha256-cqYgRfj3busbxVuQbKYdD+jcx3mDkfUrtFgQDpEdazM=";
    url = "http://cheonhyeong.com/File/TH-Tshyn-${version}.7z";
  };

  meta = {
    description = "TH-Tshyn full font collection from TianHeng fonts";
    homepage = "http://cheonhyeong.com";
    license = licenses.tianheng-font-license;

    longDescription = ''
      Provides the TH-Tshyn full font collection.

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

  pname = "tianheng-tshyn";

  nativeBuildInputs = [
    p7zip
  ];

  unpackPhase = ''
    runHook preUnpack

    7z e $src -y \
      TH-Times.ttc \
      TH-Tshyn-P0.ttf \
      TH-Tshyn-P1.ttf \
      TH-Tshyn-P2.ttf \
      TH-Tshyn-P16.ttf

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/tianheng \
      TH-Times.ttc \
      TH-Tshyn-P0.ttf \
      TH-Tshyn-P1.ttf \
      TH-Tshyn-P2.ttf \
      TH-Tshyn-P16.ttf

    runHook postInstall
  '';
}
