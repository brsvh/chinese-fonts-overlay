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
  fontName = "chengshishangkongdefanxing";
  fontChineseName = "城市上空的繁星体";
  allowCommercialUse = false;
}
