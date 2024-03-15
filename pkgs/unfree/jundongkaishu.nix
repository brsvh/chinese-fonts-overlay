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
  fontName = "jundongkaishu";
  fontChineseName = "仓耳俊冬楷书";
  allowCommercialUse = false;
}
