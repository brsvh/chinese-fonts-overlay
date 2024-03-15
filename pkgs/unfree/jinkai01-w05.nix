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
  fontName = "jinkai01-w05";
  fontChineseName = "仓耳今楷01-W05";
  allowCommercialUse = false;
}
