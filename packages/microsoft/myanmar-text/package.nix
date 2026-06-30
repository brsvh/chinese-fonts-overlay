{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-myanmar-text";
  fontFamily = "Myanmar Text";

  files = [
    "mmrtext.ttf"
    "mmrtextb.ttf"
  ];
}
