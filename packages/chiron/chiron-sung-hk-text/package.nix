{
  fetchurl,
  lib,
  stdenvNoCC,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    licenses
    maintainers
    mapAttrs
    mapAttrsToList
    platforms
    ;

  pname = "chiron-sung-hk-text";
  version = "1.024";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/chiron-sung-hk/v${version}";

  fontHashes = {
    "ChironSungHK-Text-B-It.otf" =
      "sha256-ygXxp3Dog/GIOf+O9tx69ZxDdmu9yEXYOpS1aHtLq/w=";
    "ChironSungHK-Text-B.otf" =
      "sha256-ZXcjAJ3blOKZddd0bwwlGjKy9NKa3TKSO4PMM97JBEk=";
    "ChironSungHK-Text-EL-It.otf" =
      "sha256-pTT8GfPcsLRwPzpkPiYIvOcs4wuco+KdgTO9jGj9vAo=";
    "ChironSungHK-Text-EL.otf" =
      "sha256-5H3yLC+evh38SIGj4s0hTg07B1qy+RrquT47Yeayb3o=";
    "ChironSungHK-Text-H-It.otf" =
      "sha256-JyBJEBr0g7jVI8F10tGzaXrd0BscmtXYxPsPPqjiSyg=";
    "ChironSungHK-Text-H.otf" =
      "sha256-NZBGiu9/rKFIThSn/cxMSDEiYMgSYFSsfJNrbQMyGlU=";
    "ChironSungHK-Text-L-It.otf" =
      "sha256-MJrccFVMqUt0Oew0E4MFQ35gaK8lyye1gSFt4xvWZe4=";
    "ChironSungHK-Text-L.otf" =
      "sha256-h/oOWBSB/TWucgJk0AbunuZT+/eo1QgDgjUBosESVhU=";
    "ChironSungHK-Text-M-It.otf" =
      "sha256-BRO1jh1CkHaAfxE4lU1GxPLlsI71+3Onkwjhmg4OUaw=";
    "ChironSungHK-Text-M.otf" =
      "sha256-/wEI9yMcUcVk8Ucl6W5uVVsFAeves8AVJgXMR2fs+44=";
    "ChironSungHK-Text-N-It.otf" =
      "sha256-XaFUb312ZILsSY9WaPgnY5dHc/viRe9r+GBWZAy3Wuk=";
    "ChironSungHK-Text-N.otf" =
      "sha256-wgkI6GTHUwjNYCmVuMbjFbvX7r/ydDWyUwTW9hZBfpU=";
    "ChironSungHK-Text-R-It.otf" =
      "sha256-xy6boiMaifcxvau78kKRrB9b166Im6tD06T8nFLrslY=";
    "ChironSungHK-Text-R.otf" =
      "sha256-rpq010lEuaF4X1oo06kSk/1O3MTZ0br9KIQ+kdlUjzU=";
    "ChironSungHK-Text-SB-It.otf" =
      "sha256-VV0mOg9JTsO33XkO1ONp6BzwT6c8kB+pTBGpR7pxBFo=";
    "ChironSungHK-Text-SB.otf" =
      "sha256-RiCCxyTyQuib3CV+eIXURQUIpQp8AuFOfekxyqyMSGw=";
  };

  fontSrcs = mapAttrs (
    name: hash:
    fetchurl {
      inherit hash;

      url = "${baseUrl}/STATIC_OTF/${name}";
    }
  ) fontHashes;

  licenseSrc = fetchurl {
    hash = "sha256-9hCr0cT0EMB/6Z5r6SSlAOV3o3ixgqc8aRUn4uNoyW8=";
    url = "${baseUrl}/LICENSE.md";
  };

  meta = {
    description = "Chiron Sung HK Text Traditional Chinese body-text serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/chiron-sung-hk"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chiron Sung HK Text, the body-text static OpenType
      subfamily of Chiron Sung HK generated with the PADG axis set to 6
      for slightly more open Han character spacing. Includes eight weights
      from ExtraLight to Heavy in upright and italic styles.
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

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/opentype/chiron
    docDir=$out/share/doc/${pname}
    ${concatStringsSep "\n    " (
      mapAttrsToList (
        name: src:
        "install -Dm444 ${src} $fontDir/${name}"
      ) fontSrcs
    )}
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "昭源宋體 Text";

      languages = [
        "aa"
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
        "el"
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
        "ja"
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
        "ko"
        "ku-tr"
        "kum"
        "kv"
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
        "sh"
        "sk"
        "sl"
        "sm"
        "sma"
        "smj"
        "smn"
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
        "yo"
        "yue"
        "yuw"
        "za"
        "zh-cn"
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

      vendor = "chiron";
    };
  };

  srcs = attrValues fontSrcs;
}
