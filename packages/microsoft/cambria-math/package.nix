{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-cambria-math";
  fontFamily = "Cambria Math";

  files = [
    "cambria.ttc"
  ];
}
