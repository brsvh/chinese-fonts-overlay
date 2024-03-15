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
  fontName = "yihei-w05";
  fontChineseName = "仓耳逸黑W05";
  allowCommercialUse = false;
}
