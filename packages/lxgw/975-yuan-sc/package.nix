{
  fetchurl,
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

  pname = "lxgw-975-yuan-sc";
  version = "26.07.26";

  weight400Src = fetchurl {
    hash = "sha256-0U9aRToiFSXw20iHQScSy8A6hNDcRM4tItUdHBNu2aE=";
    url = "https://github.com/lxgw/975Yuan/releases/download/${version}/LXGW975YuanSC-400W.ttf";
  };

  weight500Src = fetchurl {
    hash = "sha256-8qtyTXmUl7nq/tUBUo+8Fbpph3abdnq0UO4o97gbtNg=";
    url = "https://github.com/lxgw/975Yuan/releases/download/${version}/LXGW975YuanSC-500W.ttf";
  };

  weight700Src = fetchurl {
    hash = "sha256-85LeTLqUHzxEx3cM/tesPGWLRrfjpLJUb+FVAQEJ1AM=";
    url = "https://github.com/lxgw/975Yuan/releases/download/${version}/LXGW975YuanSC-700W.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-6cTGJYKAfCUAYeB+3pn0wMfhp9U25iHsaNBJ8ffuDYE=";
    url = "https://raw.githubusercontent.com/lxgw/975Yuan/${version}/OFL.txt";
  };

  meta = {
    description = "LXGW 975 Yuan SC Chinese rounded fonts";
    homepage = "https://github.com/lxgw/975Yuan";
    license = licenses.ofl;

    longDescription = ''
      Provides LXGW 975 Yuan SC in three weights, a Simplified Chinese
      rounded family combining adjusted Chinese glyphs with Baloo 2
      Latin characters.
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
    version
    ;

  dontUnpack = true;

  srcs = [
    weight400Src
    weight500Src
    weight700Src
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${weight400Src} $fontDir/LXGW975YuanSC-400W.ttf
    install -Dm444 ${weight500Src} $fontDir/LXGW975YuanSC-500W.ttf
    install -Dm444 ${weight700Src} $fontDir/LXGW975YuanSC-700W.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "975 圆体 SC";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "ast"
        "ay"
        "ayc"
        "az-az"
        "bem"
        "bg"
        "bi"
        "bin"
        "br"
        "bs"
        "ca"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
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
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ig"
        "io"
        "is"
        "it"
        "ki"
        "kj"
        "kl"
        "ku-tr"
        "kum"
        "kw"
        "kwm"
        "la"
        "lb"
        "lg"
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
        "nv"
        "ny"
        "oc"
        "om"
        "os"
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "qu"
        "quz"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sc"
        "se"
        "sel"
        "sg"
        "sgs"
        "sk"
        "sl"
        "sm"
        "sma"
        "smj"
        "smn"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "szl"
        "tk"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "ty"
        "unm"
        "uz"
        "vi"
        "vo"
        "vot"
        "wa"
        "wae"
        "wen"
        "wo"
        "xh"
        "yap"
        "yo"
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

      vendor = "lxgw";
    };
  };
}
