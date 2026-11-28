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

  pname = "chill-din";
  version = "1.100";

  src = fetchurl {
    hash = "sha256-p5kDQAYZeY2gE+y/y/A7HVbDFqqfMLYZERin+QQP8kI=";
    url = "https://github.com/Warren2060/ChillDIN-ChillDINGothic/releases/download/ChillDIN_v${version}/ChillDIN.v${version}.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-HDZSnA0M7eCRgM0a8+CgC8kTstwXKfcmhLjFq6dqPwc=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillDIN-ChillDINGothic/d5251e66ded29639397025784c72dc2ac12bc817/license";
  };

  meta = {
    description = "ChillDIN static Latin industrial sans-serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillDIN-ChillDINGothic"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides ChillDIN static OpenType fonts from ChillType, a refined
      Latin DIN industrial sans-serif family based on D-DIN. Includes eight
      Regular to Bold and Condensed weights.
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
      displayName = "ChillDIN";

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
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
