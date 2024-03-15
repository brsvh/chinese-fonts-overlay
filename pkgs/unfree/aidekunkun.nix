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
  fontName = "aidekunkun";
  fontChineseName = "仓耳爱的坤坤体";
  allowCommercialUse = false;
}
