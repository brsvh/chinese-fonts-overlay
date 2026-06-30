{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-javanese-text";
  fontFamily = "Javanese Text";

  files = [
    "javatext.ttf"
  ];
}
