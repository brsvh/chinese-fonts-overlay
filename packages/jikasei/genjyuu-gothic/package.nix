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

  pname = "jikasei-genjyuu-gothic";
  version = "1.002.20150607";

  regularSrc = fetchurl {
    hash = "sha256-kWu8I0sRCDW5pm6kf9YuVT/ZpSQiaxsf2sZmjw/JWAk=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8642/genjyuugothic-20150607.zip";
  };

  xSrc = fetchurl {
    hash = "sha256-5KDqEbgVUFatK2eMhQGy523Zm4yOtTY9OW/nwweSAbM=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8644/genjyuugothic-x-20150607.zip";
  };

  lSrc = fetchurl {
    hash = "sha256-0vzOwpAjLfEQ0RFv70QRQWh1rPdkcITJq31+teioDFA=";
    url = "https://ftp.iij.ad.jp/pub/osdn.jp/users/8/8643/genjyuugothic-l-20150607.zip";
  };

  meta = {
    description = "Gen Jyuu Gothic Japanese fonts";
    homepage = "http://jikasei.me/font/genjyuu/";
    license = licenses.ofl;

    longDescription = ''
      Provides Gen Jyuu Gothic, a rounded Japanese sans-serif family derived
      from Source Han Sans with some glyphs from M+ outline fonts. The
      standard, X, and L variants offer three degrees of rounding. Each
      includes seven weights in standard, proportional, and monospaced
      forms, for 63 fonts in one package.
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

  nativeBuildInputs = [ unzip ];

  srcs = [
    regularSrc
    xSrc
    lSrc
  ];

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/jikasei
    mkdir -p $fontDir
    unzip -q ${regularSrc} -d normal
    install -m444 normal/*.ttf $fontDir/
    unzip -q ${xSrc} -d x
    install -m444 x/*.ttf $fontDir/
    unzip -q ${lSrc} -d l
    install -m444 l/*.ttf $fontDir/

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "源柔ゴシック";

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
        "bm"
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
        "ee"
        "el"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "fat"
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
        "haw"
        "he"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "hz"
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
        "shs"
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
        "tw"
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
        "yi"
        "yo"
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "free";

      styles = [
        "rounded"
        "sans"
      ];

      vendor = "jikasei";
    };
  };
}
