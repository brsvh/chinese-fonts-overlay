{ callPackage
, lib
, ...
}:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation
{
  fontName = "aiminxingkai";
  fontChineseName = "仓耳爱民行楷";
  allowCommercialUse = false;
}
