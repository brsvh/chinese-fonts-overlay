{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-ui-symbols";
  fontFamily = "Segoe UI Symbol";

  files = [
    "seguiemj.ttf"
    "seguihis.ttf"
    "seguisym.ttf"
  ];
}
