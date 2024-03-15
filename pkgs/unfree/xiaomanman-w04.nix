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
  fontName = "xiaomanman-w04";
  fontChineseName = "仓耳小漫漫体W04";
  allowCommercialUse = false;
}
