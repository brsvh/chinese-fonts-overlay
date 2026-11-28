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

  pname = "chill-reunion";
  version = "2.700";

  src = fetchurl {
    hash = "sha256-A4Hhq5awfJwyIUsFLrAMVfCAXXHAhgeqUTNqdODsuFY=";
    url = "https://github.com/Warren2060/ChillReunion/releases/download/v${version}/ChillReunion_v2.7.zip";
  };

  meta = {
    description = "Chill Reunion oblique display Chinese fonts derived from Smiley Sans";

    homepage = [
      "https://github.com/Warren2060/ChillReunion"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Reunion from ChillType, a 3-degree oblique display
      Chinese typeface derived from Smiley Sans with added characters and
      vertical layout refinements. Includes Round and Sans OpenType styles.
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
    find . -type f -name 'LICENSE.txt' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 {} "$docDir/LICENSE.txt" \;

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉团圆体";

      languages = [
        "aa"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "az-az"
        "be"
        "bem"
        "bg"
        "bi"
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
        "el"
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
        "kwm"
        "lb"
        "lez"
        "li"
        "lij"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "miq"
        "mjw"
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
        "sel"
        "sg"
        "sk"
        "sl"
        "sma"
        "smj"
        "sn"
        "sq"
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
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "xh"
        "yap"
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "art"
        "hei"
        "rounded"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
