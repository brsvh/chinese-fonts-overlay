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
  fontName = "feifei-w03";
  fontChineseName = "仓耳飞飞体W03";
  allowCommercialUse = false;
}
