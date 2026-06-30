{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-corbel";
  fontFamily = "Corbel";

  files = [
    "corbel.ttf"
    "corbelb.ttf"
    "corbeli.ttf"
    "corbell.ttf"
    "corbelli.ttf"
    "corbelz.ttf"
  ];
}
