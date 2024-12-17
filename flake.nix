{
  description = "Chinese fonts collection overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }:
    let
      inherit (nixpkgs.lib)
        genAttrs
        systems
        ;

      forAllSystems = genAttrs systems.flakeExposed;

      importPkgs =
        attrs:
        import nixpkgs (
          attrs
          // {
            overlays = [
              self.overlays.default
            ];
          }
        );

    in
    {
      overlays = {
        default = final: prev: import ./overlays final prev;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = importPkgs {
            inherit
              system
              ;

            config = {
              allowUnfree = true;
            };
          };
        in
        {
          inherit (pkgs)
            TH-fonts
            alibaba-fonts
            foundertype-fonts
            trionestype-fonts
            tsangertype-fonts
            tsangertype-gcc-fonts
            tsangertype-gcp-fonts
            windows-fonts
            ;
        }
      );
    };
}
