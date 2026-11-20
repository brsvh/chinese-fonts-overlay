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

  pname = "cwtex-q-hei";
  version = "0.42";

  fullSrc = fetchurl {
    hash = "sha256-W0co6aFExG9AQ9/tkjb1/Jj7nqeRtikVXABCeM/xcjY=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQHei-Bold.ttf";
  };

  zhSrc = fetchurl {
    hash = "sha256-k3D1ICqxxDTqR3CvbFrOcKCRVWfEbDGyxlWHx501hpo=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQHeiZH-Bold.ttf";
  };

  meta = {
    description = "cwTeX Q Hei Traditional Chinese fonts";
    homepage = "https://github.com/l10n-tw/cwtex-q-fonts";
    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides cwTeX Q Hei Bold and its ZH variant for Traditional
      Chinese text. The full version includes additional non-Chinese glyphs;
      the ZH version contains Chinese characters and punctuation.

      The full version uses GPL 2.0 or later with a document embedding
      exception. The ZH version uses the SIL Open Font License 1.1.
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
    fullSrc
    zhSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/cwtex
    install -Dm444 ${fullSrc} $fontDir/cwTeXQHei-Bold.ttf
    install -Dm444 ${zhSrc} $fontDir/cwTeXQHeiZH-Bold.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "cwTeX Q 黑體";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "ca"
        "ce"
        "ch"
        "cmn"
        "co"
        "da"
        "de"
        "el"
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
        "hak"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "ik"
        "io"
        "is"
        "it"
        "kj"
        "ko"
        "kum"
        "kwm"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lzh"
        "mfe"
        "mg"
        "mhr"
        "mjw"
        "ms"
        "nan"
        "nb"
        "nds"
        "ng"
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
        "rm"
        "rn"
        "ru"
        "rw"
        "sc"
        "sel"
        "sg"
        "sma"
        "smj"
        "sn"
        "sq"
        "sr"
        "ss"
        "st"
        "sv"
        "sw"
        "tn"
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "wo"
        "xh"
        "yap"
        "yuw"
        "za"
        "zh-tw"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "hei"
        "sans"
      ];

      vendor = "cwtex";
    };
  };
}
