{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-icons";
  fontFamily = "Segoe Fluent Icons";

  files = [
    "SegoeIcons.ttf"
    "segmdl2.ttf"
  ];
}
