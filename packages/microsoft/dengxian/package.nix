{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-dengxian";
  fontFamily = "DengXian";

  files = [
    "Deng.ttf"
    "Dengb.ttf"
    "Dengl.ttf"
  ];
}
