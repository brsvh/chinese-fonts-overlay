{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-arial";
  fontFamily = "Arial";

  files = [
    "arial.ttf"
    "arialbd.ttf"
    "arialbi.ttf"
    "ariali.ttf"
    "ariblk.ttf"
  ];
}
