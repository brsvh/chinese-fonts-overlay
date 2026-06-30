{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-script";
  fontFamily = "Segoe Script";

  files = [
    "segoesc.ttf"
    "segoescb.ttf"
  ];
}
