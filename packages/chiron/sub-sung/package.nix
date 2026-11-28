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

  pname = "chiron-sub-sung";
  version = "25.090";

  src = fetchurl {
    hash = "sha256-28MBSZwj3dOVb0rvOkO88ev9EV+uzyVuqEvpnw1jrvU=";
    url = "https://github.com/chiron-fonts/sub-fonts/releases/download/v${version}-sung/Subsung_v${version}_all.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-qr329g7nVJj4QKses29lgXhqvjfWV9tWC+wQtTE/WkI=";
    url = "https://raw.githubusercontent.com/chiron-fonts/sub-fonts/v${version}-sung/OFL_LICENSE";
  };

  meta = {
    description = "SubSung Chiron Sung HK subtitle serif fonts";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/sub-fonts"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides SubSung, a suite of 8 TrueType subtitle fonts from Chiron
      Fonts derived from Chiron Sung HK with widened full-width CJK
      spacing across W560 and W600 weights, spacing widths, and
      stylistic-set presets.
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
      displayName = "拾字宋體";

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

      notices = [
        {
          level = "note";

          text = ''
            拾字宋體專為橫排中英混排字幕製作，含 W560/W600、DF0、A08/A12 與 R1/R2 共 8 款預設。其中 R2 套用較進取的 ss16 字符替換，不建議用於嚴謹製作用途；倉庫程式碼採 MIT 授權，字體本身採 SIL OFL 1.1 授權。
          '';

          url = "https://github.com/chiron-fonts/sub-fonts";
        }
      ];

      styles = [
        "serif"
        "song"
      ];

      vendor = "chiron";
    };
  };

  sourceRoot = ".";
}
