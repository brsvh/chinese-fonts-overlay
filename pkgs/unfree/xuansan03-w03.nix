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
  fontName = "xuansan03-w03";
  fontChineseName = "仓耳玄三03-W03";
  allowCommercialUse = false;
}
