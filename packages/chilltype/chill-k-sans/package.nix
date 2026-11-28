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

  pname = "chill-k-sans";
  version = "2.002";

  src = fetchurl {
    hash = "sha256-d7AJORl/cRTJqGZLIxkfgl4Lv/XiRCLfOs5S2vVecB4=";
    url = "https://github.com/Warren2060/ChillKSans/releases/download/v${version}/Chill-K-Sans.otf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-uz7/pD7M7IHSK+WTE3oM6PvT+IZpF9Buob1/V+aGddo=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillKSans/29563b97ee95d8ea5119f18324638eb96cd14e5b/license";
  };

  meta = {
    description = "Chill K Sans wide Chinese sans-serif font with clerical-script flavor";

    homepage = [
      "https://github.com/Warren2060/ChillKSans"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chill K Sans from ChillType, a wide Chinese sans-serif
      display font derived from Glow Sans with subtle clerical-script stroke
      details and paired with Montserrat Latin glyphs.
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

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/chilltype
    docDir=$out/share/doc/${pname}
    install -Dm444 "$src" "$fontDir/Chill-K-Sans.otf"
    install -Dm444 ${licenseSrc} "$docDir/LICENSE"

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉宽黑体";

      languages = [
        "aa"
        "ab"
        "af"
        "agr"
        "an"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "ba"
        "be"
        "bem"
        "bg"
        "bi"
        "bin"
        "br"
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "chm"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
        "cv"
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
        "hak"
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
        "ik"
        "io"
        "is"
        "it"
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
        "ku-am"
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
        "lt"
        "lv"
        "lzh"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "miq"
        "mjw"
        "mk"
        "mn-mn"
        "mo"
        "ms"
        "mt"
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
        "sah"
        "sc"
        "se"
        "sel"
        "sg"
        "sgs"
        "sh"
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
        "tg"
        "tk"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "tt"
        "ty"
        "tyv"
        "uk"
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
