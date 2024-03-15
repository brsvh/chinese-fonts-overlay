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
  fontName = "mengxingdelibie";
  fontChineseName = "仓耳梦醒的离别体";
  allowCommercialUse = false;
}
