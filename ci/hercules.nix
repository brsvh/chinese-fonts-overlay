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

  makeEffect =
    {
      action,
      rev,
      name ? null,
      tag ? null,
    }:
    let
      metadata =
        pkgs.writeText
          "chinese-fonts-overlay-ci-${action}.json"
          (
            builtins.toJSON (
              {
                inherit
                  bootstrapRev
                  cache
                  inventory
                  action
                  repository
                  rev
                  ;
              }
              // optionalAttrs (action == "planFonts") {
                inherit bootstrap;
              }
              // optionalAttrs (action != "planFonts") {
                inherit name tag;
              }
            )
          );

      # Opaque derivation paths supply metadata, not dependencies on font outputs.
      derivations =
        pkgs.writeText
          "chinese-fonts-overlay-ci-derivations"
          (
            concatMapStringsSep "\n"
              (
                package:
                builtins.unsafeDiscardOutputDependency package.drvPath
              )
              (
                attrValues packages
                ++ optionals (action == "planFonts") (
                  attrValues bootstrapPackages
                )
              )
          );
    in
    effects.mkEffect (
      {
        inherit action;

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
          node ${./.}/publication.mjs ${metadata}
        '';

        inputs = with pkgs; [
          nix
          nodejs
        ];

        name = "chinese-fonts-overlay-ci-${action}";

        secretsMap = {
          git = {
            type = "GitToken";
          };
        }
        // optionalAttrs (action == "publishFont") {
          public-cache = "public-cache-upload";
        };
      }
      // optionalAttrs (action != "planFonts") {
        # Only the package selected by a verified plan gets realized for publishing.
        ROOTS =
          pkgs.writeText
            "chinese-fonts-overlay-ci-public-roots"
            (
              concatMapStringsSep "\n" (
                output: toString packages.${name}.${output}
              ) packages.${name}.outputs
            );
      }
    );

  makeSiteEffect =
    args:
    import ./site.nix (
      {
        inherit inputs;
        root = projectRoot;
      }
      // args
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
            match "ci/package/(cache)/([a-z0-9_.+-]+)/([0-9a-f]{40})/([0-9a-f-]{36})" tag;

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
              "buildFont/${name}" = {
                outputs = {
                  buildFont = packages.${name};
                };
              };
              "publishFont/${name}" = {
                outputs = {
                  effects = {
                    publishFont = makeEffect {
                      inherit name rev tag;
                      action = "publishFont";
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
                buildSite = {
                  outputs = {
                    effects = {
                      buildSite = makeSiteEffect {
                        inherit rev;
                      };
                    };
                  };
                };
                planFonts = {
                  outputs = {
                    effects = {
                      planFonts = makeEffect {
                        inherit rev;
                        action = "planFonts";
                      };
                    };
                  };
                };
              }
        );
      };
  };
}
