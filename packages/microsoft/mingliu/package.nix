{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-mingliu";
  fontFamily = "MingLiU-ExtB";

  files = [
    "mingliub.ttc"
  ];
}
