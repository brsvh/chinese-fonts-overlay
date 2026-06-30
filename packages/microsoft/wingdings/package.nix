{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-wingdings";
  fontFamily = "Wingdings";

  files = [
    "wingding.ttf"
  ];
}
