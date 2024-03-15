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
  fontName = "qiaole-w01";
  fontChineseName = "仓耳巧乐体W01";
  allowCommercialUse = false;
}
