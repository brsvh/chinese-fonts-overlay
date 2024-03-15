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
  fontName = "siyecaodexingfu";
  fontChineseName = "仓耳四叶草的幸福体";
  allowCommercialUse = false;
}
