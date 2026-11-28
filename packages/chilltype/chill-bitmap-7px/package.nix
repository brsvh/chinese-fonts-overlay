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

  pname = "chill-bitmap-7px";
  version = "2.502";

  src = fetchurl {
    hash = "sha256-RE3kLNDsSZuqPsopWPZPduXR/DBXUeu5oNUxHcu28Tc=";
    url = "https://github.com/Warren2060/ChillBitmap/releases/download/v${version}/ChillBitmap_New.zip";
  };

  oflSrc = fetchurl {
    hash = "sha256-umQFOC4F4DDASVXS+z18Q3t5LB+jpu2gYP46nG+flZc=";
    url = "https://raw.githubusercontent.com/Warren2060/ChillBitmap/f9e3b2f988a2c4107f866aa43c3d61a2b27254d5/License";
  };

  meta = {
    description = "Chill Bitmap 7px pixel-style Chinese and Latin fonts";

    homepage = [
      "https://github.com/Warren2060/ChillBitmap"
    ];

    license = with licenses; [
      chilltype-bitmap-7px-license
      ofl
    ];

    longDescription = ''
      Provides Chill Bitmap 7px and its Latin companion ChillBitmapSE 7px
      from ChillType, a 7-pixel bitmap Chinese font derived from Misaki
      Font, BoutiqueBitmap7x7, and GuanZhi 8px.

      The upstream repository carries SIL Open Font License 1.1 alongside
      the 7px free-software derivative license notice.
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

  installPhase = ''
    runHook preInstall

    fontDir=$out/share/fonts/truetype/chilltype
    docDir=$out/share/doc/${pname}
    find . -type f -name '*_7px.ttf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    find . -type f -name 'ChillBitmap_7px_License.txt' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 {} "$docDir/ChillBitmap_7px_License.txt" \;
    install -Dm444 ${oflSrc} "$docDir/OFL.txt"

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉点阵体 7px";

      languages = [
        "aa"
        "agr"
        "an"
        "ast"
        "ay"
        "ayc"
        "az-az"
        "bem"
        "ber-dz"
        "bg"
        "bi"
        "bin"
        "bm"
        "br"
        "bs"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
        "ee"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "ff"
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
        "ha"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ig"
        "io"
        "is"
        "it"
        "kab"
        "ki"
        "kj"
        "ku-tr"
        "kum"
        "kw"
        "kwm"
        "lb"
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
        "sc"
        "sel"
        "sg"
        "sgs"
        "sk"
        "sl"
        "sma"
        "smj"
        "smn"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "tk"
        "tn"
        "tpi"
        "tr"
        "ts"
        "ty"
        "unm"
        "uz"
        "ve"
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

      licenseCost = "free";

      notices = [
        {
          level = "note";

          text = ''
            本包同时包含寒蝉点阵体 7px 全字符集与独立西文字体 ChillBitmapSE 7px。上游仓库附带 SIL OFL 1.1，且 7px 衍生自美咲字体、精品点阵体 7x7 与观致 8px，压缩包内声明允许商业与非商业自由使用、修改及分发，衍生品须采用相同授权。
          '';

          url = "https://github.com/Warren2060/ChillBitmap/blob/f9e3b2f988a2c4107f866aa43c3d61a2b27254d5/LICENSE.md";
        }
      ];

      styles = [
        "art"
        "sans"
      ];

      vendor = "chilltype";
    };
  };

  sourceRoot = ".";
}
