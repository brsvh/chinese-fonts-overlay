# GNU-style commit message reference

## Style classification

This skill uses a portable GNU-style commit message variant.

A commit message consists of:

1. a scoped subject line;

2. a blank separator line;

3. a required GNU-style file bullet list body;

4. optional trailers only when the user or target repository requires them.

The message must describe all staged changes as one commit.

## Required input

Before drafting a commit message, inspect staged changes with:

- `git status --short`
- `git diff --cached --stat`
- `git diff --cached`

The commit message must describe staged changes only.

If scope selection is ambiguous, inspect lightweight local context such as
recent commit subjects or documented contribution rules:

- `git log --format=%s -n 50`
- `CONTRIBUTING*`, `docs/CONTRIBUTING*`, `HACKING*`, `README*`, `docs/README*`,
  or similar repository guidance

Use this local context only to choose a truthful scope or subscope. Do not copy
unrelated project names from examples.

## Subject format

Use exactly one of the following forms:

```text
<scope>: <subscope>: <Verb> <summary>
<scope>: <Verb> <summary>
```

Package version subjects described below constrain this form to:

```text
<pname>: Init at <version>
<pname>: Update to <version>
```

Rules:

1. Scope and subscope tokens must be lowercase.

2. Prefer scope tokens already established by the target repository.

3. The verb must be imperative and capitalized.

4. The subject must not end with a period.

5. Prefer subjects within `60` characters.

6. The subject must remain concise even when approaching the limit.

7. Use the narrowest truthful scope supported by the staged paths and staged
   diff.

8. Use the two-level form when one concrete component clearly dominates the
   change.

9. Use the one-level form when the change is area-wide, cross-cutting within one
   area, or no honest single subscope exists.

## Deriving `scope`

Derive the top-level scope from the staged paths, staged diff, and target
repository conventions.

Apply these rules in order:

1. If the target repository documents compatible scope rules, follow them.

2. If all staged changes belong to one package directory matching
   `packages/**/<package>/`, read that directory's `package.nix` from the Git
   index and use its `pname` as the scope. The package directory is the parent
   directory of `packages/**/<package>/package.nix`. Prefer the staged
   `package.nix` contents with `git show :<path>` so the scope describes the
   commit being created, not unstaged working-tree edits. If the package has no
   readable staged `package.nix` or no clear `pname`, continue to the next rule.

3. If recent commit subjects consistently use a scope token for the staged area,
   prefer that established token.

4. If all staged changes are documentation-only, use the repository's
   documentation scope if one exists; otherwise use `doc`.

5. If the staged changes clearly belong to one source package, module, service,
   command, library, plugin, skill, or profile, use that stable component name.

6. If all staged paths share a meaningful top-level directory, use that
   directory name after normalizing it to a lowercase scope token.

7. For repository-wide changes, top-level metadata, package manifests, or shared
   wiring, use the project-name scope.

8. If no narrow truthful scope exists, use the project-name scope.

Project-name scope:

1. Look for a project name in repository documentation files in this order:
   `docs/README.md`, `README`, then `README.md`.

2. Prefer the first meaningful document title, such as the first Markdown H1,
   setext heading, Org title/level-one heading, or plain README title line.

3. If no project name is found in those files, use the target repository root
   directory name.

4. Normalize the selected project name using the scope normalization rules
   below.

Normalization rules:

1. Keep established repository spelling when it is already lowercase.

2. Lowercase any uppercase letters in derived names.

3. Convert spaces and underscores to hyphens.

4. Drop file extensions from file-derived scopes.

5. Avoid punctuation other than hyphens.

6. Do not use placeholder or example scopes unless they match the target
   repository.

Common portable scopes include:

- `docs`
- `github`
- `lib`
- `tools`

This list is not exhaustive. Prefer the target repository's own vocabulary over
these generic examples.

## Package version subjects

When a single staged package file at `packages/**/<package>/package.nix` adds or
changes the package `version`, constrain the subject summary.

Inspect both the staged file and the previous `HEAD` version when it exists:

- Read the new package metadata with `git show :<path>`.
- Read the old package metadata with `git show HEAD:<path>`.
- Use the staged `pname` as the subject scope.

If the package file is new, or `HEAD` has no version for that package, use:

```text
<pname>: Init at <new-version>
```

