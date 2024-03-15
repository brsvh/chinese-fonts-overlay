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
  fontName = "chuangyi-w01";
  fontChineseName = "仓耳创意体W01";
  allowCommercialUse = false;
}
