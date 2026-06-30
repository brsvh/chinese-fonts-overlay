{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-fangsong";
  fontFamily = "FangSong";

  files = [
    "simfang.ttf"
  ];
}
