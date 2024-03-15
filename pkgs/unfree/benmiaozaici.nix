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
  fontName = "benmiaozaici";
  fontChineseName = "仓耳本喵在此体";
  allowCommercialUse = false;
}
