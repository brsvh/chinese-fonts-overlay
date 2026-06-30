---
name: commit
description: >-
  Commit staged Git changes using a GNU-style scoped subject and file-bullet
  message body. Use when the user invokes this skill, asks to commit staged
  changes, or requests a GNU-style commit.
---

# GNU-style Commit

Use this skill when the user wants staged changes committed with a GNU-style
message.

## Required workflow

Run these commands in order from the target repository root:

1. `git status --short`
2. `git diff --cached --stat`
3. `git diff --cached`

Do not skip these checks.

If nothing is staged, say so clearly and stop.

1. Complete the required workflow above.
2. Read the style reference at `references/gnu-style-commit-message.md`,
   relative to this skill directory.
3. Draft the final commit message using that reference and any compatible local
   commit conventions in the target repository.
4. Check the final message text using the checklist below.
5. Write the message to a temporary file and run
   `git commit -F <temporary-file>`.
6. Report the commit result, including the new commit hash when available.

Do not pause after the user's explicit commit request. Treat that request as
authorization to create the commit. If the environment blocks access to `.git`,
retry with the required sandbox escalation and continue after access is
available.

## Message rules

Follow `references/gnu-style-commit-message.md`.

Hard requirements:

- describe staged changes only;
- use only `scope: Verb summary` or `scope: subscope: Verb summary`;
- derive scope from the staged paths, staged diff, and target repository
  conventions;
- when staged package changes are under `packages/**/<package>/`, derive the
  scope from that package's staged `package.nix` `pname`;
- keep scope tokens lowercase;
- use an imperative capitalized verb;
- omit the trailing period in the subject;
- always include a body after exactly one blank line;
- write the body as `* path: change.` bullets;
- sort bullets by path in ascending lexicographic order;
- keep bullets concise and file-oriented;
- wrap body lines to at most 70 columns in GNU style without indenting
  continuation lines;
- do not use project-specific scopes from the reference examples unless they
  match the target repository.

If the user or target repository requires an assistance trailer, add exactly one
blank line after the body bullets and then a final trailer in this format:

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
called while preparing the commit. Do not list routine shell, git, formatter,
patching, or commit-skill operations as tools.

Before producing or committing a message, check the final message text:

- the subject must use one allowed scope form;
- exactly one blank line must separate the subject from the body;
- every body line must be 70 columns or shorter;
- wrapped bullet continuations must start at column 0;
- every bullet must end with a period;
- any trailer must appear after exactly one blank line following the body, with
  no trailing blank line.

## Output format

Do not output only a proposed message. Commit with the generated message first,
then report the result.
