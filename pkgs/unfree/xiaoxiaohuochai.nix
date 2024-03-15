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
  fontName = "xiaoxiaohuochai";
  fontChineseName = "仓耳小小火柴体";
  allowCommercialUse = false;
}
