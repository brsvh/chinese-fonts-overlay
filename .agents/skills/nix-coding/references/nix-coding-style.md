# Nix Coding Style

This document is a style contract for both human maintainers and AI coding
agents. It describes how Nix code in this repository should look and be shaped.
It covers formatting, expression shape, naming, comments, and common Nix module
idioms.

This document does not decide repository architecture. It does not define where
code should live, which modules should be created, or which project-specific
configuration choices should be made.

## Contents

- [How To Apply These Rules](#how-to-apply-these-rules)
- [Formatting](#formatting)
- [Module Shape](#module-shape)
- [Attribute Sets](#attribute-sets)
- [Options](#options)
- [Lists](#lists)
- [`let` Bindings](#let-bindings)
- [Library Functions](#library-functions)
- [Default And Override Semantics](#default-and-override-semantics)
- [Flake Expressions](#flake-expressions)
- [Packages And Overrides](#packages-and-overrides)
- [Strings And Generated Files](#strings-and-generated-files)
- [Comments](#comments)
- [Naming](#naming)

## How To Apply These Rules

Apply these rules when writing new Nix code, changing existing Nix code, or
generating Nix code. Treat the examples as concrete target shapes, not as loose
illustrations.

Use the following meanings consistently:

- `must` and `do not` describe requirements;
- `prefer` describes the default choice when the surrounding code does not give
  a stronger reason;
- `acceptable` describes a permitted exception, not the default;
- `avoid` means do not use the pattern unless a local API or compatibility
  boundary requires it.

Nearby code is the first source of local context. If nearby code is more
specific than this document, follow nearby code for that local area. Otherwise,
make new code match the rules below.

When a rule has an exception, keep the exception narrow. Preserve existing
behavior first, then adjust shape and formatting. For AI agents, this means
reading enough surrounding code before editing and not inventing new local style
rules when the repository already has one.

## Formatting

Use the repository formatter for `.nix` files. The configured style is
`nixfmt --width 50` with two spaces for indentation.

Prefer letting `nixfmt` decide exact line breaks. The resulting style is narrow,
vertical, and explicit:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    ;
in
{
  imports = [
    ./base.nix
  ];

  programs = {
    fish = {
      enable = mkDefault true;
    };
  };
}
```

Use blank lines to separate logical groups:

- between flake input entries;
- between `inherit` groups from different sources;
- between unrelated top-level option groups;
- between long nested option clusters when separation improves scanning.

Do not manually compact code only to save lines. This style favors readable
vertical structure over dense one-line expressions.

## Module Shape

Write modules as functions over an argument attribute set. Put one argument per
line when there is more than one argument, and put `...` last.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
```

Only request arguments the module actually uses. If a module only imports other
modules, keep it small:

```nix
{
  ...
}:
{
  imports = [
    ./base.nix
  ];
}
```

Use this top-level order inside modules:

1. `imports`, when present.
2. `options`, for modules that define options.
3. `config`, when the module has explicit `options` and generated config.
4. Normal option trees such as `boot`, `environment`, `home`, `programs`,
   `services`, `systemd`, `users`, and `xdg`.

For modules that declare options, put `options` before `config`:

```nix
{
  options = {
    programs = {
      example = {
        enable = mkEnableOption "example program";
      };
    };
  };

  config = {
    home = {
      packages = mkIf cfg.enable [
        cfg.package
      ];
    };
  };
}
```

## Attribute Sets

Prefer nested attribute sets over dotted assignments.

Use this:

```nix
programs = {
  git = {
    lfs = {
      enable = mkDefault true;
    };
  };
};
```

Avoid this unless a local API strongly favors it:

```nix
programs.git.lfs.enable = mkDefault true;
```

Use quoted attribute names only when the key requires quoting or when it comes
from an external configuration format:

```nix
dconf = {
  settings = {
    "org/example/application" = {
      enabled = true;
    };
  };
};
```

Use dynamic attributes when the key is genuinely computed:

```nix
let
  name = "example";
in
{
  ${name} = {
    enable = true;
  };
}
```

Use `rec` only when an attribute set actually refers to its own fields.

Place `inherit` blocks at the beginning of the attribute set that contains them.
Keep them before ordinary assignments, and separate the inherit block from
following assignments with a blank line.

Use this:

```nix
{
  inherit
    foo
    bar
    ;

  baz = "baz";
}
```

Avoid this:

```nix
{
  baz = "baz";

  inherit
    foo
    bar
    ;
}
```

For generated Nix code and declarative data attrsets, including flake `inputs`,
sort sibling attribute names alphabetically when order has no semantic meaning.
Preserve non-alphabetic order only when module shape, option order, or a local
API gives the order meaning.

Use blank lines selectively inside attrsets. Keep adjacent scalar assignments
together. Add one blank line before and after an assignment whose value is a
structural block, such as an attrset, a list, an indented multiline string, or a
multiline expression that wraps one. This keeps block-valued fields visually
separate without making simple scalar fields sparse.

Use this:

```nix
{
  bar = "bar";
  foo = "foo";

  script = ''
    echo example
  '';

  some-list = [
    example
  ];

  str1 = "str1";
  str2 = "str2";

  yet-another-attrset = {
    enable = true;
  };
}
```

Avoid this for generated data:

```nix
{
  foo = "foo";

  bar = "bar";

  str1 = "str1";

  str2 = "str2";
}
```

## Options

When declaring options with `mkOption`, write `description` as an indented
multiline string. Do this even when the description is a single sentence.
Separate the description from neighboring assignments with blank lines because
it is a block-valued field.

Use this:

```nix
modulePath = mkOption {
  default = "src";

  description = ''
    Relative module path imported by final dendritic flake outputs.
  '';

  type = types.str;
};
```

Avoid this:

```nix
modulePath = mkOption {
  default = "src";
  description = "Relative module path imported by final dendritic flake outputs.";
  type = types.str;
};
```

When a `mkOption` type is composed from multiple `types` helpers, prefer
`with types;` for the type expression:

```nix
settings = mkOption {
  default = { };

  description = ''
    Free-form application settings.
  '';

  type = with types; attrsOf anything;
};
```

Avoid repeatedly qualifying each helper in a composed type:

```nix
settings = mkOption {
  default = { };

  description = ''
    Free-form application settings.
  '';

  type = types.attrsOf types.anything;
};
```

Do not use `with types;` for a single type helper:

```nix
type = types.anything;
```

## Lists

Use multiline lists for imports, packages, extensions, kernel parameters,
substituters, keys, MIME associations, and other user-visible data:

```nix
imports = [
  ./base.nix
  ./desktop.nix
];

home = {
  packages = with pkgs; [
    curl
    doggo
    ripgrep
  ];
};
```

Prefer one item per line even for a single-item list when the list is an option
value:

```nix
trusted-users = [
  "@wheel"
  "root"
];
```

Inline lists are acceptable for tiny local literals where the surrounding code
is already simple:

```nix
families = [ "sans" ];
extraArgs = [ "-f" ];
writable_roots = [ ];
```

Sort package-like lists alphabetically when order has no semantic meaning. Do
not sort lists whose order expresses priority or behavior, such as font fallback
families, kernel parameters, extension order, activation commands, and MIME
default preferences.

## `let` Bindings

Use `let` for three purposes:

- importing names from `lib`, `pkgs`, `inputs`, or `config`;
- naming intermediate values that are reused or clarify intent;
- keeping option trees concise when a value would otherwise be repeated.

Group `inherit` statements by source:

```nix
let
  inherit (inputs)
    sops
    ;

  inherit (lib)
    mkDefault
    mkForce
    ;
in
{
  imports = [
    sops.nixosModules.sops
  ];
}
```

Prefer local names for repeated config paths:

```nix
let
  inherit (config.programs)
    git
    ;

  signingKey =
    git.signing.key;
in
{
  programs = {
    git = {
      signing = {
        key = signingKey;
      };
    };
  };
}
```

Use camelCase for local helpers and derived values:

```nix
normalUsersList = mapAttrsToList (
  _: value: value.name
) normalUsers;
```

Kebab-case local names are acceptable when they mirror a package or family name:

```nix
ibm-plex-sans = pkgs.ibm-plex.override {
  families = [ "sans" ];
};
```

## Library Functions

Import library functions explicitly with `inherit (lib)` instead of calling
`lib.<name>` repeatedly.

```nix
let
  inherit (lib)
    filterAttrs
    mapAttrsToList
    mkDefault
    ;
in
{
  # ...
}
```

Prefer top-level `lib` imports when Nixpkgs exports a helper through
`lib/default.nix`. Many builtins and sublibrary helpers are re-exported there,
so import them from `lib` instead of reaching into `builtins`, `lib.strings`,
`lib.lists`, or another sub-namespace. Use a sub-namespace only when the helper
is not exported at the top level.

Use this:

```nix
let
  inherit (lib)
    attrNames
    removePrefix
    ;
in
{
  # ...
}
```

Avoid this when the same names are available from `lib`:

```nix
let
  inherit (builtins)
    attrNames
    ;

  inherit (lib.strings)
    removePrefix
    ;
in
{
  # ...
}
```

Use Nixpkgs library helpers for attribute and list transformations:

```nix
normalUsers = filterAttrs (
  _: value: value.enable && value.isNormalUser
) config.users.users;

normalUsersList = mapAttrsToList (
  _: value: value.name
) normalUsers;
```

Use `pipe` for multi-step transformations, with one transformation per line:

```nix
treeSitterGrammars =
  pipe pkgs.tree-sitter-grammars
    [
      (filterAttrs (
        name: _: name != "recurseForDerivations"
      ))
      attrValues
    ];
```

For conditional configuration, prefer `mkMerge` with explicit `mkIf` branches:

```nix
config = mkMerge [
  (mkIf config.xdg.enable {
    xdg = {
      configFile = {
        "example/config" = {
          source = ./config;
        };
      };
    };
  })
  (mkIf (!config.xdg.enable) {
    home = {
      file = {
        ".config/example/config" = {
          source = ./config;
        };
      };
    };
  })
];
```

## Default And Override Semantics

Match override strength to intent.

Use `mkDefault` when a value is an overridable default:

```nix
services = {
  openssh = {
    enable = mkDefault true;
  };
};
```

Use direct assignments when the expression is intentionally making a concrete
choice:

```nix
services = {
  example = {
    enable = true;
  };
};
```

Use `mkForce` only when a value must override another definition that would
otherwise remain active:

```nix
boot = {
  loader = {
    systemd-boot = {
      enable = mkForce false;
    };
  };
};
```

Do not use `mkForce` as a substitute for normal precedence. It should signal a
real override boundary.

## Flake Expressions

Write flake inputs as expanded attribute sets, even when the input only contains
a URL:

```nix
inputs = {
  nixpkgs = {
    url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable";
  };
};
```

For inputs with dependencies, put `inputs` before `url`:

```nix
example = {
  inputs = {
    nixpkgs = {
      follows = "nixpkgs";
    };
  };

  url = "git+https://example.invalid/example.git?ref=main";
};
```

When building output attributes from directories, prefer named transformations
and `pipe` over deeply nested expressions:

```nix
collect = dir: fns: pipe (dirToAttrs dir) fns;

modules = collect ./modules [
  removeExtension
  removePathAttrs
  keepOnlyNixAttrs
];
```

## Packages And Overrides

Use `with pkgs; [ ... ]` for package lists:

```nix
environment = {
  systemPackages = with pkgs; [
    qemu
    quickemu
  ];
};
```

Use narrower package scopes when they improve readability:

```nix
environment = {
  systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    kimpanel
  ];
};
```

Keep package overrides close to the option or local binding that uses them:

```nix
programs = {
  global = {
    package = pkgs.global.overrideAttrs (
      finalAttrs: prevAttrs: {
        NIX_CFLAGS_COMPILE =
          (prevAttrs.NIX_CFLAGS_COMPILE or "")
          + " -Wno-error=incompatible-pointer-types";
      }
    );
  };
};
```

Name repeated package overrides in `let`; inline one-off overrides when the
override is small and only used once.

## Strings And Generated Files

Use multiline strings for embedded shell, Emacs Lisp, XML, TOML, YAML, and
similar content:

```nix
programs = {
  fish = {
    interactiveShellInit = ''
      set fish_greeting
    '';
  };
};
```

Escape shell variable interpolation inside Nix multiline strings with `''${...}`
when the shell, not Nix, should expand the variable:

```nix
programs = {
  bash = {
    interactiveShellInit = ''
      export CACHE_DIR="''${XDG_CACHE_HOME:-''$HOME/.cache}"
    '';
  };
};
```

Use `pkgs.formats.<format> { }` or generator helpers when producing structured
files:

```nix
toYAML =
  name: attrs:
  (pkgs.formats.yaml { }).generate name attrs;
```

Prefer structured data over hand-written strings when the code is producing a
machine-readable file. Hand-written multiline strings are acceptable for native
shell snippets, editor configuration snippets, and XML fragments where the
source format is clearer than an attribute representation.

## Comments

Add comments only when they record non-obvious intent, a workaround, or behavior
that would be hard to infer from the option name.

Good comments explain why:

```nix
# Fix markdown-inline grammars for markdown-ts-mode.
```

Do not add comments that restate the attribute name:

```nix
# Enable fish.
programs = {
  fish = {
    enable = mkDefault true;
  };
};
```

Long embedded shell snippets may use native shell comments to explain each shell
operation. Keep those comments close to the command they explain.

## Naming

Use names that reflect the value's role:

- local helpers and derived values use camelCase, such as `normalUsers`,
  `storageDriver`, and `treeSitterGrammarsPath`;
- package-like local names may use kebab-case when that mirrors the package
  name, such as `ibm-plex-sans`;
- option names and external configuration keys keep the upstream spelling, even
  when that means hyphens, uppercase words, or quoted strings.

Avoid abbreviations unless the upstream option or package already uses them.
