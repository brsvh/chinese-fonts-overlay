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
  fontName = "xiayizhanxingfu";
  fontChineseName = "仓耳下一站幸福体";
  allowCommercialUse = false;
}
