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

  pname = "ito-chogokuboso-gothic";
  version = "1.00";

  src = fetchurl {
    hash = "sha256-VY4LZtzDB5X8e5h/50BzWKyXrLTsqG0ln7m864EKS0I=";
    url = "https://font.websozai.jp/fontdata-8/chogokubosogothic.zip";
  };

  meta = {
    description = "Chogokuboso Gothic extra-light Japanese font";
    homepage = "https://font.websozai.jp/line-font-mihon.html";
    license = licenses.mplus;

    longDescription = ''
      Provides Chogokuboso Gothic, an extra-light Japanese sans-serif font
      from Ito Font based on M+ outline fonts. Its fine strokes are intended
      for display text, logos, and headings, with Japanese kana, kanji,
      Latin letters, numerals, and punctuation in a single regular style.
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

  nativeBuildInputs = [ unzip ];

  sourceRoot = "chogokubosogothic";

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/ito
    install -Dm444 chogokubosogothic_5.ttf $fontDir/ChogokubosoGothic.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "超極細ゴシック";

      languages = [
        "aa"
        "ab"
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
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "chm"
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
        "gv"
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
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
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
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mjw"
        "mn-mn"
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
        "sah"
        "sc"
        "se"
        "sel"
        "sg"
        "sh"
        "sk"
        "sl"
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
        "tpi"
        "tr"
        "ts"
        "tt"
        "tyv"
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
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "hei"
        "sans"
      ];

      vendor = "ito";
    };
  };
}
