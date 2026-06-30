{
  mkMicrosoftFontDerivation,
  ...
}:
mkMicrosoftFontDerivation {
  pname = "microsoft-yu-gothic";
  fontFamily = "Yu Gothic";

  files = [
    "YuGothB.ttc"
    "YuGothL.ttc"
    "YuGothM.ttc"
    "YuGothR.ttc"
  ];
}
