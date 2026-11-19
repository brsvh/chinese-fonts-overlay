{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-nirmala";
  fontFamily = "Nirmala Text";

  files = [
    "Nirmala.ttc"
  ];

  meta = {
    homepage = "https://learn.microsoft.com/en-us/typography/font-list/nirmala-ui";
  };

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "Nirmala Text / Nirmala UI";

      languages = [
        "aa"
        "agr"
        "an"
        "anp"
        "as"
        "ay"
        "ayc"
        "bem"
        "bh"
        "bhb"
        "bho"
        "bi"
        "bn"
        "br"
        "brx"
        "ccp"
        "ch"
        "co"
        "da"
        "de"
        "doi"
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
        "gu"
        "gv"
        "hi"
        "hif"
        "hne"
        "ho"
        "ht"
        "ia"
        "id"
        "ie"
        "io"
        "is"
        "it"
        "kj"
        "kn"
        "kok"
        "kwm"
        "lb"
        "li"
        "lij"
        "mag"
        "mai"
        "mfe"
        "mg"
        "mjw"
        "ml"
        "mr"
        "ms"
        "nb"
        "nds"
        "ne"
        "ng"
        "nl"
        "nn"
        "no"
        "nr"
        "nso"
        "oc"
        "om"
        "or"
        "pa"
        "pap-an"
        "pap-aw"
        "pt"
        "raj"
        "rm"
        "rn"
        "rw"
        "sa"
        "sat"
        "sc"
        "sg"
        "si"
        "sma"
        "smj"
        "sn"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "ta"
        "tcy"
        "te"
        "the"
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
        "sans"
      ];

      vendor = "microsoft";
    };
  };
}
