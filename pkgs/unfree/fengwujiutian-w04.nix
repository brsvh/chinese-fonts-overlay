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
  fontName = "fengwujiutian-w04";
  fontChineseName = "仓耳锋舞九天W04";
  allowCommercialUse = false;
}
