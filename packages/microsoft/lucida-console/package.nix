{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-lucida-console";
  fontFamily = "Lucida Console";

  files = [
    "lucon.ttf"
  ];
}
