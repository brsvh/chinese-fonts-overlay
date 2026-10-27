{
  description = "Chinese fonts collection overlay";

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      self,
      ...
    }:
    let
      inherit (nixpkgs)
        lib
        ;

      inherit (lib.systems)
        flakeExposed
        ;

      projectRoot = ./.;

      chinese-fonts-overlay-lib =
        import (projectRoot + /lib)
          {
            inherit
              lib
              ;
          };

      inherit (chinese-fonts-overlay-lib)
        mkFlake
        ;
    in
    mkFlake
      {
        inherit
          inputs
          ;

        specialArgs = {
          inherit
            chinese-fonts-overlay-lib
            projectRoot
            ;

          packageNixpkgs = nixpkgs;
        };
      }
      {
        flake = {
          lib = chinese-fonts-overlay-lib;

          overlays = {
            default =
              final: prev:
              import (projectRoot + /overlays/default.nix) {
                inherit
                  chinese-fonts-overlay-lib
                  projectRoot
                  ;
              } final prev;
          };
        };

        perSystem =
          {
            pkgs,
            system,
            ...
          }:
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

            packages = {
              inherit (pkgs)
                alibaba-fonts
                alimama-fonts
                buttaiwan-fonts
                cwtex-fonts
                dingtalk-fonts
                foundertype-ctex-fonts
                foundertype-fonts
                foundertype-gcu-fonts
                foundertype-gpu-fonts
                foundertype-paid-fonts
                hanwang-fonts
                harmonyos-sans-fonts
                harmonyos-sans-vf-fonts
                huawei-fonts
                justfont-fonts
                lxgw-fonts
                taobao-fonts
                tianheng-fonts
                trionestype-fonts
                tsangertype-fonts
                tsangertype-gcu-fonts
                tsangertype-gpu-fonts
                windows-fonts
                xiaomi-fonts
                ;
            };
          };

        private = {
          directory = projectRoot + /tools;

          modules = [
            (projectRoot + /tools)
            (projectRoot + /ci/hercules.nix)
          ];

          outputs = [
            "apps"
            "checks"
            "devShells"
            "formatter"
            "herculesCI"
          ];
        };

        systems = flakeExposed;
      };
}
