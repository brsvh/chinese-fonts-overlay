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
  fontName = "zhoukezhengdabangshu";
  fontChineseName = "仓耳周珂正大榜书";
  allowCommercialUse = true;
}
