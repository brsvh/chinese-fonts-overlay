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

  pname = "chiron-sub-hei";
  version = "26.010";

  src = fetchurl {
    hash = "sha256-8/E7ryRyporuvdnedtQLrSN4bs8vugz/pey1cPVlBA0=";
    url = "https://github.com/chiron-fonts/sub-fonts/releases/download/v${version}-hei/Subhei_v${version}_all.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-qr329g7nVJj4QKses29lgXhqvjfWV9tWC+wQtTE/WkI=";
    url = "https://raw.githubusercontent.com/chiron-fonts/sub-fonts/v${version}-hei/OFL_LICENSE";
  };

  meta = {
    description = "SubHei Chiron Hei HK subtitle sans-serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/sub-fonts"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides SubHei, a suite of 24 TrueType subtitle fonts from Chiron
      Fonts derived from Chiron Hei HK with Inter Latin glyphs and
      widened full-width CJK spacing across weights, punctuation modes,
      spacing widths, and stylistic-set presets.
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

    fontDir=$out/share/fonts/truetype/chiron
    docDir=$out/share/doc/${pname}
    install -Dm444 -t $fontDir *.ttf
    install -Dm444 ${licenseSrc} $docDir/OFL_LICENSE

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "拾字黑體";

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
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
        "cu"
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
        "hak"
        "haw"
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
        "ko"
        "kr"
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

      notices = [
        {
          level = "note";

          text = ''
            拾字黑體專為橫排中英混排字幕製作，含 W340/W370、IN1/IN2、A08/A10/A12 與 R1/R2 共 24 款預設。其中 R2 套用較進取的 ss16 字符替換，不建議用於嚴謹製作用途；倉庫程式碼採 MIT 授權，字體本身採 SIL OFL 1.1 授權。
          '';

          url = "https://github.com/chiron-fonts/sub-fonts";
        }
      ];

      styles = [
        "hei"
        "sans"
      ];

      vendor = "chiron";
    };
  };

  sourceRoot = ".";
}
