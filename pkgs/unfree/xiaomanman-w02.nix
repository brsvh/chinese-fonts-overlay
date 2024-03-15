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
  fontName = "xiaomanman-w02";
  fontChineseName = "仓耳小漫漫体W02";
  allowCommercialUse = false;
}
