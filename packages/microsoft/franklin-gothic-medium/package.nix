{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-franklin-gothic-medium";
  fontFamily = "Franklin Gothic Medium";

  files = [
    "framd.ttf"
    "framdit.ttf"
  ];
}
