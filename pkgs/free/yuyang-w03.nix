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
  fontName = "yuyang-w03";
  fontChineseName = "仓耳渔阳体W03";
  allowCommercialUse = true;
}
