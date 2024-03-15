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
  fontName = "caozhebinkaishu";
  fontChineseName = "仓耳曹哲斌楷书";
  allowCommercialUse = false;
}
