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
  fontName = "jinkai02-w05";
  fontChineseName = "仓耳今楷02-W05";
  allowCommercialUse = false;
}
