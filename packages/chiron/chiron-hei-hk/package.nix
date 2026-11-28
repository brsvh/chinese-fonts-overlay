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

  pname = "chiron-hei-hk";
  version = "2.609";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/chiron-hei-hk/v${version}";

  fontHashes = {
    "ChironHeiHK-B-It.otf" =
      "sha256-MfkoaZuKnguH0KvvyR+nuxUB78i4nx5zp7qIDlQrUXE=";
    "ChironHeiHK-B.otf" =
      "sha256-UabDn43QpFIqfF02bXfp5Srr5CgNmxbtlfAyiMgC6CE=";
    "ChironHeiHK-EL-It.otf" =
      "sha256-Sj3iZnb9z9TZf8si+y+V/+dmspkr/VSs8uBwtsmWq30=";
    "ChironHeiHK-EL.otf" =
      "sha256-ornkWrADu1vgNFNULqXBqFKqH+jBEE6KuTmF2+r2ysU=";
    "ChironHeiHK-H-It.otf" =
      "sha256-h3srxpYESuOrwEtK17ylW0UQ90no6w4TXf12B0LWAe8=";
    "ChironHeiHK-H.otf" =
      "sha256-HcOfHZfJvboW/vgfCL5WyW7rcCrKA/T1uEmMa8TjhdQ=";
    "ChironHeiHK-L-It.otf" =
      "sha256-k3il0o82WPTwiro0Ibk2Bt2H4+JUMfzaMjbhmfv8nGE=";
    "ChironHeiHK-L.otf" =
      "sha256-vrIc6IH+9UN44JjyByAzDlEhs75Wn8BHuN6EPw7iyDw=";
    "ChironHeiHK-M-It.otf" =
      "sha256-Z1lXjKTaxQCySt/BhDV4VeRFAFyz4G2q4kx/Y2cdWmc=";
    "ChironHeiHK-M.otf" =
      "sha256-2cfZVvkdB0NzzzibEDFaiOYWCVTB3yhLKpzEzpoJTgg=";
    "ChironHeiHK-N-It.otf" =
      "sha256-nlaX7vWn8aI/HcbpRi+4/uTXSvy0MECbr5xSdsoOLqM=";
    "ChironHeiHK-N.otf" =
      "sha256-WnBDcyClQX1PN5s75y3lkzo7kNixSiUNXUtIb/v6j5w=";
    "ChironHeiHK-R-It.otf" =
      "sha256-hGlzFwN8oG782KS2c7swrMr+FVSnrDYJALUSOfe8NP0=";
    "ChironHeiHK-R.otf" =
      "sha256-cvaCeaeKEYtGm8aDoasSNkpaPCRO5ZLaRB1KPLDtpLE=";
    "ChironHeiHK-SB-It.otf" =
      "sha256-MZfyYwdgmyjbVWmaso9XAm2EIae/N2HIZD0YD5NK9mI=";
    "ChironHeiHK-SB.otf" =
      "sha256-ESVws6yTJGZgCXcAmAF+YFD/iuvaoq5qxIag265aVNQ=";
  };

  fontSrcs = mapAttrs (
    name: hash:
    fetchurl {
      inherit hash;

      url = "${baseUrl}/STATIC_OTF/${name}";
    }
  ) fontHashes;

  licenseSrc = fetchurl {
    hash = "sha256-j2pJB5p6zP/9/wAmyGi7teYq2mqbJVTCiulDSb3qsD8=";
    url = "${baseUrl}/LICENSE.md";
  };

  meta = {
    description = "Chiron Hei HK Traditional Chinese sans-serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/chiron-hei-hk"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chiron Hei HK, a Traditional Chinese sans-serif family
      from Chiron Fonts derived from Source Han Sans HK and Source Sans 3.
      Includes eight static OpenType weights from ExtraLight to Heavy in
      upright and italic styles.
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
      displayName = "昭源黑體";

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
        "ba"
        "be"
        "bem"
        "ber-dz"
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
        "fat"
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
        "kab"
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
        "sc"
        "sco"
        "se"
        "sel"
        "sg"
        "sgs"
        "sh"
        "shs"
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
        "tw"
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
        "hei"
        "sans"
      ];

      vendor = "chiron";
    };
  };

  srcs = attrValues fontSrcs;
}
