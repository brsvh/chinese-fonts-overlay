{
  packageNixpkgs,
  projectRoot,
  self,
  ...
}:
{
  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    let
      inherit (builtins)
        unsafeDiscardOutputDependency
        ;

      inherit (lib)
        concatMapStringsSep
        getExe
        makeBinPath
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

      catalogData = import ./catalog.nix {
        inherit projectRoot;

        pkgs = fontPkgs;
      };

      catalog = pkgs.writeText "font-catalog.json" (
        toJSON catalogData
      );

      previews = pkgs.writeText "font-previews.json" (
        toJSON (
          import ./previews.nix {
            catalog = catalogData;
            pkgs = fontPkgs;
          }
        )
      );

      previewsDerivation = unsafeDiscardOutputDependency previews.drvPath;

      guileLibraries = with pkgs; [
        guile-gcrypt
        guile-json
      ];

      modulePath = concatMapStringsSep ":" (
        package: "${package}/share/guile/site/3.0"
      ) guileLibraries;

      siteCore = pkgs.stdenv.mkDerivation {
        buildInputs = with pkgs; [
          cairo
          fontconfig
          freetype
          glib
          guile
          pango
        ];

        doCheck = true;

        meta = {
          mainProgram = "font-site";
        };

        nativeBuildInputs =
          (with pkgs; [
            autoreconfHook
            guile
            guile-hoot
            makeWrapper
            pkg-config
          ])
          ++ guileLibraries;

        pname = "chinese-fonts-site";

        postFixup = ''
          wrapProgram "$out/bin/font-site" \
            --prefix GUILE_LOAD_PATH : '${modulePath}' \
            --prefix PATH : '${
              makeBinPath [
                fontPkgs.fontconfig
                pkgs.git
                pkgs.nix
              ]
            }' \
            --set GUILE_AUTO_COMPILE 0
        '';

        src = lib.fileset.toSource {
          fileset = lib.fileset.unions [
            ./Makefile.am
            ./README
            ./bootstrap
            ./build-aux
            ./configure.ac
            ./data
            ./m4
            ./module
            ./scripts
            ./src
            ./tests
            ./web
          ];

          root = ./.;
        };

        version = "0.1.0";
      };

      site = pkgs.writeTextFile {
        destination = "/bin/font-site";
        executable = true;
        name = "font-site";

        text = ''
          #!${getExe pkgs.guile} -s
          !#
          (setenv "CATALOG" "${catalog}")
          (setenv "PREVIEWS_DERIVATION"
                  "${previewsDerivation}")
          (apply execl "${getExe siteCore}" "font-site" (cdr (command-line)))
        '';
      };
    in
    {
      apps = {
        site = {
          meta = {
            description = "Build and serve the local font preview site";
          };

          program = getExe site;
          type = "app";
        };
      };

      devShells = {
        site = pkgs.mkShell {
          CATALOG = catalog;
          # Realize font outputs when generating previews, not on shell entry.
          PREVIEWS_DERIVATION = previewsDerivation;

          inputsFrom = [
            siteCore
          ];

          packages = with pkgs; [
            autoconf
            automake
            fontPkgs.fontconfig
            git
            site
          ];
        };
      };
    };
}
