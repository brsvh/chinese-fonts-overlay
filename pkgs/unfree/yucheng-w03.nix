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
  fontName = "yucheng-w03";
  fontChineseName = "仓耳羽辰体W03";
  allowCommercialUse = false;
}
