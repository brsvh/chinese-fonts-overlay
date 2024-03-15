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
  fontName = "fengwujiutian-w05";
  fontChineseName = "仓耳锋舞九天W05";
  allowCommercialUse = false;
}
