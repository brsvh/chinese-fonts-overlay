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

  pname = "chiron-zevacode-gima";
  version = "2026-05-29";

  src = fetchurl {
    hash = "sha256-eaLoq4nbDgrp2Vxz5/xHjmMQZPGTrY1QkkPYSEXpDp0=";
    url = "https://github.com/chiron-fonts/ZevaCode/releases/download/${version}/ZevaCode-Gima-Static_TTF.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-ZBrvEJTrvI4e8SH+ssBaAnWdEHlCpPjGDi6SoYLVqlo=";
    url = "https://raw.githubusercontent.com/chiron-fonts/ZevaCode/${version}/LICENSE.md";
  };

  meta = {
    description = "ZevaCode Gima monospace font family with ZevHeiTC-N CJK glyphs";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/ZevaCode"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides ZevaCode Gima static TrueType fonts combining Mona Sans
      Mono with ZevHeiTC-N CJK glyphs in aligned (Al) and original-width
      (Og) variants across eight weights.
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
    install -Dm444 ${licenseSrc} $docDir/LICENSE.md

    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip
  ];

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "ZevaCode Gima";

      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bi"
        "bin"
        "br"
        "bs"
        "ca"
        "ch"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
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
        "ja"
        "ki"
        "kj"
        "ko"
        "ku-tr"
        "kwm"
        "lb"
        "lg"
        "li"
        "lij"
        "lt"
        "lv"
        "lzh"
        "mfe"
        "mg"
        "mh"
        "miq"
        "mjw"
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
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "rm"
        "rn"
        "ro"
        "rw"
        "sc"
        "se"
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
            本套件同時包含 Al（盡力對齊拉丁字寬兩倍）與 Og（保留原中文字寬）兩種變體。中文字圖直接複製自宙黑體 ZevHeiTC-N，不含中文 OpenType 排版特性且不支援直排。
          '';

          url = "https://github.com/chiron-fonts/ZevaCode";
        }
      ];

      styles = [
        "hei"
        "mono"
        "sans"
      ];

      vendor = "chiron";
    };
  };

  sourceRoot = "ZevaCode-Gima";
}
