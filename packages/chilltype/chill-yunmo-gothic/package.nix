{
  fetchFromGitHub,
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

  pname = "chill-yunmo-gothic";
  version = "0-unstable-2023-09-15";

  src = fetchFromGitHub {
    hash = "sha256-B8su/s9cUL+YF9Ye/7BYJcJeTzt45e4klMROUikrjFM=";
    owner = "Warren2060";
    repo = "ChillYunmoGothic";
    rev = "ff148aa15663dcfc52f91724cc1017d95a6da45d";
  };

  meta = {
    description = "Chill Yunmo Gothic rounded Chinese sans-serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillYunmoGothic"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Yunmo Gothic from ChillType, a rounded Chinese
      sans-serif family derived from Source Han Sans SC with reworked weight
      progression and typography refinements. Includes ten OpenType styles
      across Light to Heavy, Compact, and Wide variants.
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
    find . -type f -name '*.otf' \
      -exec install -Dm444 -t "$fontDir" {} +
    install -Dm444 LICENSE "$docDir/LICENSE"

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉云墨黑";

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
        "sans"
      ];

      vendor = "chilltype";
    };
  };
}
