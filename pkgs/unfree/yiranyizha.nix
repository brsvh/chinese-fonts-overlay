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
  fontName = "yiranyizha";
  fontChineseName = "仓耳易燃易炸体";
  allowCommercialUse = false;
}
