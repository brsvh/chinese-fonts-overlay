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
  fontName = "shenqidedoudou";
  fontChineseName = "仓耳神奇的豆豆体";
  allowCommercialUse = false;
}
