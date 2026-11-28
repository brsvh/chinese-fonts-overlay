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

  pname = "chill-inorganic";
  version = "1.00";

  src = fetchurl {
    hash = "sha256-O7qK4Jwp9TIjnVxjjz8YNfokMDaI6/QBz72zxLjbwxQ=";
    url = "https://github.com/Warren2060/ChillTanHei/releases/download/v${version}/ChillTanHei_v${version}.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-PoxgAgasqE/C2bjeE7pSoRr63+TXBeOdpgjTZRhy7Ls=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillTanHei/bcbebe45fb65b31a47629b4cb1fe7b633036e3c9/License";
  };

  meta = {
    description = "Chill Inorganic reverse-contrast display Chinese sans-serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillTanHei"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Inorganic from the ChillType ChillTanHei series, an
      experimental reverse-contrast display Chinese typeface. Includes six
      OpenType styles spanning Regular, Medium, Compact, and Wide variants.
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
    find . -type f -name 'ChillInorganic_*.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉无机体";

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
        "art"
        "hei"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
