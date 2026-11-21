{
  inputs,
  packageNixpkgs,
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
    let
      languageFontconfig =
        (import packageNixpkgs { inherit system; })
        .fontconfig;

      updateFontLanguages =
        pkgs.callPackage
          ./update-font-languages/package.nix
          {
            fontconfig = languageFontconfig;
          };
    in
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
        update-font-languages = {
          type = "app";
          program = lib.getExe updateFontLanguages;
          meta = {
            description = "Scan and maintain font package languages";
          };
        };

        font-ci = {
          type = "app";

          meta = {
            description = "Incremental font builds and cache publication";
          };

          program = "${
            import (projectRoot + /ci) { inherit pkgs; }
          }/bin/font-ci";
        };
      };

      devShells = {
        default =
          import
            (projectRoot + /tools/dev-shells/default.nix)
            {
              inherit
                lib
                pkgs
                projectRoot
                updateFontLanguages
                languageFontconfig
                ;
            };
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
