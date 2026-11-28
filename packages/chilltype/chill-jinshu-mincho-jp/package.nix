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

  pname = "chill-jinshu-mincho-jp";
  version = "1.0";

  src = fetchurl {
    hash = "sha256-ivrSL/+WwprAn3FncR1aUBtaXMJVCBXFO1s0/1K+knA=";
    url = "https://github.com/Warren2060/ChillJinshuSong/releases/download/v2023.9.7/ChillJinshuMinchoJP_v${version}.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-An9vaKo8ZRp3HTNo59FiCsrq39XQDSPaRDMlZbwVGGk=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillJinshuSong/58b387e4a2c49c38c9113bbccdc64d2486e45829/LICENSE";
  };

  meta = {
    description = "Chill Jinshu Mincho JP Japanese rounded serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillJinshuSong"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Jinshu Mincho JP from ChillType, the Japanese edition of
      the Chill Jinshu rounded serif family. Includes twelve OpenType styles
      spanning Light to Heavy, Text, Compact, and Wide variants.
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
      displayName = "寒蝉锦书明朝 JP";

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
        "mg"
        "mhr"
        "miq"
        "mjw"
        "ms"
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
        "serif"
        "song"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
