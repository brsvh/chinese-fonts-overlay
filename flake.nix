{
  description = "tsangertype-fonts - Tsangertype Fonts.";

  nixConfig = {
    allowUnfree = true;

    experimental-features = [
      "flakes"
      "nix-command"
      "repl-flake"
    ];
  };

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts/main";
      inputs = {
        nixpkgs-lib = {
          follows = "nixpkgs";
        };
      };
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    treefmt = {
      url = "github:numtide/treefmt-nix/main";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      self,
      treefmt,
      ...
    }@inputs:
    with builtins;
    with nixpkgs.lib;
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-parts.flakeModules.easyOverlay
        treefmt.flakeModule
      ];

      perSystem =
        {
          final,
          pkgs,
          system,
          ...
        }:
        let
          inherit (final) symlinkJoin;

          getFonts = ol: intersectAttrs (ol 42 42) final;

          freeFonts = getFonts self.overlays.free;

          unfreeFonts = getFonts self.overlays.unfree;

          allFonts = freeFonts // unfreeFonts;

          getAvailableDerivation = drv: (isDerivation drv) && (meta.availableOn { inherit system; } drv);

          tsangertype-free-fonts = symlinkJoin rec {
            name = "${pname}-${version}";
            paths = filter getAvailableDerivation (attrValues freeFonts);
            pname = "tsangertype-free-fonts";
            version = import ./version.nix;
          };

          tsangertype-unfree-fonts = symlinkJoin rec {
            name = "${pname}-${version}";
            paths = filter getAvailableDerivation (attrValues unfreeFonts);
            pname = "tsangertype-unfree-fonts";
            version = import ./version.nix;
          };

          tsangertype-fonts = symlinkJoin rec {
            name = "${pname}-${version}";
            paths = filter getAvailableDerivation (attrValues allFonts);
            pname = "tsangertype-fonts";
            version = import ./version.nix;
          };
        in
        {
          _module = {
            args = {
              config = {
                allowUnfree = true;
              };
            };
          };

          overlayAttrs =
            (self.overlays.free final pkgs)
            // (self.overlays.unfree final pkgs)
            // {
              inherit tsangertype-fonts tsangertype-free-fonts tsangertype-unfree-fonts;
            };

          packages =
            let
              fonts = getFonts self.overlays.default;
            in
            allFonts
            // {
              inherit tsangertype-fonts tsangertype-free-fonts tsangertype-unfree-fonts;

              default = tsangertype-fonts;
            };

          treefmt = {
            flakeFormatter = true;
            projectRootFile = "flake.nix";

            programs = {
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
            };
          };
        };

      flake = {
        overlays = {
          free = import ./pkgs/free;
          unfree = import ./pkgs/unfree;
        };
      };

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    };
}
