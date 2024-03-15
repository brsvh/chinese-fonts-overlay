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
  fontName = "xiaokeai-w01";
  fontChineseName = "仓耳小可爱体W01";
  allowCommercialUse = false;
}
