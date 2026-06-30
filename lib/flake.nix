# Copy from https://codeberg.org/bingshan/infix
#
# Copyright (c) 2024-2026 Bingshan Chang
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
{
  lib,
  ...
}:
let
  inherit (builtins)
    fetchTree
    getFlake
    ;

  inherit (lib)
    defaultFunctor
    evalModules
    filterAttrs
    fromJSON
    genAttrs
    hasAttr
    head
    isAttrs
    isFunction
    isList
    mapAttrs
    mkForce
    mkIf
    mkOption
    mkOptionDefault
    mkOptionType
    optionalString
    readFile
    removeAttrs
    setDefaultModuleLocation
    showOption
    tail
    types
    ;

  mkAttrsOption =
    type:
    mkOption {
      default = { };

      inherit
        type
        ;
    };

  deferredModuleWith =
    attrs@{
      staticModules ? [ ],
    }:
    mkOptionType {
      name = "deferredModule";
      description = "module";

      check =
        value:
        isAttrs value
        || isFunction value
        || types.path.check value;

      merge =
        loc: defs:
        staticModules
        ++ map (
          def:
          setDefaultModuleLocation "${def.file}, via option ${showOption loc}" def.value
        ) defs;

      substSubModules =
        modules:
        deferredModuleWith (
          attrs
          // {
            staticModules = modules;
          }
        );

      functor =
        (defaultFunctor "deferredModuleWith")
        // {
          type = deferredModuleWith;

          payload = {
            inherit
              staticModules
              ;
          };

          binOp = lhs: rhs: {
            staticModules =
              lhs.staticModules ++ rhs.staticModules;
          };
        };
    };

  mkPerSystemType =
    module:
    deferredModuleWith {
      staticModules = [
        module
      ];
    };

  flakeOutputTypes = with types; {
    apps = lazyAttrsOf (lazyAttrsOf raw);
    checks = lazyAttrsOf (lazyAttrsOf raw);
    devShells = lazyAttrsOf (lazyAttrsOf raw);
    formatter = lazyAttrsOf raw;
    legacyPackages = lazyAttrsOf (lazyAttrsOf raw);
    nixosConfigurations = lazyAttrsOf raw;
    nixosModules = lazyAttrsOf raw;
    overlays = lazyAttrsOf raw;
    packages = lazyAttrsOf (lazyAttrsOf raw);
  };

  perSystemOutputTypes = with types; {
    apps = lazyAttrsOf raw;
    checks = lazyAttrsOf raw;
    devShells = lazyAttrsOf raw;
    legacyPackages = lazyAttrsOf raw;
    packages = lazyAttrsOf raw;
  };

  transposedAttrs =
    mapAttrs (_: _: { }) perSystemOutputTypes
    // {
      formatter = {
        nullable = true;
      };
    };

  flakeOutputOptions = mapAttrs (
    _: type: mkAttrsOption type
  ) flakeOutputTypes;

  perSystemOutputOptions =
    mapAttrs (
      _: type: mkAttrsOption type
    ) perSystemOutputTypes
    // {
      formatter = mkOption {
        default = null;
        type = with types; nullOr raw;
      };
    };

  privateOutputError =
    attrName:
    throw ''
      `private.outputs` contains `${attrName}`, but
      `private.modules.flake.${attrName}` is not defined.
    '';

  lockedInputRef =
    locked:
    if locked.type == "git" then
      "git+${locked.url}?rev=${locked.rev}"
      + optionalString (
        locked ? ref
      ) "&ref=${locked.ref}"
      + optionalString (
        locked ? dir
      ) "&dir=${locked.dir}"
    else if locked.type == "github" then
      "github:${locked.owner}/${locked.repo}/${locked.rev}"
      + optionalString (
        locked ? dir
      ) "?dir=${locked.dir}"
    else
      throw ''
        private.directory contains an unsupported locked input type
        `${locked.type}`.
      '';

  lockedInputMatches =
    input: locked:
    let
      inputOutPath = input.outPath or null;

      inputRootPath =
        input.sourceInfo.outPath or inputOutPath;

      inputDirMatches =
        if
          inputOutPath == null || inputRootPath == null
        then
          !(locked ? dir)
        else if locked ? dir then
          toString inputOutPath
          == "${toString inputRootPath}/${locked.dir}"
        else
          toString inputOutPath == toString inputRootPath;
    in
    inputDirMatches
    && (
      (
        locked ? rev
        && input ? rev
        && input.rev == locked.rev
      )
      || (
        locked ? narHash
        && input ? narHash
        && input.narHash == locked.narHash
      )
    );

  lockInputNodeName =
    lock: input:
    if isList input then
      lockInputPathNodeName lock lock.root input
    else
      input;

  lockInputPathNodeName =
    lock: nodeName: path:
    if path == [ ] then
      nodeName
    else
      let
        nextInput =
          lock.nodes.${nodeName}.inputs.${head path};

        nextNodeName = lockInputNodeName lock nextInput;
      in
      lockInputPathNodeName lock nextNodeName (
        tail path
      );

  privateInputs =
    inputs: directory:
    let
      lock = fromJSON (
        readFile (directory + /flake.lock)
      );

      rootInputs =
        lock.nodes.${lock.root}.inputs or { };

      inputFromLock =
        inputName: input:
        let
          nodeName = lockInputNodeName lock input;

          node = lock.nodes.${nodeName};

          publicInput = inputs.${inputName} or null;
        in
        if
          publicInput != null
          && lockedInputMatches publicInput node.locked
        then
          publicInput
        else if !(node.flake or true) then
          fetchTree node.locked
        else
          getFlake (lockedInputRef node.locked);
    in
    mapAttrs inputFromLock rootInputs;

  flakeOutputModule =
    {
      ...
    }:
    {
      options = {
        flake = mkOption {
          default = { };

          description = ''
            Raw flake output attributes.
          '';

          type =
            with types;
            submoduleWith {
              modules = [
                {
                  freeformType = lazyAttrsOf raw;
                  options = flakeOutputOptions;
                }
              ];
            };
        };
      };
    };

  perSystemModule =
    {
      config,
      inputs,
      self,
      ...
    }:
    let
      rootConfig = config;

      perInput =
        system: flake:
        mapAttrs (
          attrName: attrConfig:
          flake.${attrName}.${system} or (
            if attrConfig.nullable then
              null
            else
              throw ''
                Attempt to access `${attrName}.${system}` of a flake
                input, but that output is not defined.
              ''
          )
        ) rootConfig.transposition;

      perSystemBaseModule =
        {
          system,
          ...
        }:
        let
          inputs' = mapAttrs (
            _: input: perInput system input
          ) (removeAttrs inputs [ "self" ]);

          self' = perInput system self;
        in
        {
          freeformType = with types; lazyAttrsOf raw;
          options = perSystemOutputOptions;

          config = {
            _module = {
              args = {
                inherit
                  inputs'
                  self'
                  ;

                pkgs = mkOptionDefault (
                  inputs'.nixpkgs.legacyPackages or (throw ''
                    `pkgs` was requested in a `perSystem` module, but
                    the flake does not have an input named `nixpkgs` with
                    `legacyPackages.${system}`.
                  '')
                );
              };
            };
          };
        };
    in
    {
      options = {
        allSystems = mkOption {
          description = ''
            The system-specific configuration for each configured system.
          '';

          internal = true;
          type = with types; lazyAttrsOf unspecified;
        };

        perSystem = mkOption {
          apply =
            modules: system:
            (evalModules {
              inherit
                modules
                ;

              class = "perSystem";

              prefix = [
                "perSystem"
                system
              ];

              specialArgs = {
                inherit
                  system
                  ;
              };
            }).config;

          default = { };

          description = ''
            A module evaluated once for each configured system.
          '';

          type = mkPerSystemType perSystemBaseModule;
        };

        systems = mkOption {
          default = [ ];

          description = ''
            Systems to enumerate in transposed flake output attributes.
          '';

          type = with types; listOf str;
        };
      };

      config = {
        allSystems = genAttrs config.systems config.perSystem;
      };
    };

  transpositionModule =
    {
      config,
      ...
    }:
    let
      transposed = mapAttrs (
        attrName: attrConfig:
        let
          systemAttrs = mapAttrs (
            _: systemConfig: systemConfig.${attrName}
          ) config.allSystems;
        in
        if attrConfig.nullable then
          filterAttrs (_: value: value != null) systemAttrs
        else
          systemAttrs
      ) config.transposition;
    in
    {
      options = {
        transposition = mkOption {
          default = transposedAttrs;

          description = ''
            Per-system attributes to transpose into flake outputs.
          '';

          type =
            with types;
            lazyAttrsOf (submodule {
              options = {
                nullable = mkOption {
                  default = false;

                  description = ''
                    Whether null per-system values should be omitted.
                  '';

                  type = bool;
                };
              };
            });
        };
      };

      config = {
        flake = transposed;
      };
    };

  privateModule =
    {
      moduleLocation,
      privateEval,
      specialArgs,
    }:
    {
      config,
      inputs,
      self,
      ...
    }:
    let
      privateSubmodule =
        {
          config,
          ...
        }:
        {
          options = {
            directory = mkOption {
              default = null;

              description = ''
                Directory containing the private inputs flake.
              '';

              type = with types; nullOr path;
            };

            modules = mkOption {
              apply =
                modules:
                let
                  directoryInputs =
                    if config.directory == null then
                      { }
                    else
                      privateInputs inputs config.directory;

                  inputs' =
                    inputs
                    // directoryInputs
                    // {
                      self = self';
                    };

                  self' = self // {
                    inputs = inputs';
                  };
                in
                (evalFlakeModule
                  {
                    inherit
                      moduleLocation
                      specialArgs
                      ;

                    inputs = inputs';
                    privateEval = true;
                    self = self';
                  }
                  {
                    imports = modules;
                  }
                ).config;

              default = [ ];

              description = ''
                Modules evaluated with private inputs.
              '';

              type = with types; listOf deferredModule;
            };

            outputs = mkOption {
              default = [ ];

              description = ''
                Flake output attributes taken from the private modules.
              '';

              type = with types; listOf str;
            };
          };
        };
    in
    {
      options = {
        private = mkOption {
          default = { };

          description = ''
            Single private flake module evaluation with private inputs.
          '';

          type = with types; submodule privateSubmodule;
        };
      };

      config = {
        flake = mkIf (!privateEval) (
          genAttrs config.private.outputs (
            attrName:
            mkForce (
              config.private.modules.flake.${attrName}
                or (privateOutputError attrName)
            )
          )
        );
      };
    };

  evalFlakeModule =
    {
      inputs ? self.inputs,
      moduleLocation ? (
        if self ? outPath then
          "${self.outPath}/flake.nix"
        else
          "<mkFlake>/flake.nix"
      ),
      privateEval ? false,
      self ? inputs.self or { },
      specialArgs ? { },
      ...
    }:
    module:
    evalModules {
      class = "flake";

      modules = [
        flakeOutputModule
        perSystemModule
        (privateModule {
          inherit
            moduleLocation
            privateEval
            specialArgs
            ;
        })
        transpositionModule
        (setDefaultModuleLocation moduleLocation module)
      ];

      specialArgs = {
        inherit
          inputs
          moduleLocation
          self
          ;
      }
      // specialArgs;
    };
