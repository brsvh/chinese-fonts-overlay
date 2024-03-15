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
  fontName = "chuangyi-w03";
  fontChineseName = "仓耳创意体W03";
  allowCommercialUse = false;
}
