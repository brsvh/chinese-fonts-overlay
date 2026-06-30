{
  inputs,
  projectRoot,
  self,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    systems
    ;
in
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      system,
      ...
    }:
    {
      _module = {
        args = {
          pkgs = import nixpkgs {
            inherit
              system
              ;

            config = {
              allowUnfree = true;
            };

            overlays = [
              self.overlays.default
            ];
          };
        };
      };

      devShells =
        let
          mkDevShell =
            includeFontPreviewTool:
            import
              (projectRoot + /tools/dev-shells/default.nix)
              {
                inherit
                  includeFontPreviewTool
                  lib
                  pkgs
                  projectRoot
                  ;
              };
        in
        {
          default = mkDevShell false;

          generator = mkDevShell true;
        };

      formatter =
        import (projectRoot + /tools/formatter.nix)
          {
            inherit
              config
              lib
              pkgs
              ;
          };
    };

  systems = import systems;
}
