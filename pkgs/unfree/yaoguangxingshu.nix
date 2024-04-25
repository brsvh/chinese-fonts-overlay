{ callPackage, lib, ... }:
with builtins;
with lib;
let
  mkTsangerTypeFontDerivation = callPackage ../mkTsangerTypeFontDerivation.nix { };
in
mkTsangerTypeFontDerivation {
  fontName = "yaoguangxingshu";
  fontChineseName = "仓耳尧光行书";
  allowCommercialUse = false;
}
