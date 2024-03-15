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
  fontName = "xiaomanman-w01";
  fontChineseName = "仓耳小漫漫体W01";
  allowCommercialUse = false;
}
