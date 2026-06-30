{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-print";
  fontFamily = "Segoe Print";

  files = [
    "segoepr.ttf"
    "segoeprb.ttf"
  ];
}
