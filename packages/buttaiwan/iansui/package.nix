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

  version = "1.020";

  src = fetchurl {
    hash = "sha256-KNWK75t6IcE3lFpP0UE41ihKhXPAwbEj9uW3CEIzSKY=";
    url = "https://github.com/ButTaiwan/iansui/releases/download/v${version}/iansui.zip";
  };

  meta = {
    description = "Iansui Traditional Chinese handwriting font";
    homepage = "https://github.com/ButTaiwan/iansui";
    license = licenses.ofl;

    longDescription = ''
      Provides Iansui, a Traditional Chinese handwriting TrueType
      font from ButTaiwan.
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

  pname = "buttaiwan-iansui";

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/truetype/buttaiwan \
      Iansui-Regular.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "芫荽";

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
        "da"
        "de"
        "en"
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
        "gv"
        "haw"
        "ho"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "ja"
        "ki"
        "kj"
        "kum"
        "kw"
        "kwm"
        "la"
        "lb"
        "li"
        "lij"
        "mfe"
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
        "nso"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pt"
        "qu"
        "quz"
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
        "tn"
        "to"
        "tpi"
        "ts"
        "ty"
        "unm"
        "uz"
        "vo"
        "vot"
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
        "handwritten"
        "kai"
      ];

      vendor = "buttaiwan";
    };
  };
}
