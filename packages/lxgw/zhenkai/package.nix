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

  pname = "lxgw-zhenkai";
  version = "0.827";
  legacyVersion = "0.825";

  slabGbSrc = fetchurl {
    hash = "sha256-v06ow5tReERpAgEgElcV0wdRNyM/4ze10Kcyf538A70=";
    url = "https://github.com/lxgw/LxgwZhenKai/releases/download/v${version}/LXGWZhenKaiSlabGB-Regular.ttf";
  };

  gbSrc = fetchurl {
    hash = "sha256-QIdpAqfOJSaKtxCtj+bitjvAAqpLaNIv1F/BJDcmztU=";
    url = "https://github.com/lxgw/LxgwZhenKai/releases/download/v${legacyVersion}/LXGWZhenKaiGB-Regular.ttf";
  };

  gbkSrc = fetchurl {
    hash = "sha256-gheFHr3hJKqErnVKTB1W9BjaYkR2Z6hqSrS4titlexs=";
    url = "https://github.com/lxgw/LxgwZhenKai/releases/download/v${legacyVersion}/ZhenKai_GBK-Regular.ttf";
  };

  licenseSrc = fetchurl {
    hash = "sha256-HuZqIt36UkHUB6X9miumZsTeVwDxcYLV7nKeBDTntC0=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhenKai/v${version}/OFL.txt";
  };

  legacyLicenseSrc = fetchurl {
    hash = "sha256-cWUbHcMODIqxdoZA23joE5yGynrwltmx2MRu2mfutSQ=";
    url = "https://raw.githubusercontent.com/lxgw/LxgwZhenKai/v${legacyVersion}/OFL.txt";
  };

  meta = {
    description = "LXGW ZhenKai Chinese handwriting fonts";
    homepage = "https://github.com/lxgw/LxgwZhenKai";
    license = licenses.ofl;

    longDescription = ''
      Provides LXGW ZhenKai GB, ZhenKai_GBK, and LXGW ZhenKai Slab GB,
      handwriting fonts derived from LXGW WenKai with heavier strokes.
      Slab GB includes Gungsuh Latin characters, while GBK also uses
      metrics intended for KaiTi documents. GB and GBK retain their
      final 0.825 release.
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
    slabGbSrc
    gbSrc
    gbkSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/lxgw
    docDir=$out/share/doc/${pname}
    install -Dm444 ${slabGbSrc} $fontDir/LXGWZhenKaiSlabGB-Regular.ttf
    install -Dm444 ${gbSrc} $fontDir/LXGWZhenKaiGB-Regular.ttf
    install -Dm444 ${gbkSrc} $fontDir/ZhenKai_GBK-Regular.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL.txt
    install -Dm444 ${legacyLicenseSrc} $docDir/OFL-0.825.txt

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "霞鹜臻楷";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "az-az"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "bs"
        "ca"
        "ce"
        "ch"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
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
        "ik"
        "io"
        "is"
        "it"
        "ja"
        "ki"
        "kj"
        "kl"
        "ku-tr"
        "kum"
        "kwm"
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
        "miq"
        "mjw"
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
        "rm"
        "rn"
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
        "ty"
        "uk"
        "unm"
        "uz"
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
        "zh-tw"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "handwritten"
        "kai"
      ];

      vendor = "lxgw";
    };
  };
}
