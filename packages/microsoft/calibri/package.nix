{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-calibri";
  fontFamily = "Calibri";

  files = [
    "calibri.ttf"
    "calibrib.ttf"
    "calibrii.ttf"
    "calibril.ttf"
    "calibrili.ttf"
    "calibriz.ttf"
  ];
}
