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

  pname = "chill-round-m";
  version = "1.805";

  src = fetchurl {
    hash = "sha256-GXAY/c5UNvyZ2IdNMsW0cCssxZUAbS00H7NUK2tXeb0=";
    url = "https://github.com/Warren2060/ChillRound/releases/download/v${version}/ChillRoundM_v${version}.zip";
  };

  meta = {
    description = "Chill Round M semi-rounded Chinese font";

    homepage = [
      "https://github.com/Warren2060/ChillRound"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Round M from ChillType, a semi-rounded Chinese typeface
      derived from Zen Maru Gothic and expanded to cover GB2312 and common
      Simplified and Traditional Chinese characters.
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
      displayName = "寒蝉半圆体";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bg"
        "bi"
        "br"
        "ch"
        "co"
        "cy"
        "da"
        "de"
        "el"
        "en"
        "es"
        "eu"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "gd"
        "gl"
        "gv"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "kum"
        "kwm"
        "lb"
        "li"
        "lij"
        "mfe"
        "mg"
        "mhr"
        "mjw"
        "ms"
        "nb"
        "nds"
        "ng"
        "nl"
        "nn"
        "no"
        "nr"
        "ny"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pt"
        "rm"
        "rn"
        "ru"
        "rw"
        "sc"
        "sel"
        "sg"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "wa"
        "wae"
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
        "rounded"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
