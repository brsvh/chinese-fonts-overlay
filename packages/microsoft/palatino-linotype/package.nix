{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-palatino-linotype";
  fontFamily = "Palatino Linotype";

  files = [
    "pala.ttf"
    "palab.ttf"
    "palabi.ttf"
    "palai.ttf"
  ];
}
