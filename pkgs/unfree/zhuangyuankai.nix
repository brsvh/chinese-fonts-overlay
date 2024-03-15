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
  fontName = "zhuangyuankai";
  fontChineseName = "仓耳状元楷";
  allowCommercialUse = false;
}
