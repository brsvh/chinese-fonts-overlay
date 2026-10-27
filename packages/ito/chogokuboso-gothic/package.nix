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

  pname = "ito-chogokuboso-gothic";
  version = "1.00";

  src = fetchurl {
    hash = "sha256-VY4LZtzDB5X8e5h/50BzWKyXrLTsqG0ln7m864EKS0I=";
    url = "https://font.websozai.jp/fontdata-8/chogokubosogothic.zip";
  };

  meta = {
    description = "Chogokuboso Gothic extra-light Japanese font";
    homepage = "https://font.websozai.jp/line-font-mihon.html";
    license = licenses.mplus;

    longDescription = ''
      Provides Chogokuboso Gothic, an extra-light Japanese sans-serif font
      from Ito Font based on M+ outline fonts. Its fine strokes are intended
      for display text, logos, and headings, with Japanese kana, kanji,
      Latin letters, numerals, and punctuation in a single regular style.
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
    src
    version
    ;

  nativeBuildInputs = [ unzip ];

  sourceRoot = "chogokubosogothic";

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/ito
    install -Dm444 chogokubosogothic_5.ttf $fontDir/ChogokubosoGothic.ttf

    runHook postInstall
  '';
}
