{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-constantia";
  fontFamily = "Constantia";

  files = [
    "constan.ttf"
    "constanb.ttf"
    "constani.ttf"
    "constanz.ttf"
  ];
}
