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
  fontName = "xuansanm-w01";
  fontChineseName = "仓耳玄三M-W01";
  allowCommercialUse = false;
}
