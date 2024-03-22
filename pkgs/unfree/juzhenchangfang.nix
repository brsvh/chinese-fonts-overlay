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
  fontName = "juzhenchangfang";
  fontChineseName = "仓耳聚珍长仿";
  allowCommercialUse = false;
}
