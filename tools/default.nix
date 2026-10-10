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

      apps = {
        font-ci = {
          type = "app";

          meta = {
            description = "Incremental font CI and preview tools";
          };

          program = "${
            import (projectRoot + /ci) { inherit pkgs; }
          }/bin/font-ci";
        };
      };

      checks = import (projectRoot + /ci/checks.nix) {
        inherit pkgs projectRoot;
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
