{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-noto-sans-sc";
  fontFamily = "Noto Sans SC";

  files = [
    "NotoSansSC-VF.ttf"
  ];
}
