{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "qingfengxieyang";
  fontChineseName = "仓耳轻风斜阳体";
  allowCommercialUse = false;
}
