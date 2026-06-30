{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-symbol";
  fontFamily = "Symbol";

  files = [
    "symbol.ttf"
  ];
}
