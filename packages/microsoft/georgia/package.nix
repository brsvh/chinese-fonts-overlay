{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-georgia";
  fontFamily = "Georgia";

  files = [
    "georgia.ttf"
    "georgiab.ttf"
    "georgiai.ttf"
    "georgiaz.ttf"
  ];

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "Georgia";

      languages = [
        "aa"
        "af"
        "agr"
        "an"
        "av"
        "ay"
        "ayc"
        "be"
        "bem"
        "bg"
        "bi"
        "br"
        "bs"
        "ca"
        "ce"
        "ch"
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
        "hr"
        "hsb"
        "ht"
        "hu"
        "ia"
        "id"
        "ie"
        "ik"
        "io"
        "is"
        "it"
        "ki"
        "kj"
        "kl"
        "ku-tr"
        "kum"
        "kwm"
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
        "se"
        "sel"
        "sg"
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
        "tk"
        "tn"
        "tpi"
        "tr"
        "ts"
        "uk"
        "unm"
        "uz"
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
        "serif"
      ];

      vendor = "microsoft";
    };
  };
}
