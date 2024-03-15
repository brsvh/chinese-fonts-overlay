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
  fontName = "dudu-w03";
  fontChineseName = "仓耳嘟嘟体W03";
  allowCommercialUse = false;
}
