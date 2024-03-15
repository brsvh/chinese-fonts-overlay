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
  fontName = "tianmu-w05";
  fontChineseName = "仓耳天沐体W05";
  allowCommercialUse = false;
}
