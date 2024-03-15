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
  fontName = "dudu-w04";
  fontChineseName = "仓耳嘟嘟体W04";
  allowCommercialUse = false;
}
