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

  version = "2.100";

  src = fetchurl {
    hash = "sha256-3cMksvP4BONrYISy53OQCo90RVwfv6HzjQgjRPSrMmQ=";
    url = "https://github.com/ButTaiwan/genwan-font/releases/download/v${version}/GenWanMin2TW-otf.zip";
  };

  meta = {
    description = "GenWanMin2 TW Traditional Chinese Mincho font family";
    homepage = "https://github.com/ButTaiwan/genwan-font";
    license = licenses.ofl;

    longDescription = ''
      Provides GenWanMin2 TW, the Traditional Chinese modern Mincho
      variant of ButTaiwan's GenWanMin2 Source Han Serif derivative,
      in ExtraLight, Light, Regular, Medium, and SemiBold weights.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "buttaiwan-genwanmin2-tw";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype/buttaiwan \
      GenWanMin2TW-EL.otf \
      GenWanMin2TW-L.otf \
      GenWanMin2TW-R.otf \
      GenWanMin2TW-M.otf \
      GenWanMin2TW-SB.otf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "源雲明體月";

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
        "yue"
        "yuw"
        "za"
        "zh-hk"
        "zh-mo"
        "zh-sg"
        "zh-tw"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "serif"
        "song"
      ];

      vendor = "buttaiwan";
    };
  };
}
