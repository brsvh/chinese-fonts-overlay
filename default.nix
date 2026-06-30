final: prev:
let
  projectRoot = ./.;

  chinese-fonts-overlay-lib =
    import (projectRoot + /lib)
      {
        inherit (prev)
          lib
          ;
      };
in
import (projectRoot + /overlays/default.nix) {
  inherit
    chinese-fonts-overlay-lib
    projectRoot
    ;
} final prev
