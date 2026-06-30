{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-webdings";
  fontFamily = "Webdings";

  files = [
    "webdings.ttf"
  ];
}
