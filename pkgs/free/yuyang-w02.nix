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
  fontName = "yuyang-w02";
  fontChineseName = "仓耳渔阳体W02";
  allowCommercialUse = true;
}
