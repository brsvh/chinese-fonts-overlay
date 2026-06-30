{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-georgia";
  fontFamily = "Georgia";

  files = [
    "georgia.ttf"
    "georgiab.ttf"
    "georgiai.ttf"
    "georgiaz.ttf"
  ];
}
