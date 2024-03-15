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
  fontName = "yuyang-w01";
  fontChineseName = "仓耳渔阳体W01";
  allowCommercialUse = true;
}
