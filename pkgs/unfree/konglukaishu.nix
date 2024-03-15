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
  fontName = "konglukaishu";
  fontChineseName = "仓耳孔璐楷书";
  allowCommercialUse = false;
}
