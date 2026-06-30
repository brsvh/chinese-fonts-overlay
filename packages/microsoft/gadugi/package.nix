{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-gadugi";
  fontFamily = "Gadugi";

  files = [
    "gadugi.ttf"
    "gadugib.ttf"
  ];
}
