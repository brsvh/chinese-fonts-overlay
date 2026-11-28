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

  pname = "chiron-zevacode-casmono";
  version = "2026-05-29";

  src = fetchurl {
    hash = "sha256-PEO1PFPx4GxrjucKV5Kn1NWpzqRaZlw81bhzBGXC/BI=";
    url = "https://github.com/chiron-fonts/ZevaCode/releases/download/${version}/ZevaCode-CasMono-Static_TTF.zip";
  };

  licenseSrc = fetchurl {
    hash = "sha256-ZBrvEJTrvI4e8SH+ssBaAnWdEHlCpPjGDi6SoYLVqlo=";
    url = "https://raw.githubusercontent.com/chiron-fonts/ZevaCode/${version}/LICENSE.md";
  };

  meta = {
    description = "ZevaCode CasMono no-ligatures monospace fonts with ZevHeiTC-N CJK glyphs";

    homepage = [
      "https://chiron-fonts.github.io/"
      "https://github.com/chiron-fonts/ZevaCode"
    ];

    license = licenses.ofl;

    longDescription = ''
      Provides ZevaCode CasMono static TrueType fonts combining Cascadia
      Mono (no ligatures) with ZevHeiTC-N CJK glyphs in aligned (Al) and
      original-width (Og) variants across six upright and italic weights.
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
      displayName = "ZevaCode CasMono";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "ar"
        "ast"
        "av"
        "ay"
        "ayc"
        "az-az"
        "az-ir"
        "be"
        "bem"
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
        "ckb"
        "cmn"
        "co"
        "crh"
        "cs"
        "csb"
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
        "fa"
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
        "he"
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
        "ku-iq"
        "ku-ir"
        "ku-tr"
        "kum"
        "kw"
        "kwm"
        "ky"
        "la"
        "lah"
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
        "ota"
        "pa-pk"
        "pap-an"
        "pap-aw"
        "pl"
        "ps-af"
        "ps-pk"
        "pt"
        "rm"
        "rn"
        "ro"
        "ru"
        "rw"
        "sc"
        "sd"
        "se"
        "sel"
        "sg"
        "sgs"
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
        "ty"
        "tyv"
        "ug"
        "uk"
        "unm"
        "ur"
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
        "yi"
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

  sourceRoot = "ZevaCode-CasMono";
}
