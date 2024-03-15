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
  fontName = "quancunzuikeai";
  fontChineseName = "仓耳全村最可爱";
  allowCommercialUse = false;
}
