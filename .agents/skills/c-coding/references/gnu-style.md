# GNU C Style

Use the GNU Coding Standards as the default for authored C. The relevant
upstream sections are
[Formatting](https://www.gnu.org/prep/standards/html_node/Formatting.html),
[Comments](https://www.gnu.org/prep/standards/html_node/Comments.html),
[C constructs](https://www.gnu.org/prep/standards/html_node/Syntactic-Conventions.html),
and [Names](https://www.gnu.org/prep/standards/html_node/Names.html).

## Layout

- Indent in two-space steps. A function definition has its return type on the
  preceding line, its name at column one, and outer braces at column one.
  Control-statement braces occupy their own lines, two spaces inside the
  statement; statements inside them go another two spaces in. An unbraced single
  statement is allowed. Use braces to make nested if/else unambiguous.
- Put spaces before argument-list parentheses and after commas. Write pointer
  declarations as `char *data`; keep unary dereference and address operators
  attached to their operands. Use ordinary spaces around binary operators.
- Aim for at most 79 columns. Align continued arguments under the first
  argument. Break expressions before the operator, with indentation and
  parentheses that show precedence. Avoid hand alignment that the configured
  GNU-style formatter immediately destroys.
- Put multiline struct and enum braces on separate lines and indent their
  members. Separate functions with a blank line. Keep else and the trailing
  while of do/while on their own lines.

This original helper demonstrates function layout, an unbraced early return, and
a braced loop body. Its caller supplies an array covering LENGTH bytes whenever
DATA is non-NULL.

```c
/* sample-style.c -- Locate a terminator in a counted byte sequence.  */

#include <stddef.h>

/* Find the first NUL among LENGTH bytes of DATA, or return LENGTH if none
   is present.  NULL DATA is accepted only when LENGTH is zero.  */
size_t
sample_prefix_length (const unsigned char *data, size_t length)
{
  size_t offset = 0;

  if (length == 0)
    return 0;

  while (offset < length && data[offset] != '\0')
    {
      ++offset;
    }
  return offset;
}
```

The brace pair demonstrates placement; a real one-statement loop may omit it.

## Names and declarations

Use lowercase_with_underscores for functions, variables, members, and tags. Use
uppercase for macros and enum constants. Choose informative exported names and
short local names only when their meaning is clear. Avoid obscure abbreviations
and shadowing global identifiers. Retain foreign names such as SCM or a required
scanner entry point exactly as the API defines them.

Declare types explicitly. Keep external declarations in headers or near the top
of the implementation, not inside functions. Use proper prototypes and `(void)`
for a no-argument C function. Separate a struct's definition from the
declaration of an instance or typedef. Give different purposes different local
variables and keep them in the smallest useful scope. Do not spread several
variables from one declaration over multiple lines; separate pointer
declarations to keep each declarator clear.

Prefer an enum for named integer constants when its type/range fits and the
preprocessor does not need them. Do not export an enum's incidental layout as a
fixed-width ABI. Separate assignments from if conditions; use an assignment in a
while condition only when it makes the iteration clear. GNU style does not
require K&R definitions, declarations restricted to block beginnings, casts of
malloc, GNU language extensions, or one particular C standard.

## Comments and formatting tools

Start a source file with a short comment describing its purpose. Document each
function's behavior, unusual argument constraints, result, ownership, and
failure behavior at its declaration or definition. A public header can carry the
contract without duplicating it word for word above the implementation. Explain
meaningful static variables. Comments should add information beyond the name and
conventional C types.

Use `/* ... */` comments with complete English sentences and two spaces between
sentences and before the closing delimiter. Refer to parameter values with
uppercase argument names in prose. Annotate long or nested conditional
compilation endings with the condition and its sense; a short obvious guard does
not need extra ceremony. Keep license and generated notices intact where they
already belong; this style guide is not a source-file boilerplate template.

Inspect the target's formatter configuration and development environment. If
`.clang-format` is generated, change its maintained source rather than the
generated file. Do not assume a Nix devshell or a particular configuration path.
When no project configuration exists, an available clang-format can use the
`GNU` preset directly; do not add a required formatter dependency for this
skill.

Running clang-format is optional. Manual formatting, Emacs CC Mode, or GNU
indent are acceptable ways to follow the style. The formatter is not part of
treefmt or the commit checks; this skill does not require adding a new gate.
When useful, enter the project's declared environment and format only the
selected file. Here `source_file` is the actual file selected for the task:

```sh
clang-format --style=file -i "$source_file"
```

With no applicable configuration, use `--style=GNU` instead. For an optional
check, add `--dry-run --Werror` and omit `-i`, if the selected version supports
those flags. Review the result: presets cannot provide meaningful comments or
establish API safety. Do not rewrite unrelated files for a small C change.
Retain narrow, explicit local exceptions and third-party interfaces.
