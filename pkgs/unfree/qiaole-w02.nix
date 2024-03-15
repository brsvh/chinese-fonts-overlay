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
  fontName = "qiaole-w02";
  fontChineseName = "仓耳巧乐体W02";
  allowCommercialUse = false;
}
