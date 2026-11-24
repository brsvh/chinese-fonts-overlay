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

    homepage = [
      "https://justfont.com/justforfun/abbrfesfont"
      "https://github.com/justfont/AbbrFesFont"
    ];

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

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "簡語生活體";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bi"
        "br"
        "bs"
        "ch"
        "cy"
        "eo"
        "es"
        "et"
        "eu"
        "fi"
        "fil"
        "fj"
        "fur"
        "gl"
        "ho"
        "hr"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "io"
        "it"
        "ki"
        "kj"
        "kw"
        "kwm"
        "la"
        "li"
        "mg"
        "ms"
        "na"
        "ng"
        "nhn"
        "nl"
        "nr"
        "nso"
        "ny"
        "om"
        "pap-an"
        "pap-aw"
        "rm"
        "rn"
        "rw"
        "sc"
        "sg"
        "sl"
        "sma"
        "smj"
        "sn"
        "ss"
        "st"
        "sv"
        "sw"
        "tn"
        "ts"
        "ty"
        "uz"
        "vo"
        "vot"
        "xh"
        "yap"
        "za"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "handwritten"
      ];

      vendor = "justfont";
    };
  };
}
