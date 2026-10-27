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

  pname = "jikasei-genshin-gothic";
  version = "1.002.20150607";

  regularSrc = fetchurl {
    hash = "sha256-uOAPAKbiUXv+dc6ypzK1lv4AJFe4nAXBgda3E3Oq2lg=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8637/genshingothic-20150607.zip";
  };

  meta = {
    description = "Gen Shin Gothic Japanese fonts";
    homepage = "http://jikasei.me/font/genshin/";
    license = licenses.ofl;

    longDescription = ''
      Provides Gen Shin Gothic, a Japanese sans-serif family derived from
      Source Han Sans with some glyphs from M+ outline fonts. Seven weights
      are available in standard, proportional, and monospaced forms, for
      21 fonts in one package. The family adjusts metrics and glyph forms
      for everyday document use.
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
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/jikasei
    mkdir -p $fontDir
    unzip -q ${regularSrc} -d normal
    install -m444 normal/*.ttf $fontDir/

    runHook postInstall
  '';
}
