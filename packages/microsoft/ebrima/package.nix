{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-ebrima";
  fontFamily = "Ebrima";

  files = [
    "ebrima.ttf"
    "ebrimabd.ttf"
  ];

  meta = {
    homepage = "https://learn.microsoft.com/en-us/typography/font-list/ebrima";
  };

  passthru = {
    chinese-fonts-overlay-site = {
      displayName = "Ebrima";

      languages = [
        "aa"
        "af"
        "agr"
        "ak"
        "am"
        "an"
        "ast"
        "ay"
        "ayc"
        "az-az"
        "bax"
        "bem"
        "ber-dz"
        "ber-ma"
        "bi"
        "bin"
        "bm"
        "br"
        "bs"
        "byn"
        "ca"
        "ch"
        "co"
        "crh"
        "cs"
        "csb"
        "cy"
        "da"
        "de"
        "dsb"
        "ee"
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
        "gez"
        "gl"
        "gn"
        "gv"
        "ha"
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
        "io"
        "is"
        "it"
        "kab"
        "ki"
        "kj"
        "kr"
        "ku-tr"
        "kw"
        "kwm"
        "la"
        "lb"
        "lg"
        "li"
        "lij"
        "ln"
        "lt"
        "lv"
        "mfe"
        "mg"
        "mh"
        "mi"
        "miq"
        "mjw"
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
        "nqo"
        "nr"
        "nso"
        "nv"
        "ny"
        "oc"
        "om"
        "pap-an"
        "pap-aw"
        "pl"
        "pt"
        "rif"
        "rm"
        "rn"
        "ro"
        "rw"
        "sc"
        "se"
        "sg"
        "sgs"
        "shs"
        "sid"
        "sk"
        "sl"
        "sma"
        "smj"
        "smn"
        "sms"
        "sn"
        "so"
        "sq"
        "ss"
        "st"
        "sv"
        "sw"
        "szl"
        "ti-er"
        "ti-et"
        "tig"
        "tk"
        "tn"
        "tpi"
        "tr"
        "ts"
        "tw"
        "ty"
        "unm"
        "uz"
        "vai"
        "ve"
        "vo"
        "vot"
        "wa"
        "wae"
        "wal"
        "wen"
        "wo"
        "xh"
        "yap"
        "yo"
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
