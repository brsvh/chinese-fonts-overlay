{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-ms-gothic";
  fontFamily = "MS Gothic";

  files = [
    "msgothic.ttc"
  ];
}
