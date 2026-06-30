{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-segoe-ui";
  fontFamily = "Segoe UI";

  files = [
    "segoeui.ttf"
    "segoeuib.ttf"
    "segoeuii.ttf"
    "segoeuil.ttf"
    "segoeuisl.ttf"
    "segoeuiz.ttf"
    "seguibl.ttf"
    "seguibli.ttf"
    "seguili.ttf"
    "seguisb.ttf"
    "seguisbi.ttf"
    "seguisli.ttf"
  ];
}
