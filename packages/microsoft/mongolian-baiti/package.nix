{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-mongolian-baiti";
  fontFamily = "Mongolian Baiti";

  files = [
    "monbaiti.ttf"
  ];

  passthru = {
    fontInfo = {
      languages = [
        "aa"
        "agr"
        "an"
        "ay"
        "ayc"
        "bem"
        "bi"
        "br"
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
        "kwm"
        "lb"
        "li"
        "lij"
        "mfe"
        "mg"
        "mjw"
        "mn-cn"
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
        "pap-an"
        "pap-aw"
        "pt"
        "rm"
        "rn"
        "rw"
        "sc"
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
