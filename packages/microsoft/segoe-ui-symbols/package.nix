{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-ui-symbols";
  fontFamily = "Segoe UI Symbol";

  files = [
    "seguiemj.ttf"
    "seguihis.ttf"
    "seguisym.ttf"
  ];

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "Segoe UI Emoji / Segoe UI Historic / Segoe UI Symbol";

      languages = [
        "aa"
        "agr"
        "an"
        "arc"
        "ay"
        "ayc"
        "bem"
        "bi"
        "br"
        "ch"
        "co"
        "cop"
        "da"
        "de"
        "ecy"
        "el"
        "en"
        "es"
        "et"
        "ett"
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
        "got"
        "gv"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "kwm"
        "lb"
        "li"
        "lij"
        "mfe"
        "mg"
        "mjw"
        "ms"
        "nb"
        "nds"
        "ng"
        "nl"
        "nn"
        "no"
        "nr"
        "nso"
        "oc"
        "om"
        "otk"
        "pal"
        "pap-an"
        "pap-aw"
        "peo"
        "pgd"
        "pgl"
        "phn"
        "pt"
        "rm"
        "rn"
        "rw"
        "sc"
        "sg"
        "shs"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "syr"
        "tn"
        "tpi"
        "ts"
        "uga"
        "und-zsye"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "xcr"
        "xh"
        "xlc"
        "xld"
        "xpr"
        "xsa"
        "yap"
        "yuw"
        "za"
        "zu"
      ];

      licenseCost = "paid";

      notices = [
        {
          level = "caution";

          text = ''
            Microsoft 字体是专有软件，受 Microsoft Software License Terms 约束。 这个仓库只提供本地构建与安装表达式，不授予额外使用或再分发权利。

            相关限制可以概括为：您不能在非 Windows 设备上使用它们。

            建议您只在 Windows Subsystem for Linux (WSL) 上使用它。
          '';
        }
      ];

      styles = [
        "sans"
        "symbol"
      ];

      vendor = "microsoft";
    };
  };
}
