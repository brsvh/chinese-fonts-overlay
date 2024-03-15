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
  fontName = "fengyun-w05";
  fontChineseName = "仓耳锋韵W05";
  allowCommercialUse = false;
}
