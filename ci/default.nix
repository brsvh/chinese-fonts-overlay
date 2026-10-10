{
  mode ? "runtime",
  pkgs ? null,
  root ? null,
  selection ? [ ],
  system ? "x86_64-linux",
}:
let
  previewRequests = { };

  projectRoot = /. + root;
  flake = builtins.getFlake root;

  fontPkgs =
    if pkgs != null then
      pkgs
    else
      import flake.inputs.nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };

        overlays = [
          flake.overlays.default
        ];
      };

  inherit (fontPkgs.lib)
    attrByPath
    attrNames
    concatMap
    filterAttrs
    isDerivation
    listToAttrs
    mapAttrsToList
    nameValuePair
    optional
    ;

  discard = builtins.unsafeDiscardStringContext;

  vendors = attrNames (
    filterAttrs (_: kind: kind == "directory") (
      builtins.readDir (projectRoot + /packages)
    )
  );

  sourceInfo = source: {
    drvPath =
      if isDerivation source then
        discard source.drvPath
      else
        null;

    path = discard (toString source);
  };

  entries = concatMap (
    vendor:
    mapAttrsToList
      (
        name: package:
        nameValuePair "${vendor}.${name}" {
          inherit vendor;

          attrPath = [
            "${vendor}Packages"
            name
          ];

          drvPath = discard package.drvPath;

          outputs = listToAttrs (
            map (
              output:
              nameValuePair output (
                discard (toString package.${output})
              )
            ) package.outputs
          );

          pname = package.pname;
          redistributable =
            (package.meta.redistributable or false) == true;

          sources = map sourceInfo (
            optional (package ? src) package.src
            ++ (package.srcs or [ ])
          );

          version = package.version or "";
          windows = vendor == "microsoft";
        }
      )
      (
        filterAttrs (
          _: isDerivation
        ) fontPkgs."${vendor}Packages"
      )
  ) vendors;

  inventory = {
    packages = listToAttrs entries;
    schema = 1;
    system = fontPkgs.stdenv.hostPlatform.system;
  };

  renderer = fontPkgs.callPackage (
    projectRoot
    + /tools/generate-font-preview-images/package.nix
  ) { };

  common = pkgs.writeText "font-ci-common.mjs" (
    import ./common.nix {
      evaluator = "${./.}/default.nix";
    }
  );

  previews = pkgs.writeText "font-ci-previews.mjs" (
    import ./previews.nix {
      inherit common;
    }
  );

  github = pkgs.writeText "font-ci-github.mjs" (
    import ./github.nix {
      inherit common previews;
    }
  );

  actions = pkgs.writeText "font-ci-actions.mjs" (
    import ./actions.nix {
      inherit common github previews;
    }
  );

  entry = pkgs.writeText "font-ci.mjs" ''
    import { parseArgs } from 'node:util';
    import { ensure, inventory, readJson, writeJson } from '${common}';
    import { GitHub, publishCommand } from '${github}';
    import { validatePlan } from '${previews}';
    import {
      buildShard, preparePlan, previewManifest,
    } from '${actions}';

    const { values, positionals } = parseArgs({
      allowPositionals: true,
      options: {
        root: { type: 'string', default: '.' },
        directory: { type: 'string', default: '.ci-work' },
        output: { type: 'string' },
        plan: { type: 'string' },
        shard: { type: 'string' },
        'package-name': { type: 'string' },
      },
    });

    try {
      ensure(positionals.length === 1, 'Exactly one command is required');
      const [command] = positionals;

      if (command === 'inventory') {
        writeJson(values.output, inventory(values.root));
      } else if (command === 'preview-manifest') {
        previewManifest(values.root, values['package-name'], values.output);
      } else if (command === 'pr-plan') {
        await preparePlan(values.root, values.directory,
          readJson(process.env.GITHUB_EVENT_PATH),
          new GitHub(process.env.GITHUB_TOKEN));
      } else if (command === 'pr-build') {
        const shard = Number(values.shard);
        ensure(Number.isSafeInteger(shard) && shard >= 0, 'Invalid shard');
        const ok = buildShard(values.root,
          validatePlan(readJson(values.plan)), shard, values.directory,
          readJson(process.env.GITHUB_EVENT_PATH));
        process.exitCode = ok ? 0 : 1;
      } else if (['identify', 'publish', 'finalize'].includes(command)) {
        await publishCommand(command);
      } else {
        throw new Error('Unknown command: ' + command);
      }
    } catch (error) {
      console.error(error.message, error.details ?? "");
      process.exitCode = 1;
    }
  '';
in
if mode == "requests" then
  previewRequests
else if mode == "preview-requests" then
  let
    declaration = projectRoot + /ci/default.nix;
  in
  if builtins.pathExists declaration then
    import declaration {
      mode = "requests";
    }
  else
    { }
else if mode == "inventory" then
  inventory
else if mode == "outputs" then
  concatMap (
    name:
    let
      package =
        attrByPath inventory.packages.${name}.attrPath
          (throw "Unknown font package ${name}")
          fontPkgs;
    in
    map (output: package.${output}) package.outputs
  ) selection
else if mode == "renderer" then
  renderer
else if mode == "preview-config" then
  {
    rendererDrvPath = discard renderer.drvPath;

    requests = import ./default.nix {
      inherit root;
      mode = "preview-requests";
    };

    samples = import (
      projectRoot
      + /tools/generate-font-preview-images/sample-keys.nix
    );
  }
else if mode == "runtime" then
  pkgs.writeShellApplication {
    name = "font-ci";

    runtimeInputs = with pkgs; [
      git
      nix
      nodejs
    ];

    text = ''
      exec node ${entry} "$@"
    '';
  }
else if mode == "modules" then
  {
    inherit
      actions
      common
      github
      previews
      ;
  }
else
  throw "Unknown CI mode ${mode}"
