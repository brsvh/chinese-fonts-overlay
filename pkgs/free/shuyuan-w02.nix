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
  fontName = "shuyuan-w02";
  fontChineseName = "仓耳舒圆体W02";
  allowCommercialUse = true;
}
