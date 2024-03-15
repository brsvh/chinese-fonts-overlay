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
  fontName = "mengbaokeji";
  fontChineseName = "仓耳萌宝柯基体";
  allowCommercialUse = false;
}
