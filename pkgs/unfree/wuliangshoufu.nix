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
  fontName = "wuliangshoufu";
  fontChineseName = "仓耳无量寿福体";
  allowCommercialUse = false;
}
