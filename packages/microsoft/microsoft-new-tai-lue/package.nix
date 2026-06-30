{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-microsoft-new-tai-lue";
  fontFamily = "Microsoft New Tai Lue";

  files = [
    "ntailu.ttf"
    "ntailub.ttf"
  ];
}
