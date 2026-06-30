{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-leelawadee-ui";
  fontFamily = "Leelawadee UI";

  files = [
    "LeelaUIb.ttf"
    "LeelawUI.ttf"
    "LeelUIsl.ttf"
  ];
}
