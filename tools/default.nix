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
        filterAttrs
        getExe
        hasSuffix
        mapAttrs'
        nameValuePair
        pathExists
        pipe
        readDir
        removeSuffix
        ;

      baseFontPkgs = import packageNixpkgs {
        inherit system;
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

      languageFontconfig = baseFontPkgs.fontconfig;

      checksDirectory = projectRoot + /tools/checks;

      checkArguments = {
        inherit
          fontPkgs
          lib
          pkgs
          projectRoot
          ;
      };

      isCheckEntry =
        name: type:
        (type == "regular" && hasSuffix ".nix" name)
        || (
          type == "directory"
          && pathExists (
            checksDirectory + "/${name}/default.nix"
          )
        );

      loadCheck =
        name: type:
        let
          checkName =
            if type == "regular" then
              removeSuffix ".nix" name
            else
              name;

          path =
            if type == "regular" then
              checksDirectory + "/${name}"
            else
              checksDirectory + "/${name}/default.nix";
        in
        nameValuePair checkName (
          import path checkArguments
        );

      updateFontLanguages =
        pkgs.callPackage
          ./update-font-languages/package.nix
          {
            inherit (baseFontPkgs)
              fontconfig
              freetype
              pkg-config
              stdenv
              ;
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

      checks = pipe (readDir checksDirectory) [
        (filterAttrs isCheckEntry)
        (mapAttrs' loadCheck)
      ];

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
