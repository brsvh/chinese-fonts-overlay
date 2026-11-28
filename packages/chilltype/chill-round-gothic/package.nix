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

  pname = "chill-round-gothic";
  version = "3.750";

  src = fetchurl {
    hash = "sha256-QaGdmY1ZlI5QRSeL7CJLDlQbiKtKBUvrWzul/htjmRc=";
    url = "https://github.com/Warren2060/ChillRoundGothic/releases/download/v${version}/ChillRoundGothic.v3.75.zip";
  };

  meta = {
    description = "Chill Round Gothic rounded Chinese sans-serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillRoundGothic"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Round Gothic from ChillType, a rounded Chinese
      sans-serif family derived from Source Han Sans SC. Includes seven
      OpenType weights from ExtraLight to Heavy.
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
    find . -type f -name 'License.txt' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 {} "$docDir/LICENSE.txt" \;

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉圆黑体";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bg"
        "bi"
        "bin"
        "br"
        "ch"
        "cmn"
        "da"
        "de"
        "en"
        "es"
        "eu"
        "fil"
        "fj"
        "fo"
        "fur"
        "fy"
        "gd"
        "gl"
        "gn"
        "gv"
        "hak"
        "haw"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "ig"
        "io"
        "is"
        "it"
        "ki"
        "kj"
        "kum"
        "kwm"
        "lb"
        "li"
        "lij"
        "lzh"
        "mg"
        "mhr"
        "miq"
        "mjw"
        "ms"
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
        "sm"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "to"
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
        "hei"
        "rounded"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
