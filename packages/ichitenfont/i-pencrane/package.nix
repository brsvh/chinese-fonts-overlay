{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    licenses
    maintainers
    platforms
    ;

  pname = "ichitenfont-i-pencrane";
  version = "1.004";

  # The original site is unavailable; this mirror preserves the release.
  src = fetchurl {
    hash = "sha256-d+9AMvbWN7ngdL0VPHmtmwhJGJxjlFE1vhxZ5U6iqBY=";
    name = "I.PenCrane-B-${version}.ttf";
    url = "https://raw.githubusercontent.com/plotdb/fontset-cjk/b8713058d6fc03ef521bd27ea87d468063e0d055/%E5%88%BB%E7%9F%B3%E9%8C%84/%E5%88%BB%E7%9F%B3%E9%8C%84%E9%8B%BC%E7%AD%86%E9%B6%B4%E9%AB%94.ttf";
  };

  meta = {
    description = "I.PenCrane-B Traditional Chinese pen handwriting font";
    homepage = "http://founder.acgvlyric.org/iu/doku.php/%E9%80%A0%E5%AD%97:%E9%96%8B%E6%BA%90%E5%AD%97%E5%9E%8B_i.%E9%8B%BC%E7%AD%86%E9%B6%B4%E9%AB%94";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides I.PenCrane-B, a Traditional Chinese pen handwriting font from
      Ichiten Fonts Project, derived from HanWang WCL07. It revises traditional
      glyph forms and adds characters used in Hong Kong, alongside updated
      Latin letters, numerals, and punctuation.
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

  srcs = [
    src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/ichitenfont
    install -Dm444 ${src} $fontDir/I.PenCrane-B.ttf

    runHook postInstall
  '';
}
