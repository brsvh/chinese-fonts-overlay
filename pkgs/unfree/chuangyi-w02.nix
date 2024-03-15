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
  fontName = "chuangyi-w02";
  fontChineseName = "仓耳创意体W02";
  allowCommercialUse = false;
}
