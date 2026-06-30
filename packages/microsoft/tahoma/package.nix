{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-tahoma";
  fontFamily = "Tahoma";

  files = [
    "tahoma.ttf"
    "tahomabd.ttf"
  ];
}
