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
  fontName = "qiedoudou";
  fontChineseName = "仓耳企鹅豆豆体";
  allowCommercialUse = false;
}
