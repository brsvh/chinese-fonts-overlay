{
  lib,
  newScope,
  stdenvNoCC,
  xorg,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    filterAttrs
    isDerivation
    makeScope
    ;
in
makeScope newScope (
  self:
  let
    inherit (self)
      callPackage
      ;

    fonts = {
      puhuiti-2 = callPackage ./puhuiti-2.nix { };

      puhuiti-3 = callPackage ./puhuiti-3.nix { };
    };

    combine' =
      name: cond:
      let
        drvs = attrValues (filterAttrs (n: v: isDerivation v && (cond v)) fonts);
      in
      stdenvNoCC.mkDerivation {
        pname = name;

        version = "0-unstable";

        buildInputs = [
          xorg.lndir
        ] ++ drvs;

        unpackPhase = "true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          for drv in ${concatStringsSep " " drvs}; do
            ${xorg.lndir}/bin/lndir -silent $drv $out
          done

          runHook postInstall
        '';
      };

    combine = cond: combine' "alibaba-combined-fonts" cond;
  in
  fonts
  // {
    inherit
      combine
      combine'
      ;
  }
)
