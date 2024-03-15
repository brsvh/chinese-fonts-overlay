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
  fontName = "xiaokeai-w06";
  fontChineseName = "仓耳小可爱体W06";
  allowCommercialUse = false;
}
