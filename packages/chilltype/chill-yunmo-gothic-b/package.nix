{
  fetchFromGitHub,
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

  pname = "chill-yunmo-gothic-b";
  version = "0-unstable-2023-09-15";

  src = fetchFromGitHub {
    hash = "sha256-B8su/s9cUL+YF9Ye/7BYJcJeTzt45e4klMROUikrjFM=";
    owner = "Warren2060";
    repo = "ChillYunmoGothic";
    rev = "ff148aa15663dcfc52f91724cc1017d95a6da45d";
  };

  meta = {
    description = "Chill Yunmo Gothic B rounded Chinese sans-serif fonts";

    homepage = [
      "https://github.com/Warren2060/ChillYunmoGothic"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Yunmo Gothic B and BS Medium OpenType variants from
      ChillType.
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
    tmpDir=$(mktemp -d)
    for archive in ./*/*.otf.zip; do
      unzip -q "$archive" -d "$tmpDir"
    done
    find "$tmpDir" -type f -name '*.otf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    install -Dm444 LICENSE "$docDir/LICENSE"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉云墨黑 B";

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
