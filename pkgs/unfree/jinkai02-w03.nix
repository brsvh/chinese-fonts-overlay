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
  fontName = "jinkai02-w03";
  fontChineseName = "仓耳今楷02-W03";
  allowCommercialUse = false;
}
