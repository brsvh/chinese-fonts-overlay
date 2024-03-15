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
  fontName = "zhixiangkanzheni";
  fontChineseName = "仓耳只想看着你";
  allowCommercialUse = false;
}
