{
  includeFontPreviewTool ? false,
  lib,
  pkgs,
  projectRoot,
  ...
}:
let
  inherit (lib)
    attrNames
    baseNameOf
    concatMap
    concatStringsSep
    elem
    escapeShellArg
    foldl'
    getExe
    map
    mapAttrs
    optional
    removeAttrs
    ;

  inherit (lib.generators)
    toINIWithGlobalSection
    ;

  inherit (pkgs)
    callPackage
    git
    mkShell
    writeText
    ;

  mkFile = request: request.engine request;

  install =
    request:
    let
      source = escapeShellArg (
        toString (mkFile request)
      );
      output = escapeShellArg request.output;
    in
    ''
      target="$projectRoot"/${output}
      mkdir -p "$(dirname -- "$target")"
      ln -sfn ${source} "$target"
    '';

  hookExtra =
    request:
    if request ? hook && request.hook ? extra then
      request.hook.extra request.data
    else
      "";

  installWithHook =
    request:
    let
      extra = hookExtra request;
    in
    concatStringsSep "\n" (
      [
        (install request)
      ]
      ++ optional (extra != "") extra
    );

  addFile =
    names: name:
    if elem name names then
      names
    else
      (foldl' addFile names (
        files.${name}.depends or [ ]
      ))
      ++ [
        name
      ];

  toml =
    request:
    let
      inherit (request)
        data
        output
        ;
    in
    (pkgs.formats.toml { }).generate
      (baseNameOf output)
      data;

  generate-font-preview-images = callPackage (
    projectRoot
    + /tools/generate-font-preview-images/package.nix
  ) { };

  files = {
    editorconfig = {
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

        "*.nix" = {
          indent_style = "space";
          max_line_length = 80;
          tab_width = 2;
        };

        "COPYING" = {
          indent_size = "unset";
          indent_style = "unset";
          max_line_length = "unset";
        };
      };

      engine =
        request:
        let
          inherit (request)
            data
            output
            ;

          value = {
            globalSection = {
              root = data.root or true;
            };

            sections = removeAttrs data [
              "root"
            ];
          };
        in
        writeText (baseNameOf output) (
          toINIWithGlobalSection { } value
        );

      output = ".editorconfig";

      packages = with pkgs; [
        editorconfig-checker
      ];
    };

    prek = {
      data = {
        default_install_hook_types = [
          "pre-commit"
        ];

        repos = [
          {
            repo = "local";

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
          }
        ];
      };

      depends = [
        "treefmt"
      ];

      engine = toml;
      output = "prek.toml";

      hook = {
        extra =
          cfg:
          let
            inherit (pkgs)
              prek
              runtimeShell
              writeScript
              ;

            mkInstall = stage: ''
              if gitDir="$(
                ${getExe git} -C "$projectRoot" rev-parse \
                  --absolute-git-dir 2>/dev/null
              )"; then
                mkdir -p "$gitDir/hooks"
                ln -sf "${mkScript stage}" "$gitDir/hooks/${stage}"
              fi
            '';

            mkScript =
              stage:
              writeScript "prek-${stage}" ''
                #!${runtimeShell}
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

                exec ${getExe prek} -C "$repoRoot" run \
                  --stage "${stage}" "$@"
              '';
          in
          concatStringsSep "\n" (
            map mkInstall cfg.default_install_hook_types
          );
      };

      packages = with pkgs; [
        git
        prek
      ];
    };

    treefmt = {
      data = {
        formatter = {
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

      engine = toml;
      output = "treefmt.toml";

      packages =
        let
          mdformatWithPlugins = pkgs.mdformat.withPlugins (
            ps: with ps; [
              mdformat-frontmatter
              mdformat-gfm
            ]
          );
        in
        with pkgs;
        [
          mdformatWithPlugins
          nixfmt
          treefmt
        ];
    };
  };

  names = foldl' addFile [ ] (attrNames files);
in
mkShell {
  packages =
    (concatMap (
      name: files.${name}.packages or [ ]
    ) names)
    ++ (optional includeFontPreviewTool generate-font-preview-images)
    ++ [
      git
    ];

  shellHook = concatStringsSep "\n" (
    [
      ''projectRoot="$(${getExe git} rev-parse --show-toplevel)"''
    ]
    ++ map (name: installWithHook files.${name}) names
  );

  passthru = {
    dependencies = mapAttrs (_: request: {
      packages = request.packages or [ ];
    }) files;

    files = mapAttrs (_: request: {
      inherit (request)
        data
        output
        ;

      file = mkFile request;
      packages = request.packages or [ ];
    }) files;
  };
}
