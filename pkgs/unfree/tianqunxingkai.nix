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
  fontName = "tianqunxingkai";
  fontChineseName = "仓耳天群行楷";
  allowCommercialUse = false;
}