If `HEAD` has a different version and the package already existed, use:

```text
<pname>: Update to <new-version>
```

Apply this constraint even when the same staged package commit also changes
hashes, URLs, metadata, or install details. Continue to describe those file
changes in the body bullets.

## Deriving `subscope`

`subscope` is optional.

Rules:

1. Use a subscope only when one stable component under the chosen top-level
   scope clearly dominates the staged changes.

2. Prefer established module, package, command, feature, profile, plugin, skill,
   or service names already used in the repository.

3. For changes under a repeated collection such as `plugins/<name>/`,
   `skills/<name>/`, `packages/<name>/`, or `services/<name>/`, use `<name>` as
   the subscope when all staged changes belong to the same item.

4. Do not invent a subscope that is not supported by the staged diff.

5. If the change crosses multiple components under one top-level scope, omit the
   subscope.

## Preferred verbs

Use the most precise imperative verb that matches the staged diff.

For package version subjects governed by the section above, use `Init` or
`Update` exactly as specified there.

Preferred verbs include:

- `Add`
- `Update`
- `Remove`
- `Move`
- `Fix`
- `Enable`
- `Configure`
- `Import`
- `Use`
- `Set`
- `Bump`
- `Rename`
- `Expose`
- `Switch`
- `Generalize`

Prefer established verbs documented in this file when they fit the change.

## Body policy

A body is always required.

Rules:

1. Always insert exactly one blank line after the subject.

2. Always include a file bullet list body, even for a single-file or trivial
   change.

3. The body must cover the staged files and must not describe unstaged changes.

## Body format

Write the body as GNU-style file bullets.

Each bullet must use this form:

```text
* <path>: <Description...>
```

Rules:

1. Use one bullet per changed file whenever practical.
2. Sort bullets by `<path>` in ascending lexicographic order.
3. Start each bullet description with an uppercase letter.
4. End each bullet description with a period.
5. Keep each bullet concise and file-oriented.
6. State what the file change does.
7. Include why only when needed.
8. Do not replace the bullet list with free-form prose.
9. Do not write `This commit ...`.

## Wrapping rules

Wrap body lines for readability in GNU style.

Rules:

1. Keep body lines within `70` characters.
2. Do not indent continuation lines.
3. Do not leave trailing spaces before a newline.
4. If a bullet wraps, continue on the next line at column `0`.
5. Do not repeat `* <path>:` on continuation lines.

Example:

```text
* src/parser/options.c: Add shared option validation for quoted
values.
```

## Trailer policy

Do not add trailers unless the user or target repository requires them.

When an assistance trailer is required, place it after exactly one blank line
following the body bullets:

```text
Assisted-by: AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]
```

Fill `AGENT_NAME` at skill invocation time by resolving the actual current agent
identity from the running session or its configuration. Do not default it to any
product, tool, or platform name unless that is the configured current agent
name.

For `MODEL_VERSION`, at commit-skill execution time, first inspect the
configuration file or inline configuration entry that defines the current agent
and use its exact `model` value. If the current agent configuration cannot be
located or does not set a model, fall back to the most specific model value
exposed by the active session context. Do not include example model labels or
hard-code either value in this skill; the trailer must use values discovered at
execution time. Omit tool tokens unless a specialized analysis tool was actually
called while preparing the commit.

## Scope fallback

If scope selection is ambiguous, apply this fallback order:

1. Use the two-level form when one component clearly dominates.

2. Otherwise use the one-level form.

3. Use a documented or recently used scope from the target repository when it
   truthfully describes the staged changes.

4. Use the project-name scope for repository-wide changes.

5. Use the project-name scope when no narrower truthful scope exists.

## Content rules

1. Describe all staged changes in one commit message.

2. Keep the subject concise and specific.

3. Keep bullet descriptions concrete and file-oriented.

4. Avoid fluff.

5. Do not use emojis.

6. Do not use decorative Unicode.

7. Do not include URLs or links.

8. Do not use Conventional Commit prefixes unless explicitly requested.

## Recommended examples

- `justfont-example: Init at 0.1`
- `justfont-example: Update to 0.2`
- `doc: Update installation notes`
- `build: Fix release artifact naming`
- `parser: Handle quoted field escapes`
- `ui: settings: Add profile import action`
- `skills: commit: Generalize scope fallback`
