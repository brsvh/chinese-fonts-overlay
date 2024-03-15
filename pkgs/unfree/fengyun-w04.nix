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
  fontName = "fengyun-w04";
  fontChineseName = "仓耳锋韵W04";
  allowCommercialUse = false;
}
