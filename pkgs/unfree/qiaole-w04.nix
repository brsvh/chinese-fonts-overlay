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
  fontName = "qiaole-w04";
  fontChineseName = "仓耳巧乐体W04";
  allowCommercialUse = false;
}
