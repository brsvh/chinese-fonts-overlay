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

      fontPkgs = import packageNixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          self.overlays.default
        ];
      };

      fontCatalog =
        import (projectRoot + /site/catalog.nix)
          {
            inherit projectRoot;
            pkgs = fontPkgs;
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

        ci = {
          type = "app";

          meta = {
            description = "Font build planning and publication records";
          };

          program = "${
            import (projectRoot + /ci) { inherit pkgs; }
          }/bin/chinese-fonts-overlay-ci";
        };
      };

      checks = {
        font-metadata = pkgs.writeText "font-metadata.json" (
          builtins.toJSON fontCatalog
        );
      };

      devShells = {
        ci = pkgs.mkShell {
          packages = with pkgs; [
            awscli2
            git
            gnutar
            guile
            guile-gcrypt
            guile-json
            gzip
            nix
            nodejs
          ];
        };
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
