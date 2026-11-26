{
  languageFontconfig,
  lib,
  pkgs,
  updateFontLanguages,
  ...
}:
let
  inherit (lib)
    attrValues
    concatMap
    concatStringsSep
    escapeShellArg
    getExe
    makeBinPath
    mapAttrsToList
    removeAttrs
    unique
    ;

  inherit (lib.generators)
    toINIWithGlobalSection
    ;

  inherit (pkgs)
    git
    mkShell
    writeText
    ;

  toml = (pkgs.formats.toml { }).generate;

  files = {
    biome = rec {
      data = {
        css = {
          parser = {
            tailwindDirectives = true;
          };
        };

        formatter = {
          enabled = true;
          indentStyle = "space";
          indentWidth = 2;
          lineWidth = 80;
        };

        html = {
          experimentalFullSupportEnabled = true;

          formatter = {
            enabled = true;
            indentScriptAndStyle = true;
            whitespaceSensitivity = "strict";
          };
        };

        javascript = {
          formatter = {
            quoteStyle = "single";
          };
        };
      };

      file =
        (pkgs.formats.json { }).generate output
          data;
      output = "biome.json";

      packages = with pkgs; [
        biome
      ];
    };

    clang-format = rec {
      data = {
        BasedOnStyle = "GNU";
      };

      file =
        (pkgs.formats.yaml { }).generate output
          data;
      output = ".clang-format";

      packages = with pkgs; [
        clang-tools
      ];
    };

    editorconfig = rec {
      data = {
        root = true;

        "*" = {
          charset = "utf-8";
          end_of_line = "lf";
          indent_size = 2;
          indent_style = "space";
          insert_final_newline = true;
          max_line_length = 80;
          tab_width = 2;
          trim_trailing_whitespace = true;
        };

        "*.lock" = {
          indent_size = "unset";
        };

        "*.md" = {
          trim_trailing_whitespace = false;
        };

        "COPYING" = {
          indent_size = "unset";
          indent_style = "unset";
          max_line_length = "unset";
        };

        "{GNUmakefile,Makefile,Makefile.am,makefile,*.mk}" =
          {
            indent_style = "tab";
            max_line_length = 80;
          };
      };

      file = writeText output (
        toINIWithGlobalSection { } {
          globalSection = {
            inherit (data) root;
          };

          sections = removeAttrs data [
            "root"
          ];
        }
      );

      output = ".editorconfig";

      packages = with pkgs; [
        editorconfig-checker
      ];
    };

    mbake = rec {
      data = {
        formatter = {
          auto_insert_phony_declarations = false;
          ensure_final_newline = true;
          group_phony_declarations = false;
          max_line_length = 80;
          phony_at_top = false;
          tab_width = 2;
        };
      };

      file = toml output data;
      output = ".bake.toml";

      packages = with pkgs; [
        mbake
      ];
    };

    prek = rec {
      data = {
        default_install_hook_types = [
          "pre-commit"
        ];

        repos = [
          {
            hooks = [
              {
                entry = "treefmt --fail-on-change";
                id = "treefmt";
                language = "system";
                name = "treefmt";

                stages = [
                  "pre-commit"
                ];
              }
            ];

            repo = "local";
          }
        ];
      };

      file = toml output data;
      output = "prek.toml";

      packages = with pkgs; [
        git
        prek
      ];
    };

    treefmt = rec {
      data = {
        global = {
          excludes = [
            "pages/build/**"
            "pages/.cache/**"
          ];
        };

        formatter =
          let
            # Biome scopes an absolute config path to its directory.
            biomeScript = pkgs.writeShellScript "format-with-biome" ''
              set -euo pipefail
              config="$(
                ${pkgs.coreutils}/bin/realpath \
                  --relative-to="$PWD" ${files.biome.file}
              )"
              exec ${getExe pkgs.biome} format --write \
                --config-path="$config" "$@"
            '';

            formatWithBiome = includes: {
              inherit includes;

              command = biomeScript;
            };
          in
          {
            css = formatWithBiome [
              "*.css"
            ];

            html = formatWithBiome [
              "pages/**/*.html"
            ];

            javascript = formatWithBiome [
              "*.cjs"
              "*.js"
              "*.jsx"
              "*.mjs"
            ];

            markdown = {
              command = "mdformat";

              includes = [
                "*.md"
              ];

              options = [
                "--extensions=frontmatter"
                "--extensions=gfm"
                "--number"
                "--wrap=80"
              ];
            };

            nix = {
              command = "nixfmt";

              includes = [
                "*.nix"
              ];

              options = [
                "--width=50"
              ];
            };
          };
      };

      file = toml output data;
      output = "treefmt.toml";

      packages =
        files.biome.packages
        ++ (with pkgs; [
          (mdformat.withPlugins (
            ps: with ps; [
              mdformat-frontmatter
              mdformat-gfm
            ]
          ))
          nixfmt
          treefmt
        ]);
    };
  };
in
mkShell {
  packages = unique (
    concatMap (config: config.packages) (
      attrValues files
    )
    ++ [
      languageFontconfig
      pkgs.guile
      pkgs.guile-json
      updateFontLanguages
    ]
  );

  shellHook = concatStringsSep "\n" (
    [
      ''projectRoot="$(${getExe git} rev-parse --show-toplevel 2>/dev/null || true)"''
      ''if [ -n "$projectRoot" ]; then''
    ]
    ++ mapAttrsToList (_: config: ''
      ln -sfn ${escapeShellArg (toString config.file)} \
        "$projectRoot"/${escapeShellArg config.output}
    '') files
    ++ map (
      stage:
      let
        hook = pkgs.writeScript "prek-${stage}" ''
          #!${pkgs.runtimeShell}
          if [ "''${PREK:-}" = "0" ]; then
            exit 0
          fi

          repoRoot="$(
            ${getExe git} rev-parse --show-toplevel \
              2>/dev/null \
              || true
          )"

          if [ -z "$repoRoot" ]; then
            repoRoot="$PWD"
          fi

          gitDir="$(
            ${getExe git} -C "$repoRoot" rev-parse \
              --absolute-git-dir 2>/dev/null \
              || true
          )"

          if [ -n "$gitDir" ]; then
            if [ -e "$gitDir/MERGE_HEAD" ] \
              || [ -d "$gitDir/rebase-apply" ] \
              || [ -d "$gitDir/rebase-merge" ]; then
              exit 0
            fi

            ref="$(
              ${getExe git} -C "$repoRoot" symbolic-ref \
                --quiet --short HEAD 2>/dev/null \
                || true
            )"

            if [ "$ref" = "update_flake_lock_action" ]; then
              exit 0
            fi
          fi

          export PATH=${
            escapeShellArg (
              makeBinPath (files.treefmt.packages ++ [ git ])
            )
          }''${PATH:+:$PATH}

          exec ${getExe pkgs.prek} -C "$repoRoot" run \
            --stage ${escapeShellArg stage} "$@"
        '';
      in
      ''
        if gitCommonDir="$(
          ${getExe git} -C "$projectRoot" rev-parse \
            --path-format=absolute \
            --git-common-dir 2>/dev/null
        )"; then
          mkdir -p "$gitCommonDir/hooks"
          ln -sf "${hook}" "$gitCommonDir/hooks"/${escapeShellArg stage}
        fi
      ''
    ) files.prek.data.default_install_hook_types
    ++ [
      "fi"
    ]
  );

  passthru = {
    inherit files;
  };
}
