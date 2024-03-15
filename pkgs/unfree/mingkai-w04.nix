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
  fontName = "mingkai-w04";
  fontChineseName = "仓耳明楷W04";
  allowCommercialUse = false;
}
