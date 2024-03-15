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
  fontName = "feifei-w01";
  fontChineseName = "仓耳飞飞体W01";
  allowCommercialUse = false;
}
