{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-kaiti";
  fontFamily = "KaiTi";

  files = [
    "simkai.ttf"
  ];

  meta = {
    homepage = "https://learn.microsoft.com/en-us/typography/font-list/kaiti";
  };

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "楷体";

      languages = [
        "agr"
        "bem"
        "bg"
        "cmn"
        "fj"
        "hak"
        "ho"
        "ia"
        "io"
        "kj"
        "kum"
        "kwm"
        "lzh"
        "mhr"
        "ms"
        "ng"
        "nr"
        "om"
        "os"
        "rn"
        "ru"
        "rw"
        "sel"
        "sn"
        "ss"
        "st"
        "sw"
        "ts"
        "uz"
        "xh"
        "za"
        "zh-cn"
        "zh-sg"
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
        "kai"
      ];

      vendor = "microsoft";
    };
  };
}
