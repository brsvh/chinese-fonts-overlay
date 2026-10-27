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

  pname = "ichitenfont-i-ngaan";
  version = "1.004";

  # The original site is unavailable; this mirror preserves the release.
  src = fetchurl {
    hash = "sha256-erqPW7d+p+D8N8Dl5wm9jh1JtEo8ketQP0JlYmAvnCo=";
    name = "I.Ngaan-${version}.ttf";
    url = "https://raw.githubusercontent.com/plotdb/fontset-cjk/b8713058d6fc03ef521bd27ea87d468063e0d055/%E5%88%BB%E7%9F%B3%E9%8C%84/%E5%88%BB%E7%9F%B3%E9%8C%84%E9%A1%8F%E9%AB%94.ttf";
  };

  meta = {
    description = "I.Ngaan Traditional Chinese brush calligraphy font";
    homepage = "http://founder.acgvlyric.org/iu/doku.php/%E9%80%A0%E5%AD%97:%E9%96%8B%E6%BA%90%E5%AD%97%E5%9E%8B_i.%E9%A1%8F%E9%AB%94";
    license = licenses.gpl2Plus;

    longDescription = ''
      Provides I.Ngaan, a Traditional Chinese brush calligraphy font from
      Ichiten Fonts Project, derived from HanWang Yen. It revises traditional
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
    install -Dm444 ${src} $fontDir/I.Ngaan.ttf

    runHook postInstall
  '';
}
