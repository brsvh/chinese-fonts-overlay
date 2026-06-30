{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-verdana";
  fontFamily = "Verdana";

  files = [
    "verdana.ttf"
    "verdanab.ttf"
    "verdanai.ttf"
    "verdanaz.ttf"
  ];
}
