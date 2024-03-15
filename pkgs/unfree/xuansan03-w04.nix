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
  fontName = "xuansan03-w04";
  fontChineseName = "仓耳玄三03-W04";
  allowCommercialUse = false;
}
