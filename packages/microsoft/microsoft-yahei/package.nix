{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-microsoft-yahei";
  fontFamily = "Microsoft YaHei";

  files = [
    "msyh.ttc"
    "msyhbd.ttc"
    "msyhl.ttc"
  ];
}
