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

  pname = "chiron-go-round-tc";
  version = "1.011";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/chiron-go-round-tc/v${version}";

  fontHashes = {
    "ChironGoRoundTC-200EL.otf" =
      "sha256-hqQmHIPUx/rKTCbioe6YvG77FY5jNCNVgqQQhhho7d0=";
    "ChironGoRoundTC-300L.otf" =
      "sha256-+v6oqe0wDGqOA5iuTF+O6Lk8wLKTFv1BEH5MYtBg2uY=";
    "ChironGoRoundTC-350N.otf" =
      "sha256-S3g/Rjdm0250/HeGFO+DRBIsnPgTUsJZyRO/ez62dn0=";
    "ChironGoRoundTC-400R.otf" =
      "sha256-UZJTIzy8o8K5e4GJSegDzPCPk311Qxvt9Z4WewC/S2U=";
    "ChironGoRoundTC-450BK.otf" =
      "sha256-m02khxmNpwdEhB0mJeoMqsyOPvPKHZKv2ouUofBGKew=";
    "ChironGoRoundTC-500M.otf" =
      "sha256-N+lVFChUrMwNta7Gz6lo20RYv9rsjnBa/ciwhhK0YPk=";
    "ChironGoRoundTC-600SB.otf" =
      "sha256-NTy+fZv9K0rdBkJPJ0ffNTBBW9DsCtxZjN8QEWHfb4g=";
    "ChironGoRoundTC-700B.otf" =
      "sha256-XtBDs9EEjk14aJCcbW+7otDLUHc9OUAD9PsHehjis/s=";
    "ChironGoRoundTC-800EB.otf" =
      "sha256-NLokuc3Opf7Z5IlQUoWPNFz/8uTdkoD0d5060H8JJJ8=";
    "ChironGoRoundTC-900H.otf" =
      "sha256-aYm7fGCYBXVxRsp5dlxLN9ovF94MgIQI1gMdtJM35k4=";
  };

  fontSrcs = mapAttrs (
    name: hash:
    fetchurl {
      inherit hash;

      url = "${baseUrl}/STATIC_OTF/${name}";
    }
  ) fontHashes;

  licenseSrc = fetchurl {
    hash = "sha256-AJRCjVFPRj1483UGlhuE6YzM1whXPE8SZh/22YnNJIM=";
    url = "${baseUrl}/LICENSE.md";
  };

  meta = {
    description = "Chiron GoRound TC Traditional Chinese rounded sans-serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/chiron-go-round-tc"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chiron GoRound TC, a rounded Traditional Chinese
      sans-serif family from Chiron Fonts derived from Chiron Hei HK
      with Nunito Latin glyphs. Includes ten static OpenType weights
      from ExtraLight to Heavy.
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
      displayName = "昭源環方";

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
        "ja"
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
        "ko"
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
        "rounded"
        "sans"
      ];

      vendor = "chiron";
    };
  };

  srcs = attrValues fontSrcs;
}
