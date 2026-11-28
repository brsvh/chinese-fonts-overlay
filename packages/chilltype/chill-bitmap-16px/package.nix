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

  pname = "chill-bitmap-16px";
  version = "2.502";

  src = fetchurl {
    hash = "sha256-RE3kLNDsSZuqPsopWPZPduXR/DBXUeu5oNUxHcu28Tc=";
    url = "https://github.com/Warren2060/ChillBitmap/releases/download/v${version}/ChillBitmap_New.zip";
  };

  meta = {
    description = "Chill Bitmap 16px pixel-style Chinese and Latin fonts";

    homepage = [
      "https://github.com/Warren2060/ChillBitmap"
    ];

    license = with licenses; [
      gpl2Plus
      ofl
    ];

    longDescription = ''
      Provides Chill Bitmap 16px and its Latin companion ChillBitmapSE 16px
      from ChillType, a 16-pixel bitmap font derived from GNU Unifont with
      redesigned Latin glyphs.

      Dual-licensed under SIL Open Font License 1.1 and GNU GPL 2.0 or later
      with the GNU Font Embedding Exception.
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
    find . -type f -name '*_16px.ttf' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 -t "$fontDir" {} +
    find . -type f -name 'ChillBitmap_16px_License.txt' ! -path '*/__MACOSX/*' \
      -exec install -Dm444 {} "$docDir/ChillBitmap_16px_License.txt" \;

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "寒蝉点阵体 16px";

      languages = [
        "aa"
        "ab"
        "af"
        "agr"
        "ak"
        "an"
        "anp"
        "ar"
        "as"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "az-ir"
        "ba"
        "ban"
        "bax"
        "be"
        "bem"
        "ber-dz"
        "ber-ma"
        "bg"
        "bh"
        "bhb"
        "bho"
        "bi"
        "bin"
        "bku"
        "blt"
        "bm"
        "bn"
        "bo"
        "br"
        "brx"
        "bs"
        "bua"
        "ca"
        "ce"
        "ch"
        "chm"
        "chr"
        "cjm"
        "ckb"
        "cmn"
        "co"
        "cop"
        "crh"
        "cs"
        "csb"
        "cu"
        "cv"
        "cy"
        "da"
        "de"
        "doi"
        "dsb"
        "dv"
        "dz"
        "ee"
        "eky"
        "el"
        "en"
        "eo"
        "es"
        "et"
        "eu"
        "fa"
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
        "gu"
        "gv"
        "ha"
        "hak"
        "haw"
        "he"
        "hi"
        "hif"
        "hne"
        "hnn"
        "ho"
        "hr"
        "hsb"
        "ht"
        "hu"
        "hy"
        "hz"
        "ia"
        "id"
        "ie"
        "ig"
        "ii"
        "ik"
        "io"
        "is"
        "it"
        "iu"
        "jv"
        "ka"
        "kaa"
        "kab"
        "khb"
        "ki"
        "kj"
        "kk"
        "kl"
        "km"
        "kn"
        "kok"
        "kr"
        "ks"
        "ku-am"
        "ku-iq"
        "ku-ir"
        "ku-tr"
        "kum"
        "kv"
        "kw"
        "kwm"
        "ky"
        "la"
        "lah"
        "lb"
        "lep"
        "lez"
        "lg"
        "li"
        "lif"
        "lij"
        "lis"
        "ln"
        "lo"
        "lt"
        "lv"
        "lzh"
        "mag"
        "mai"
        "mfe"
        "mg"
        "mh"
        "mhr"
        "mi"
        "mid"
        "miq"
        "mjw"
        "mk"
        "ml"
        "mn-cn"
        "mn-mn"
        "mni"
        "mnw"
        "mo"
        "mr"
        "ms"
        "mt"
        "my"
        "na"
        "nan"
        "nb"
        "nds"
        "ne"
        "ng"
        "nhn"
        "niu"
        "nl"
        "nn"
        "no"
        "nqo"
        "nr"
        "nso"
        "nv"
        "ny"
        "oc"
        "om"
        "or"
        "os"
        "ota"
        "pa"
        "pa-pk"
        "pap-an"
        "pap-aw"
        "pgl"
        "pl"
        "ps-af"
        "ps-pk"
        "pt"
        "qu"
        "quz"
        "raj"
        "rif"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sa"
        "sah"
        "sam"
        "sat"
        "sc"
        "sco"
        "sd"
        "se"
        "sel"
        "sg"
        "sgs"
        "sh"
        "shn"
        "shs"
        "si"
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
        "su"
        "sv"
        "sw"
        "szl"
        "ta"
        "tbw"
        "tcy"
        "tdd"
        "te"
        "tg"
        "th"
        "the"
        "tk"
        "tl"
        "tn"
        "to"
        "tpi"
        "tr"
        "ts"
        "tt"
        "tw"
        "ty"
        "tyv"
        "ug"
        "uk"
        "unm"
        "ur"
        "uz"
        "vai"
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
        "zh-cn"
        "zh-sg"
        "zu"
      ];

      licenseCost = "free";

      notices = [
        {
          level = "note";

          text = ''
            本包同时包含寒蝉点阵体 16px 全字符集与独立西文字体 ChillBitmapSE 16px。16px 衍生自 GNU Unifont，采用 SIL OFL 1.1 与带字体嵌入例外的 GNU GPL 2.0 或更高版本双重授权。
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
