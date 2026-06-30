{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-sylfaen";
  fontFamily = "Sylfaen";

  files = [
    "sylfaen.ttf"
  ];
}
