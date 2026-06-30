{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-marlett";
  fontFamily = "Marlett";

  files = [
    "marlett.ttf"
  ];
}
