# Memory and Interfaces

Apply the skill's [GNU C style](gnu-style.md). For correctness, consult targeted
CERT rules such as
[MEM35-C allocation sizes](https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/memory-management-mem/mem35-c/)
and
[MEM30-C freed storage](https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/memory-management-mem/mem30-c/).
Do not import an entire compliance profile or embedded-system restrictions.

## A counted copy with explicit failure semantics

This scratch interface copies bytes and appends a convenience NUL. The length
still counts the original bytes, including any embedded NUL. It does not
validate text encoding. Save the declaration as sample-bytes.h:

```c
/* sample-bytes.h -- Owned copies of counted byte sequences.  */

#ifndef SAMPLE_BYTES_H
#define SAMPLE_BYTES_H

#include <stddef.h>

struct sample_bytes
{
  unsigned char *data;
  size_t length;
};

enum sample_status
{
  SAMPLE_OK,
  SAMPLE_INVALID,
  SAMPLE_RANGE,
  SAMPLE_NOMEM
};

/* OUT must be a distinct writable empty owner: {NULL, 0}.
   NULL input is accepted only when LENGTH is zero.  For an accepted
   nonempty input, DATA must cover LENGTH readable bytes.
   Success transfers the allocation to OUT; failure leaves OUT unchanged.  */
enum sample_status sample_bytes_copy (const unsigned char *data, size_t length,
                                      struct sample_bytes *out);

/* Release an initialized owner and reset it to empty.  Repeated clearing
   of the same reset owner is allowed; copied aliases are not new owners.  */
void sample_bytes_clear (struct sample_bytes *bytes);

#endif /* not SAMPLE_BYTES_H */
```

Save this implementation as sample-bytes.c:

```c
/* sample-bytes.c -- Copy and release counted byte sequences.  */

#include "sample-bytes.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum sample_status
sample_bytes_copy (const unsigned char *data, size_t length,
                   struct sample_bytes *out)
{
  unsigned char *copy;

  if (out == NULL || (data == NULL && length != 0))
    return SAMPLE_INVALID;
  if (length == SIZE_MAX)
    return SAMPLE_RANGE;

  copy = malloc (length + 1);
  if (copy == NULL)
    return SAMPLE_NOMEM;
  if (length != 0)
    memcpy (copy, data, length);
  copy[length] = '\0';
  out->data = copy;
  out->length = length;
  return SAMPLE_OK;
}

void
sample_bytes_clear (struct sample_bytes *bytes)
{
  if (bytes != NULL)
    {
      free (bytes->data);
      bytes->data = NULL;
      bytes->length = 0;
    }
}
```

The SIZE_MAX check protects the addition before allocation. It is not a way to
validate the extent of an arbitrary input pointer. The output precondition
prevents overwriting an already owned allocation or corrupting input through
aliasing. For an API that replaces an existing value, construct a temporary
owner and swap only on success instead of silently changing this contract.

An array allocation needs a multiplication check, for example testing
`count > SIZE_MAX / sizeof *items` before computing `count * sizeof *items`.
That arithmetic check is separate from the application's maximum acceptable
input size. For realloc, retain the original pointer until success and handle
zero capacity explicitly. A live pointer into the old allocation cannot remain
valid after an operation that may move it.

## Error and release contracts

The enum above is a local C convention, not a fixed-width cross-language ABI.
Use the actual library's status representation at a foreign boundary.
Distinguish an expected malformed input from allocation failure and internal
corruption. Only return errno when the failed API specifies that it describes
the failure.

Release functions should state whether NULL and repeated release are allowed. Do
not generalize this fixture's idempotent clear to arbitrary third-party
destructors. Zeroing one owner does not make a previously borrowed pointer or
shallow struct copy safe to reuse.

For resources acquired in stages, a cleanup label can release exactly those
stages completed. Preserve the original failure while cleaning up unless a
cleanup error is itself the operation's meaningful result. Calls that can exit
nonlocally need the runtime-specific cleanup mechanism described in
[Guile extensions](guile-extensions.md).
