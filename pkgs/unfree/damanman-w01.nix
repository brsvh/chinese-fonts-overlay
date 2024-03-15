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
  fontName = "damanman-w01";
  fontChineseName = "仓耳大漫漫体W01";
  allowCommercialUse = false;
}
