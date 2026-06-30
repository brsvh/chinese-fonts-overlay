{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-consolas";
  fontFamily = "Consolas";

  files = [
    "consola.ttf"
    "consolab.ttf"
    "consolai.ttf"
    "consolaz.ttf"
  ];
}
