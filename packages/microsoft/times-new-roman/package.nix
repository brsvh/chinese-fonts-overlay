{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-times-new-roman";
  fontFamily = "Times New Roman";

  files = [
    "times.ttf"
    "timesbd.ttf"
    "timesbi.ttf"
    "timesi.ttf"
  ];
}
