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
  fontName = "shuyuan-w01";
  fontChineseName = "仓耳舒圆体W01";
  allowCommercialUse = true;
}
