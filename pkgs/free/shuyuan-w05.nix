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
  fontName = "shuyuan-w05";
  fontChineseName = "仓耳舒圆体W05";
  allowCommercialUse = true;
}
