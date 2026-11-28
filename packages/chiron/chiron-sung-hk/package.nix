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

  pname = "chiron-sung-hk";
  version = "1.024";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/chiron-sung-hk/v${version}";

  fontHashes = {
    "ChironSungHK-B-It.otf" =
      "sha256-CLya2u1sqth1f2VhJlF4U6zAnYCk3A4bXWxPB7blbd0=";
    "ChironSungHK-B.otf" =
      "sha256-vD+REifJiuRcrzEUcgHCndPPFPwshK9yk29O9gZ7OX0=";
    "ChironSungHK-EL-It.otf" =
      "sha256-vXFDAfwUTOWlLUbgZBhzsr35j2nvB1AI3ktoS0GUGEg=";
    "ChironSungHK-EL.otf" =
      "sha256-AEK57ZYfpoYC/vc31cLiKgSUuQooGaMaENHveIBZgXs=";
    "ChironSungHK-H-It.otf" =
      "sha256-nBt+DrjCbCR3gsc5gMzewzXd4xrgKAsYhMpuv0rush4=";
    "ChironSungHK-H.otf" =
      "sha256-JGXr2BGeAIa9G+A1VtYN1qOimI8VealiUy3bjGuHfPo=";
    "ChironSungHK-L-It.otf" =
      "sha256-0Vrcf/H5mMjly6aVZa6BMtHxSjdlnf09PnL0lLpu5sQ=";
    "ChironSungHK-L.otf" =
      "sha256-N/wvYHlXif3d2VUsbcGblIgUTsdmLSyA28Doko2cuw0=";
    "ChironSungHK-M-It.otf" =
      "sha256-CQuMgHH6wr1fRcjjI7V/nnMzqxQUNfTplCRXTXCs+Kw=";
    "ChironSungHK-M.otf" =
      "sha256-hyr1g21QOukgkmSWzHWGOm+uvyRtkXSHs/hqf8XgXB4=";
    "ChironSungHK-N-It.otf" =
      "sha256-A1nY09HrbTEXyxkAANjncP9FmPaMiqerBT5jBQxpRSc=";
    "ChironSungHK-N.otf" =
      "sha256-mSG72epWWWRQGx4jiE6lrlxTUlNYB9eSYvp2eXmfdjM=";
    "ChironSungHK-R-It.otf" =
      "sha256-cv1DP0d6GFgaI+ZXUuysQ4Gtp3mCHXUaQdgXjR4h2YI=";
    "ChironSungHK-R.otf" =
      "sha256-1T2p/7NZOm3M40+eSl2UNpx+YZ76Gz2aYHF8fXKqZdA=";
    "ChironSungHK-SB-It.otf" =
      "sha256-4cJvrqEpbRHmus0uZxpc7xRCjuHMAVLvuH/7ClgUYn8=";
    "ChironSungHK-SB.otf" =
      "sha256-pkX9EuJ8TKBfquqTi7aiKCZRhvlRZj4QhIeh7Zu2cyw=";
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
    description = "Chiron Sung HK Traditional Chinese serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/chiron-sung-hk"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chiron Sung HK, a Traditional Chinese serif family from
      Chiron Fonts derived from Source Han Serif HK and Source Serif.
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
      displayName = "昭源宋體";

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
