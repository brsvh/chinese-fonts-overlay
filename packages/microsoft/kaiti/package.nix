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
}
