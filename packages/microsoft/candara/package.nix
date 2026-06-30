{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-candara";
  fontFamily = "Candara";

  files = [
    "Candara.ttf"
    "Candarab.ttf"
    "Candarai.ttf"
    "Candaral.ttf"
    "Candarali.ttf"
    "Candaraz.ttf"
  ];
}
