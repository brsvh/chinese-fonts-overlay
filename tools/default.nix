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
      inherit (lib)
        getExe
        toJSON
        ;

      fontPkgs = import packageNixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          self.overlays.default
        ];
      };

      languageFontconfig = fontPkgs.fontconfig;

      updateFontLanguages =
        pkgs.callPackage
          ./update-font-languages/package.nix
          {
            fontconfig = languageFontconfig;
            freetype = fontPkgs.freetype;
            pkg-config = fontPkgs.pkg-config;
            stdenv = fontPkgs.stdenv;
          };

      fontCatalog =
        import (projectRoot + /packages/font-catalog.nix)
          {
            inherit projectRoot;
            pkgs = fontPkgs;
          };
    in
    {
      _module = {
        args = {
          pkgs = import nixpkgs {
            inherit system;

            config = {
              allowUnfree = true;
            };
          };
        };
      };

      apps = {
        ci = {
          meta = {
            description = "Font build planning and publication records";
          };

          program = "${
            import (projectRoot + /ci) { inherit pkgs; }
          }/bin/chinese-fonts-overlay-ci";
          type = "app";
        };

        update-font-languages = {
          meta = {
            description = "Scan and maintain font package languages";
          };

          program = getExe updateFontLanguages;
          type = "app";
        };
      };

      checks = {
        font-metadata = pkgs.writeText "font-metadata.json" (
          toJSON fontCatalog
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
                languageFontconfig
                lib
                pkgs
                updateFontLanguages
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
