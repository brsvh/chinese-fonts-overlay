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

  pname = "cwtex-q-ming";
  version = "0.42";

  fullSrc = fetchurl {
    hash = "sha256-y7LkdKteNnkqvmAItFwQKFcSrBsGIueGS1kYhkFbGnU=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQMing-Medium.ttf";
  };

  zhSrc = fetchurl {
    hash = "sha256-Ui9AtcpX/+c40X6pCzLFIXjpGc1R2uND/IDLVfyVymg=";
    url = "https://raw.githubusercontent.com/l10n-tw/cwtex-q-fonts-TTFs/v${version}/ttf/cwTeXQMingZH-Medium.ttf";
  };

  meta = {
    description = "cwTeX Q Ming Traditional Chinese fonts";
    homepage = "https://github.com/l10n-tw/cwtex-q-fonts";
    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides cwTeX Q Ming Medium and its ZH variant for Traditional
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
    install -Dm444 ${fullSrc} $fontDir/cwTeXQMing-Medium.ttf
    install -Dm444 ${zhSrc} $fontDir/cwTeXQMingZH-Medium.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "cwTeX Q 明體";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "ba"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "bua"
        "ca"
        "ce"
        "ch"
        "cmn"
        "da"
        "de"
        "en"
        "es"
        "eu"
        "fil"
        "fj"
        "fo"
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
        "kaa"
        "kj"
        "kk"
        "ko"
        "kum"
        "kwm"
        "ky"
        "lb"
        "lez"
        "lg"
        "li"
        "lij"
        "lzh"
        "mg"
        "mhr"
        "mjw"
        "mn-mn"
        "ms"
        "nan"
        "nb"
        "nds"
        "ng"
        "nl"
        "nn"
        "no"
        "nr"
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
        "ss"
        "st"
        "sv"
        "sw"
        "tpi"
        "ts"
        "tt"
        "tyv"
        "unm"
        "uz"
        "vo"
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
        "serif"
        "song"
      ];

      vendor = "cwtex";
    };
  };
}
