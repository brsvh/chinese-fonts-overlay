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

  pname = "chiron-hei-hk-text";
  version = "2.609";
  baseUrl = "https://raw.githubusercontent.com/chiron-fonts/chiron-hei-hk/v${version}";

  fontHashes = {
    "ChironHeiHK-Text-B-It.otf" =
      "sha256-520X4txC247Vj+DSNVFW3ZzDUOvpzGF8SNRpNlb4b3E=";
    "ChironHeiHK-Text-B.otf" =
      "sha256-OuiLIcF8WsTLXvsV6ERQ40wXNkUFC6RWU/B+MAGT6uQ=";
    "ChironHeiHK-Text-EL-It.otf" =
      "sha256-WnHpDyaFLMMEv/xD09MfwOK+6lFtmBqGxrXNRaVQvc4=";
    "ChironHeiHK-Text-EL.otf" =
      "sha256-/HbK+J+q7U1ZcRjph6XWFJ4TE91cn7w/PjBkshWBDVI=";
    "ChironHeiHK-Text-H-It.otf" =
      "sha256-fKUORqOToHJLbnf6atVa9WZCN5GhIslUeIjGtLMyuF0=";
    "ChironHeiHK-Text-H.otf" =
      "sha256-TcD0QDakXc7rmQNod3Zuov5C7WLmAWVGJ63iMRJhUAA=";
    "ChironHeiHK-Text-L-It.otf" =
      "sha256-tNoVS/mXCr2jZS/WMxTxe+kOkSc/38PBJpQFvEENgGQ=";
    "ChironHeiHK-Text-L.otf" =
      "sha256-SKtLvQPuXI4uOr9DRHb7aM4QzgPjZEbbO/zrHlUJe7k=";
    "ChironHeiHK-Text-M-It.otf" =
      "sha256-hBHEWdbVc+CauI3EJ1mV/m52ZzaLB/rVLku6EzAnE/U=";
    "ChironHeiHK-Text-M.otf" =
      "sha256-JLUz/4W/MbD9w3cOPtXWY5enp0rLHJp9JokGG4DBVC4=";
    "ChironHeiHK-Text-N-It.otf" =
      "sha256-2G/BZm7ZulkRHyUH+g/FwwDEXzD+N+TZYXpACxmuZF4=";
    "ChironHeiHK-Text-N.otf" =
      "sha256-F7ycOG5h6Z46fBakzvMCRoCSk1bAMO81c82FwP0EO1c=";
    "ChironHeiHK-Text-R-It.otf" =
      "sha256-aE4PQEwsaGS/uWNzoXC8I5nbAEdRqQvxgyZC015z2co=";
    "ChironHeiHK-Text-R.otf" =
      "sha256-Ue3pCy+ZBhHFwQMM7qdTfH9fGcmuyLFe4PDGVq8TaWA=";
    "ChironHeiHK-Text-SB-It.otf" =
      "sha256-WTyKxQUJhmgWTrKR65/6t4s4hAvIr/Ki4pQCFfWCyFM=";
    "ChironHeiHK-Text-SB.otf" =
      "sha256-1AYOExCdVkzyV0XQaIrTgA3gJD1e4qesQ97F3XX3nbs=";
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
    description = "Chiron Hei HK Text Traditional Chinese body-text sans-serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/chiron-hei-hk"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides Chiron Hei HK Text, the body-text static OpenType subfamily
      of Chiron Hei HK generated with the PADG axis set to 6 for slightly
      more open Han character spacing. Includes eight weights from
      ExtraLight to Heavy in upright and italic styles.
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
      displayName = "昭源黑體 Text";

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
