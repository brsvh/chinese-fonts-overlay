{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-malgun-gothic";
  fontFamily = "Malgun Gothic";

  files = [
    "malgun.ttf"
    "malgunbd.ttf"
    "malgunsl.ttf"
  ];
}
