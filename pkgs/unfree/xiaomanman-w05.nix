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
  fontName = "xiaomanman-w05";
  fontChineseName = "仓耳小漫漫体W05";
  allowCommercialUse = false;
}
