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
  fontName = "jinkai05-w01";
  fontChineseName = "仓耳今楷05-W01";
  allowCommercialUse = false;
}
