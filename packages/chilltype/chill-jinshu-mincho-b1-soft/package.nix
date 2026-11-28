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

  pname = "chill-jinshu-mincho-b1-soft";
  version = "1.500";

  src = fetchurl {
    hash = "sha256-RYQ4cw44WU4ELKYuBFLH5X52cFzxsJh4amrgRrzwbwE=";
    url = "https://github.com/Warren2060/ChillJinshuSong/releases/download/Bv${version}/ChillJinshuMinchoB1Soft.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-An9vaKo8ZRp3HTNo59FiCsrq39XQDSPaRDMlZbwVGGk=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillJinshuSong/58b387e4a2c49c38c9113bbccdc64d2486e45829/LICENSE";
  };

  meta = {
    description = "Chill Jinshu Mincho B1 Soft rounded serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillJinshuSong"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Jinshu Mincho B1 Soft from ChillType, a softer rounded
      variant of Chill Jinshu Mincho B1. Includes seven OpenType weights from
      Light to Heavy.
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
      displayName = "寒蝉锦书明朝 B1 Soft";

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
        "ho"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ig"
        "io"
        "is"
        "it"
        "ja"
        "ki"
        "kj"
        "kum"
        "kwm"
        "la"
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
        "serif"
        "song"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
