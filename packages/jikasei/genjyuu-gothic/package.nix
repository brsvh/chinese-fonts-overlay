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

  pname = "jikasei-genjyuu-gothic";
  version = "1.002.20150607";

  regularSrc = fetchurl {
    hash = "sha256-kWu8I0sRCDW5pm6kf9YuVT/ZpSQiaxsf2sZmjw/JWAk=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8642/genjyuugothic-20150607.zip";
  };

  xSrc = fetchurl {
    hash = "sha256-5KDqEbgVUFatK2eMhQGy523Zm4yOtTY9OW/nwweSAbM=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8644/genjyuugothic-x-20150607.zip";
  };

  lSrc = fetchurl {
    hash = "sha256-0vzOwpAjLfEQ0RFv70QRQWh1rPdkcITJq31+teioDFA=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8643/genjyuugothic-l-20150607.zip";
  };

  meta = {
    description = "Gen Jyuu Gothic Japanese fonts";
    homepage = "http://jikasei.me/font/genjyuu/";
    license = licenses.ofl;

    longDescription = ''
      Provides Gen Jyuu Gothic, a rounded Japanese sans-serif family derived
      from Source Han Sans with some glyphs from M+ outline fonts. The
      standard, X, and L variants offer three degrees of rounding. Each
      includes seven weights in standard, proportional, and monospaced
      forms, for 63 fonts in one package.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    pname
    version
    ;

  dontUnpack = true;

  nativeBuildInputs = [ unzip ];

  srcs = [
    regularSrc
    xSrc
    lSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/jikasei
    mkdir -p $fontDir
    unzip -q ${regularSrc} -d normal
    install -m444 normal/*.ttf $fontDir/
    unzip -q ${xSrc} -d x
    install -m444 x/*.ttf $fontDir/
    unzip -q ${lSrc} -d l
    install -m444 l/*.ttf $fontDir/

    runHook postInstall
  '';
}
