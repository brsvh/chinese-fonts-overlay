{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-malgun-gothic";
  fontFamily = "Malgun Gothic";

  files = [
    "malgun.ttf"
    "malgunbd.ttf"
    "malgunsl.ttf"
  ];

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "Malgun Gothic";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bg"
        "bi"
        "br"
        "ca"
        "ch"
        "co"
        "da"
        "de"
        "en"
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
        "ko"
        "kum"
        "kwm"
        "lb"
        "lg"
        "li"
        "lij"
        "mfe"
        "mg"
        "mhr"
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
        "os"
        "pap-an"
        "pap-aw"
        "pt"
        "rm"
        "rn"
        "ru"
        "rw"
        "sc"
        "sel"
        "sg"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "tn"
        "tpi"
        "ts"
        "unm"
        "uz"
        "vo"
        "vot"
        "wa"
        "wae"
        "wo"
        "xh"
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
        "hei"
        "sans"
      ];

      vendor = "microsoft";
    };
  };
}
