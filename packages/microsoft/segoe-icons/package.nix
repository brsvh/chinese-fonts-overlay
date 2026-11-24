{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-icons";
  fontFamily = "Segoe Fluent Icons";

  files = [
    "SegoeIcons.ttf"
    "segmdl2.ttf"
  ];

  meta = {
    homepage = [
      "https://learn.microsoft.com/en-us/windows/apps/design/style/segoe-fluent-icons-font"
      "https://learn.microsoft.com/en-us/windows/apps/design/style/segoe-ui-symbol-font"
    ];
  };

  passthru = {
    chinese-fonts-overlay-pages = {
      displayName = "Segoe Fluent Icons / Segoe MDL2 Assets";

      languages = [ ];

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
        "symbol"
      ];

      vendor = "microsoft";
    };
  };
}
