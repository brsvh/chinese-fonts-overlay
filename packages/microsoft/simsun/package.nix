{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-simsun";
  fontFamily = "SimSun";

  files = [
    "simsun.ttc"
    "simsunb.ttf"
    "SimsunExtG.ttf"
  ];
}
