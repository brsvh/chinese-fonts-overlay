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
  fontName = "shuyuan-w04";
  fontChineseName = "仓耳舒圆体W04";
  allowCommercialUse = true;
}
