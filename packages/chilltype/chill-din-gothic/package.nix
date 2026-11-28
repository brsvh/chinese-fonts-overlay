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

  pname = "chill-din-gothic";
  version = "1.300";

  src = fetchurl {
    hash = "sha256-K+ok9utLs8zOUW0XBPIiWlBLtf/61s7igmnMmWS6C4Q=";
    url = "https://github.com/Warren2060/ChillDIN-ChillDINGothic/releases/download/ChillDINGothic_v${version}/ChillDINGothic.v${version}.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-HDZSnA0M7eCRgM0a8+CgC8kTstwXKfcmhLjFq6dqPwc=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillDIN-ChillDINGothic/d5251e66ded29639397025784c72dc2ac12bc817/license";
  };

  meta = {
    description = "Chill DIN Gothic static Chinese sans-serif fonts paired with ChillDIN";

    homepage = [
      "https://github.com/Warren2060/ChillDIN-ChillDINGothic"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill DIN Gothic static OpenType fonts from ChillType,
      combining ChillDIN Latin glyphs with Chinese glyphs adapted from
      Chill Duan Sans and Source Han Sans. Includes Regular to Bold,
      Condensed, and Std OpenType styles.
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

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/chilltype
    docDir=$out/share/doc/${pname}
    find . -type f -name '*.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉德黑体";

      languages = [
        "aa"
        "agr"
        "an"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "be"
        "bem"
        "bg"
        "bi"
        "bin"
        "br"
        "bs"
        "ce"
        "ch"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "fi"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "gd"
        "gl"
        "gn"
        "gv"
        "hak"
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ig"
        "ik"
        "io"
        "is"
        "it"
        "ki"
        "kj"
        "ku-tr"
        "kum"
        "kw"
        "kwm"
        "la"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "lzh"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mi"
        "miq"
        "mjw"
        "mk"
        "mn-mn"
        "mo"
        "ms"
        "mt"
        "na"
        "nan"
        "nb"
        "nds"
        "ng"
        "nhn"
        "niu"
        "nl"
        "nn"
        "no"
        "nr"
        "nso"
        "nv"
        "ny"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sc"
        "se"
        "sel"
        "sg"
        "sgs"
        "sk"
        "sl"
        "sm"
        "sma"
        "smj"
        "smn"
        "sn"
        "sq"
        "sr"
        "ss"
        "st"
        "sv"
        "sw"
        "szl"
        "tk"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "ty"
        "uk"
        "unm"
        "uz"
        "ve"
        "vi"
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "wo"
        "xh"
        "yap"
        "yo"
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "hei"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