in
{
  /**
    Evaluate a flake module and return the full module system result.

    # Inputs

    `args` (Attribute set)
    : `inputs`
      : Flake output function inputs. This is usually the `inputs` value from
        `outputs = inputs@{ ... }:`.

    : `moduleLocation`
      : Location used for module error reporting.

    : `self`
      : The flake's own output value. Defaults to `inputs.self`.

    : `specialArgs`
      : Additional module arguments passed to top-level flake modules.

    `module`
    : Flake module to evaluate.

    # Type

    ```
    evalFlakeModule :: AttrSet -> Module -> EvalModulesResult
    ```

    # Examples
    :::{.example}
    ## `infix-lib.evalFlakeModule` usage example

    ```nix
    (evalFlakeModule
      {
        inherit inputs;
      }
      {
        systems = [
          "x86_64-linux"
        ];
      }).config.flake
    ```

    :::
  */
  inherit
    evalFlakeModule
    ;

  /**
    Return a required flake input, or throw if it is absent.

    This is intended for modules that require a caller-provided flake input.  It
    checks only the top-level input name and returns the input value unchanged,
    so existing inputs with values such as `null` or `false` still count as
    present.

    # Inputs

    `inputs` (Attribute set)
    : Flake output function inputs. This is usually the `inputs` value from
      `outputs = inputs@{ ... }:`.

    `input` (String)
    : Required input name.

    # Type

    ```
    hasInput :: AttrSet -> String -> Any
    ```

    # Examples
    :::{.example}
    ## `infix-lib.hasInput` usage example

    ```nix
    let
      devshell = hasInput inputs "devshell";
    in
    devshell.packages.${system}.default
    ```

    :::
  */
  hasInput =
    inputs: input:
    if hasAttr input inputs then
      inputs.${input}
    else
      throw ''
        ${input} input not found, please add a ${input} input to your flake.
      '';

  /**
    Build flake outputs from a flake module.

    # Inputs

    `args`
    : Flake evaluation arguments. This is usually `{ inherit inputs; }` from
      the flake output function.

    `module`
    : Flake module defining outputs with `flake`, `systems`, `perSystem`, or
      `private`.

    # Type

    ```
    mkFlake :: AttrSet -> Module -> AttrSet
    ```

    # Examples
    :::{.example}
    ## `infix-lib.mkFlake` usage example

    ```nix
    outputs = inputs@{ self, ... }:
      mkFlake
        {
          inherit inputs;
        }
        {
          private = {
            directory = ./private;

            outputs = [
              "checks"
            ];

            modules = [
              (
                { inputs, ... }:
                {
                  systems = [
                    "x86_64-linux"
                  ];

                  perSystem =
                    { system, ... }:
                    {
                      checks = {
                        private = inputs.ci.checks.${system}.default;
                      };
                    };
                }
              )
            ];
          };

          systems = [
            "x86_64-linux"
          ];

          perSystem =
            { system, ... }:
            {
              packages = {
                default = "package-for-${system}";
              };
            };
        };
    ```

    :::
  */
  mkFlake =
    args: module:
    (evalFlakeModule args module).config.flake;
}
