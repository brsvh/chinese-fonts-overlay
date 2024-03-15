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
  fontName = "xiaokeai-w02";
  fontChineseName = "仓耳小可爱体W02";
  allowCommercialUse = false;
}
