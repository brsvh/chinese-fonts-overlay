{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-cambria";
  fontFamily = "Cambria";

  files = [
    "cambria.ttc"
    "cambriab.ttf"
    "cambriai.ttf"
    "cambriaz.ttf"
  ];
}
