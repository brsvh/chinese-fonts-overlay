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

  pname = "oppo-sans";
  version = "4.0";

  src = fetchurl {
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0"
      "--referer"
      "https://www.coloros.com/article/A00000074/"
    ];

    hash = "sha256-QS0Q/U7YRH4x7skTqb1IFIFs6WFMEuquI/d9yw9U+X0=";
    url = "https://coloros-website-cn.allawnfs.com/font/OPPO_Sans_${version}.zip";
  };

  meta = {
    description = "OPPO Sans 4.0 variable Chinese font";
    homepage = "https://www.coloros.com/article/A00000074/";
    license = licenses.oppo-sans-fonts-license;

    longDescription = ''
      Provides OPPO Sans 4.0 as the original variable TrueType font, with
      a weight axis from 100 to 700 and named Light, Regular, Medium,
      SemiBold, and Bold instances.

      The OPPO Sans Fonts License Agreement permits use and bundling of
      unmodified fonts with software under its terms. Font modification
      and standalone font redistribution are prohibited. Copyright and
      license notices must be retained.
    '';

    maintainers = with maintainers; [ brsvh ];
    platforms = platforms.all;
    redistributable = false;
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

  sourceRoot = "OPPO_Sans_${version}";

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/oppo
    install -Dm444 "OPPO Sans 4.0.ttf" $fontDir/OPPOSans4.0.ttf

    runHook postInstall
  '';

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "OPPO Sans 4.0";
      embedding = true;

      languages = [
        "aa"
        "af"
        "agr"
        "an"
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
        "kaa"
        "ki"
        "kj"
        "kk"
        "kl"
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
        "yuw"
        "za"
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "gratisCommercialUse";

      notices = [
        {
          level = "warning";

          text = ''
            OPPO Sans 允许将未修改的字体嵌入或捆绑在字体软件以外的软件中；须显著注明使用了 OPPO Sans，并保留版权声明与许可协议。不得修改字体，也不得单独分发或出售字体。
          '';

          url = "https://www.coloros.com/article/A00000074/";
        }
      ];

      styles = [
        "hei"
        "sans"
      ];

      vendor = "oppo";
    };
  };
}
