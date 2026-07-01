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

  version = "1.0";

  src = fetchurl {
    hash = "sha256-qvuw1oOo/GgFu4c4iekCrVkOL1a/PwW/bjYvQOi1PlU=";
    url = "https://github.com/justfont/AbbrFesFont/releases/download/v${version}/AbbrFesFont.ttf";
  };

  meta = {
    description = "AbbrFesFont Traditional Chinese abbreviation font";
    homepage = "https://justfont.com/justforfun/abbrfesfont";
    license = licenses.ofl;

    longDescription = ''
      Provides AbbrFesFont, also named Jian Yu Sheng Huo Ti, a
      Traditional Chinese font from justfont. It is based on
      Chenyuluoyan and uses OpenType ligatures to replace selected
      phrases with shorter Taiwanese abbreviations.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "justfont-abbrfesfont";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/justfont
    install -Dm444 $src $fontDir/AbbrFesFont.ttf

    runHook postInstall
  '';
}
