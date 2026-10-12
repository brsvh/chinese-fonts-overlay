{
  inputs,
  lib,
  packageNixpkgs,
  projectRoot,
  self,
  ...
}:
let
  inherit (lib)
    attrByPath
    attrValues
    concatMapStringsSep
    elemAt
    filterAttrs
    hasAttr
    mapAttrs
    match
    optionalAttrs
    optionals
    ;

  system = "x86_64-linux";
  repository = "brsvh/chinese-fonts-overlay";
  bootstrapRev = "da90d47fa1a6f8fbfcc5795bc9351c98142f37ea";

  pkgs = import packageNixpkgs {
    inherit system;

    config = {
      allowUnfree = true;
    };

    overlays = [
      self.overlays.default
    ];
  };

  effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;

  inventory = import ./default.nix {
    inherit pkgs;

    mode = "inventory";
    root = toString projectRoot;
  };

  packages = mapAttrs (
    _: info: attrByPath info.attrPath null pkgs
  ) inventory.packages;

  candidates = filterAttrs (
    name: _:
    inventory.packages.${name}.redistributable
    && !inventory.packages.${name}.windows
  ) packages;

  bootstrapFlake = builtins.getFlake "git+https://github.com/brsvh/chinese-fonts-overlay.git?rev=${bootstrapRev}";

  bootstrapPkgs =
    import bootstrapFlake.inputs.nixpkgs
      {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          bootstrapFlake.overlays.default
        ];
      };

  bootstrap = import ./default.nix {
    mode = "inventory";
    pkgs = bootstrapPkgs;
    root = builtins.unsafeDiscardStringContext bootstrapFlake.outPath;
  };

  bootstrapPackages = mapAttrs (
    _: info:
    attrByPath info.attrPath null bootstrapPkgs
  ) bootstrap.packages;

  cache = {
    publicKey = "cache.bingshan.org-1:HqcG/vJ7jeSLU48jV4yg8Ot+rUPP2v0vIAAnDEqVSvk=";
    url = "https://cache.bingshan.org";
  };

  renderer = pkgs.callPackage (
    projectRoot
    + /tools/generate-font-preview-images/package.nix
  ) { };

  previewConfiguration = {
    rendererDrvPath = builtins.unsafeDiscardStringContext renderer.drvPath;

    requests = import ./default.nix {
      mode = "requests";
    };

    samples = import (
      projectRoot
      + /tools/generate-font-preview-images/sample-keys.nix
    );
  };

  makeEffect =
    {
      mode,
      rev,
      name ? null,
      tag ? null,
    }:
    let
      metadata = pkgs.writeText "font-ci-${mode}.json" (
        builtins.toJSON (
          {
            inherit
              bootstrapRev
              cache
              inventory
              mode
              previewConfiguration
              repository
              rev
              ;
          }
          // optionalAttrs (mode == "plan") {
            inherit bootstrap;

            previewRequests = previewConfiguration.requests;
          }
          // optionalAttrs (mode != "plan") {
            inherit name tag;
          }
          // optionalAttrs (mode == "preview") {
            renderer = toString renderer;
          }
        )
      );

      # Opaque derivation paths supply metadata, not dependencies on font outputs.
      derivations =
        pkgs.writeText "font-ci-derivations"
          (
            concatMapStringsSep "\n"
              (
                package:
                builtins.unsafeDiscardOutputDependency package.drvPath
              )
              (
                attrValues packages
                ++ optionals (mode == "plan") (
                  attrValues bootstrapPackages
                )
              )
          );
    in
    effects.mkEffect (
      {
        inherit mode;

        DERIVATION_ROOTS = derivations;

        NIX_CONFIG = ''
          experimental-features = nix-command
          narinfo-cache-negative-ttl = 0
          narinfo-cache-positive-ttl = 0
          builders =
        '';

        dontUnpack = true;

        effectScript = ''
          set -euo pipefail
          node ${./.}/main.mjs ${metadata}
        '';

        inputs = with pkgs; [
          nix
          nodejs
        ];

        name = "font-ci-${mode}";

        secretsMap = {
          git = {
            type = "GitToken";
          };
        }
        // optionalAttrs (mode == "cache") {
          public-cache = "public-cache-upload";
        };
      }
      // optionalAttrs (mode != "plan") {
        # Only the package selected by a verified plan gets realized for publishing.
        ROOTS = pkgs.writeText "font-ci-public-roots" (
          concatMapStringsSep "\n" (
            output: toString packages.${name}.${output}
          ) packages.${name}.outputs
        );
      }
    );
in
{
  flake = {
    herculesCI =
      {
        branch ? null,
        primaryRepo ? { },
        ref ? null,
        rev ? null,
        tag ? null,
        ...
      }:
      let
        trusted =
          (primaryRepo.owner or null) == "brsvh"
          &&
            (primaryRepo.name or null)
            == "chinese-fonts-overlay";

        request =
          if tag == null then
            null
          else
            match "ci/package/(cache|preview)/([a-z0-9_.+-]+)/([0-9a-f]{40})/([0-9a-f-]{36})" tag;

        mode = elemAt request 0;
        name = elemAt request 1;
      in
      {
        ciSystems = [
          system
        ];

        onPush = optionalAttrs trusted (
          if
            request != null
            && ref == "refs/tags/${tag}"
            && elemAt request 2 == rev
            && hasAttr name candidates
          then
            {
              "${mode}/${name}" = {
                outputs = {
                  effects = {
                    publish = makeEffect {
                      inherit
                        mode
                        name
                        rev
                        tag
                        ;
                    };
                  };
                };
              };
            }
          else
            optionalAttrs
              (
                branch == "main"
                && ref == "refs/heads/main"
                && tag == null
              )
              {
                plan = {
                  outputs = {
                    effects = {
                      plan = makeEffect {
                        inherit rev;

                        mode = "plan";
                      };
                    };
                  };
                };
              }
        );
      };
  };
}
