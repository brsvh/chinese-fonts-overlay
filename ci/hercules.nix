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
    toJSON
    ;

  system = "x86_64-linux";
  repository = "brsvh/chinese-fonts-overlay";

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

  cache = {
    publicKey = "cache.brsvh.org-1:HqcG/vJ7jeSLU48jV4yg8Ot+rUPP2v0vIAAnDEqVSvk=";
    url = "https://cache.brsvh.org";
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
            toJSON (
              {
                inherit
                  action
                  cache
                  inventory
                  repository
                  rev
                  ;
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
            concatMapStringsSep "\n" (
              package:
              builtins.unsafeDiscardOutputDependency package.drvPath
            ) (attrValues packages)
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

  makePagesEffect =
    rev:
    import ./pages.nix {
      inherit inputs rev;
      root = projectRoot;
    };
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
            match "ci/package/([a-z0-9_.+-]+)/([0-9a-f]{40})/([0-9a-f-]{36})" tag;

        name = elemAt request 0;
      in
      {
        ciSystems = [
          system
        ];

        onPush = optionalAttrs trusted (
          if
            request != null
            && ref == "refs/tags/${tag}"
            && elemAt request 1 == rev
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
                buildPages = {
                  outputs = {
                    effects = {
                      buildPages = makePagesEffect rev;
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
