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

  pname = "chill-huo-fang-kai";
  version = "1.00";

  src = fetchurl {
    hash = "sha256-k5Qox4L3Z9rVXaIgyv613VrAYcfgzVr6yO4U2Sspgno=";
    url = "https://github.com/Warren2060/ChillMovableType/releases/download/HuoFangKaiv${version}/ChillHuoFangKai_F.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-x8ZpEx6CC0vW2ZFaS1bJVna8/43d7zcW4ijvBiVObT8=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillMovableType/d0a36cfb5912e891c0492d3ff5c04584e05b9409/LICENSE";
  };

  meta = {
    description = "Chill Huo FangKai movable-type letterpress Chinese Kai fonts";

    homepage = [
      "https://github.com/Warren2060/ChillMovableType"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill Huo FangKai from the ChillType ChillMovableType
      project, a letterpress-textured Chinese Kai family derived from LXGW
      WenKai TC. Includes three OpenType styles: Regular, ConRegular, and
      ConBold.
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
      displayName = "寒蝉活仿楷";

      languages = [
        "aa"
        "af"
        "agr"
        "ak"
        "an"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "be"
        "bem"
        "ber-dz"
        "bg"
        "bi"
        "bin"
        "bm"
        "br"
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
        "ee"
        "el"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "fat"
        "ff"
        "fi"
        "fil"
        "fj"
        "fo"
        "fr"
        "fur"
        "fy"
        "ga"
        "gd"
        "gl"
        "gn"
        "gv"
        "ha"
        "haw"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "hz"
        "ia"
        "id"
        "ie"
        "ig"
        "ik"
        "io"
        "is"
        "it"
        "kaa"
        "kab"
        "ki"
        "kj"
        "kk"
        "kl"
        "kr"
        "ku-tr"
        "kum"
        "kv"
        "kw"
        "kwm"
        "ky"
        "la"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "ln"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mi"
        "miq"
        "mjw"
        "mk"
        "mn-mn"
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
        "rif"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sc"
        "sco"
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
        "sms"
        "sn"
        "sq"
        "sr"
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
        "tt"
        "tw"
        "ty"
        "tyv"
        "uk"
        "unm"
        "uz"
        "ve"
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
        "kai"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
