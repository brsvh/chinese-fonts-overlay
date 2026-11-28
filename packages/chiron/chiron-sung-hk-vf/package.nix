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

  pname = "chiron-sung-hk-vf";
  version = "1.024";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/chiron-sung-hk/v${version}";

  regularSrc = fetchurl {
    hash = "sha256-DREqGueO02ZyVhcTFzrXAYCqx23pnnXRUXhI5e9+pjs=";
    url = "${baseUrl}/VAR_OTF/ChironSungHKVF.otf";
  };

  italicSrc = fetchurl {
    hash = "sha256-9Q8PTBrPSA2arAzlwi/uXhpOv+QBZ8IDgoYlytoID4Y=";
    url = "${baseUrl}/VAR_OTF/ChironSungHKItVF.otf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-9hCr0cT0EMB/6Z5r6SSlAOV3o3ixgqc8aRUn4uNoyW8=";
    url = "${baseUrl}/LICENSE.md";
  };

  meta = {
    description = "Chiron Sung HK Traditional Chinese variable serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/chiron-sung-hk"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chiron Sung HK VF, the variable OpenType edition of Chiron
      Sung HK in upright and italic styles. Supports the wght axis from
      200 to 900 and the PADG axis from 0 to 10 for Han character
      padding adjustment.
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
    install -Dm444 ${regularSrc} $fontDir/ChironSungHKVF.otf
    install -Dm444 ${italicSrc} $fontDir/ChironSungHKItVF.otf
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "昭源宋體 VF";

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

  srcs = [
    regularSrc
    italicSrc
  ];
}
