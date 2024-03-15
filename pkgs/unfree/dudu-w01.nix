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
  fontName = "dudu-w01";
  fontChineseName = "仓耳嘟嘟体W01";
  allowCommercialUse = false;
}
