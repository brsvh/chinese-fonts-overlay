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

  pname = "lxgw-xiaolai";
  version = "3.126";

  regularSrc = fetchurl {
    hash = "sha256-4vaNrw5yd3qM9YvIPeG5hjSyUeU33b/KJLCuUNGALaI=";
    url = "https://github.com/lxgw/kose-font/releases/download/v${version}/Xiaolai-Regular.ttf";
  };

  monoSrc = fetchurl {
    hash = "sha256-gCtljbSS4Crltln1tW19Tvj3dglRW9zIL0Yq6RKIjDM=";
    url = "https://github.com/lxgw/kose-font/releases/download/v${version}/XiaolaiMono-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-Dffgm+TCyFCki9i+uc1ks0Oq1JzV0/bPsq0uPSilbKQ=";
    url = "https://raw.githubusercontent.com/lxgw/kose-font/v${version}/OFL.txt";
  };

  meta = {
    description = "Xiaolai Chinese handwriting fonts";
    homepage = "https://github.com/lxgw/kose-font";
    license = licenses.ofl;

    longDescription = ''
      Provides Xiaolai and Xiaolai Mono, Chinese handwriting fonts
      derived from SetoFont with additional Simplified Chinese
      characters. The regular variant uses proportional Latin glyphs,
      while Mono provides a monospaced alternative.
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
    regularSrc
    monoSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${regularSrc} $fontDir/Xiaolai-Regular.ttf
    install -Dm444 ${monoSrc} $fontDir/XiaolaiMono-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "小赖字体";

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
        "chm"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
        "cu"
        "cv"
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
        "kab"
        "ki"
        "kj"
        "kk"
        "kl"
        "kr"
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
        "ln"
        "lt"
        "lv"
        "lzh"
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
        "rif"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sah"
        "sc"
        "sco"
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
        "handwritten"
      ];

      vendor = "lxgw";
    };
  };
}
