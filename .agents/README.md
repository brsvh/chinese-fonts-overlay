# Using the skills

These skills can be copied to another machine or installed in another project.
Copy each complete skill directory, including its `SKILL.md`, `references/`,
`scripts/`, and `examples/`. Relative resource links resolve from the installed
skill directory.

## Scope

- `c-coding`: GNU-style C, resource ownership, and native library boundaries.
- `guile-coding`: native Guile modules, scripts, and tests.
- `guile-web-coding`: native Guile HTTP services and SXML/HTML generation.
- `hoot-coding`: Scheme compiled to browser Wasm and its host interactions.
- `nix-coding`: Nix style, formatting, and validation.
- `commit`: staged-diff review and GNU-style messages when a commit is
  requested.
- `create-font-package`: font packaging in a Chinese-fonts-overlay-compatible
  Nix repository.
- `create-font-preview`: generation and repair of branch previews in that
  layout.

## Using another environment

Locate the target workspace and read its applicable `AGENTS.md` and development
instructions. Discover its build entry points, tool versions, and formatter
configuration. The target repository and installed skill are separate locations;
do not assume the author's working directory, home directory, Nix store paths,
or caches exist on another machine. Architecture, interface language, website
data, and publication rules belong to the target project, not language skills.

Resolve companion skills by their names in the current environment; they need
not be installed next to one another. Report a missing skill when the project
requires it. For optional companions, use the project's rules and available
references. Font workflows retain their specialized layout conventions, but
verify actual paths, preview branches, Git remotes, and publication addresses
before use. Do not apply the original repository's addresses to another fork.

## Validation scripts

The bundled scripts optionally validate reference examples. They are neither
application dependencies nor mandatory CI checks. They read resources relative
to their own location, require no particular working directory, and do not
install dependencies. Prepare the tools listed in the relevant reference and
write results to a new task-owned temporary directory.

- Python scripts require Python 3.10 or newer and read text as UTF-8.
- C example checks target native Linux/ELF and require a C compiler with
  ASan/UBSan, Rust with edition 2024 support, Guile 3 development libraries, and
  pkg-config.
- HTTP example checks use POSIX signals and pipes. They require Guile 3 and
  native Fibers, allocate local ports, and clean up the servers they start.
- Hoot examples require the selected Hoot version. Host adapter tests also
  require Node.js; browser checks need the Wasm features required by that
  runtime.

Where supported, select tools through `CC`, `RUSTC`, `PKG_CONFIG`, `GUILE`, or
`HOOT`. Values are split using shell argument syntax but are not executed
through a shell; quote executable paths containing spaces within the variable
value. Report missing dependencies or unsupported platforms rather than treating
them as successful checks.
