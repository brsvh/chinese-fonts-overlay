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
  fontName = "xiaokeai-w03";
  fontChineseName = "仓耳小可爱体W03";
  allowCommercialUse = false;
}
