{
  description = "tsangertype-fonts - Tsangertype Fonts.";

  nixConfig =
    {
      allowUnfree = true;

      experimental-features =
        [
          "flakes"
          "nix-command"
          "repl-flake"
        ];
    };

  inputs =
    {
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
    { flake-parts
    , nixpkgs
    , self
    , treefmt
    , ...
    } @ inputs:
      with builtins;
      with nixpkgs.lib;
      flake-parts.lib.mkFlake
        { inherit inputs; }
        {
          imports =
            [
              flake-parts.flakeModules.easyOverlay
              treefmt.flakeModule
            ];

          perSystem =
            { final
            , pkgs
            , system
            , ...
            }:
            let
              inherit (final) symlinkJoin;
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
                (self.overlays.free final pkgs) //
                (self.overlays.unfree final pkgs);

              packages =
                let
                  fonts =
                    let
                      getFonts = ol:
                        intersectAttrs (ol 42 42) final;
                    in
                    (getFonts self.overlays.free) //
                    (getFonts self.overlays.unfree);
                in
                fonts // {
                  tsangertype-fonts = symlinkJoin rec {
                    name = "${pname}-${version}";
                    paths =
                      filter
                        (
                          p:
                          (isDerivation p) && (meta.availableOn { inherit system; } p)
                        )
                        (attrValues fonts);
                    pname = "tsangertype-fonts";
                    version = import ./version.nix;
                  };
                };

              treefmt = {
                flakeFormatter = true;
                projectRootFile = "flake.nix";

                programs = {
                  nixpkgs-fmt = {
                    enable = true;
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

          systems =
            [
              "aarch64-darwin"
              "aarch64-linux"
              "x86_64-darwin"
              "x86_64-linux"
            ];
        };
}
