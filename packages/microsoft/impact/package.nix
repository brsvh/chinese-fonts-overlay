{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-impact";
  fontFamily = "Impact";

  files = [
    "impact.ttf"
  ];
}
