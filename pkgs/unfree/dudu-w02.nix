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
  fontName = "dudu-w02";
  fontChineseName = "仓耳嘟嘟体W02";
  allowCommercialUse = false;
}
