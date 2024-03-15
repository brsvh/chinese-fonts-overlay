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
  fontName = "yiyechunfeng";
  fontChineseName = "仓耳一夜春风体";
  allowCommercialUse = false;
}
