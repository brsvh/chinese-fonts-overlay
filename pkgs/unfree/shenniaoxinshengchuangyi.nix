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
  fontName = "shenniaoxinshengchuangyi";
  fontChineseName = "神鸟新生创意体";
  allowCommercialUse = false;
}
