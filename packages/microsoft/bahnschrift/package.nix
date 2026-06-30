{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-bahnschrift";
  fontFamily = "Bahnschrift";

  files = [
    "bahnschrift.ttf"
  ];
}
