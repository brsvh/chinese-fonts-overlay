{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-trebuchet-ms";
  fontFamily = "Trebuchet MS";

  files = [
    "trebuc.ttf"
    "trebucbd.ttf"
    "trebucbi.ttf"
    "trebucit.ttf"
  ];
}
