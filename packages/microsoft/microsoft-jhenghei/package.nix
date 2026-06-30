{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-microsoft-jhenghei";
  fontFamily = "Microsoft JhengHei";

  files = [
    "msjh.ttc"
    "msjhbd.ttc"
    "msjhl.ttc"
  ];
}
