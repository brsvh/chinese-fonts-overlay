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
  fontName = "qiaole-w03";
  fontChineseName = "仓耳巧乐体W03";
  allowCommercialUse = false;
}
