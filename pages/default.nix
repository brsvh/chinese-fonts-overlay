{
  packageNixpkgs,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      fontPkgs = import packageNixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          self.overlays.default
        ];
      };

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
        UI_FONT_LICENSE = interfaceFontLicense;
        UI_FONT_MEDIUM = "${interfaceFont}/share/fonts/truetype/tsangertype/TsangerYuYangT-W03.ttf";
        UI_FONT_REGULAR = "${interfaceFont}/share/fonts/truetype/tsangertype/TsangerYuYangT-W02.ttf";
      };
    in
    {
      devShells = {
        manual = pkgs.mkShell {
          packages = with pkgs; [
            git
            gnumake
            guile
            guile-gcrypt
            guile-json
            nix
            texinfoInteractive
          ];
        };

        pages = pkgs.mkShell (
          interfaceAssets
          // {
            buildInputs = with pkgs; [
              cairo
              fontconfig
              freetype
              glib
              guile
              libwebp
              pango
            ];

            packages = with pkgs; [
              git
              gnumake
              gnutar
              guile-gcrypt
              guile-hoot
              guile-json
              gzip
              nix
              pkg-config
              tailwindcss_4
              texinfo
            ];
          }
        );
      };
    };
}
