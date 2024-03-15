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
  fontName = "xuansan04-w02";
  fontChineseName = "仓耳玄三04-W02";
  allowCommercialUse = false;
}
