{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-courier-new";
  fontFamily = "Courier New";

  files = [
    "cour.ttf"
    "courbd.ttf"
    "courbi.ttf"
    "couri.ttf"
  ];
}
