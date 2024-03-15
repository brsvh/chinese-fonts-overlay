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
  fontName = "caolulinshouji";
  fontChineseName = "仓耳曹录林手迹";
  allowCommercialUse = false;
}
