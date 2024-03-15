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
  fontName = "yuanqimanmandeqingchun";
  fontChineseName = "仓耳元气满满的青春体";
  allowCommercialUse = false;
}
