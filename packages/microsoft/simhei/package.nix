{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-simhei";
  fontFamily = "SimHei";

  files = [
    "simhei.ttf"
  ];
}
