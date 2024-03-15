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
  fontName = "tuya-w03";
  fontChineseName = "仓耳涂鸦体W03";
  allowCommercialUse = false;
}
