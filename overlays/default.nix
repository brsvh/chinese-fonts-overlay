final: prev:
let
  inherit (prev)
    callPackage
    ;

  inherit (prev.lib)
    attrByPath
    ;

  licenseShortName =
    drv:
    attrByPath [
      "meta"
      "license"
      "shortName"
    ] "unknown" drv;
in
rec {
  alibaba-fonts = alibabaFonts.combine' "alibaba-fonts" (v: true);

  alibabaFonts = callPackage ../packages/alibaba-fonts/package.nix { };

  foundertype-fonts = foundertypeFonts.combine' "foundertype-fonts" (v: true);

  foundertypeFonts = callPackage ../packages/foundertype-fonts/package.nix { };

  TH-fonts = THFonts.combine' "TH-fonts" (v: true);

  THFonts = callPackage ../packages/TH-fonts/package.nix { };

  tsangertype-gpc-fonts = tsangertypeFonts.combine' "tsangertype-gpc-fonts" (
    v: (licenseShortName v) == "tsangertype-gpc-license"
  );

  tsangertype-gpp-fonts = tsangertypeFonts.combine' "tsangertype-gpp-fonts" (
    v: (licenseShortName v) == "tsangertype-gpp-license"
  );

  tsangertype-fonts = tsangertypeFonts.combine' "tsangertype-fonts" (v: true);

  tsangertypeFonts = callPackage ../packages/tsangertype-fonts/package.nix { };

  trionestype-fonts = trionestypeFonts.combine' "trionestype-fonts" (v: true);

  trionestypeFonts = callPackage ../packages/trionestype-fonts/package.nix { };

  windows-fonts = callPackage ../packages/windows-fonts/package.nix { };
}
