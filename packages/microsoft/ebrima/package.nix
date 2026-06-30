{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-ebrima";
  fontFamily = "Ebrima";

  files = [
    "ebrima.ttf"
    "ebrimabd.ttf"
  ];
}
