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

      daisyui = pkgs.fetchurl {
        url = "https://github.com/saadeghi/daisyui/releases/download/v5.7.39/daisyui.mjs";
        sha256 = "69c0fd011966f12b1e3e9f8e43ebddaa937f6c3616f8cb292c2b2ca41a3e1677";
      };

      daisyuiTheme = pkgs.fetchurl {
        url = "https://github.com/saadeghi/daisyui/releases/download/v5.7.39/daisyui-theme.mjs";
        sha256 = "feb72a4414716d3cf10f9e8c092285a3a8e3afa43c1269e752569734d1121f00";
      };

      interfaceFont =
        fontPkgs.tsangertypePackages.tsangeryuyangt;

      interfaceFontLicense = pkgs.fetchurl {
        url = interfaceFont.meta.license.url;
        sha256 = "dd032d62dc79a2b7b4e07b34ebd8e41c68ab943fa590f21a13fe9f649d0ae468";
      };

      interfaceAssets = {
        DAISYUI = daisyui;
        DAISYUI_THEME = daisyuiTheme;
        UI_FONT_REGULAR = "${interfaceFont}/share/fonts/truetype/tsangertype/TsangerYuYangT-W02.ttf";
        UI_FONT_MEDIUM = "${interfaceFont}/share/fonts/truetype/tsangertype/TsangerYuYangT-W03.ttf";
        UI_FONT_LICENSE = interfaceFontLicense;
      };

      siteCore = pkgs.stdenv.mkDerivation (
        interfaceAssets
        // {
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
            mainProgram = "chinese-fonts-overlay-site";
          };

          nativeBuildInputs =
            (with pkgs; [
              autoreconfHook
              guile
              guile-hoot
              makeWrapper
              pkg-config
              tailwindcss_4
            ])
            ++ guileLibraries;

          pname = "chinese-fonts-overlay-site";

          postFixup = ''
            wrapProgram "$out/bin/chinese-fonts-overlay-site" \
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
        }
      );

      site = pkgs.writeTextFile {
        destination = "/bin/chinese-fonts-overlay-site";
        executable = true;
        name = "chinese-fonts-overlay-site";

        text = ''
          #!${getExe pkgs.guile} -s
          !#
          (setenv "CATALOG" "${catalog}")
          (setenv "PREVIEWS_DERIVATION"
                  "${previewsDerivation}")
          (apply execl "${getExe siteCore}" "chinese-fonts-overlay-site"
                 (cdr (command-line)))
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
        site = pkgs.mkShell (
          interfaceAssets
          // {
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
          }
        );
      };
    };
}
