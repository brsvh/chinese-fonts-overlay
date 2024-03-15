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
  fontName = "tianmu-w04";
  fontChineseName = "仓耳天沐体W04";
  allowCommercialUse = false;
}
