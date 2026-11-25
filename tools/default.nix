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

      languagePkgs = import packageNixpkgs {
        inherit system;
      };

      languageFontconfig = languagePkgs.fontconfig;

      updateFontLanguages =
        pkgs.callPackage
          ./update-font-languages/package.nix
          {
            fontconfig = languageFontconfig;
            freetype = languagePkgs.freetype;
          };

      overlayConfig = {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          self.overlays.default
        ];
      };

      fontPkgs = import packageNixpkgs overlayConfig;

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
          pkgs = import nixpkgs overlayConfig;
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
                lib
                pkgs
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
