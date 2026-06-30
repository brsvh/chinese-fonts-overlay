{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-sitka";
  fontFamily = "Sitka";

  files = [
    "SitkaVF.ttf"
    "SitkaVF-Italic.ttf"
  ];
}
