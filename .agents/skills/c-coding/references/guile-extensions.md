# Guile Extensions

Read
[Programming in C](https://www.gnu.org/software/guile/manual/html_node/Programming-in-C.html),
[Dynamic Wind](https://www.gnu.org/software/guile/manual/html_node/Dynamic-Wind.html),
and
[Foreign Object Memory Management](https://www.gnu.org/software/guile/manual/html_node/Foreign-Object-Memory-Management.html)
for the selected Guile. Guile-SSH's
[session wrapper](https://github.com/artyom-poptsov/guile-ssh/blob/master/libguile-ssh/session-type.c)
is useful evidence for resource state and associated Scheme references, but its
SMOB representation is not a requirement for new extensions.

## Cleanup across a Scheme callback

Ordinary tail cleanup is skipped when a Guile call throws. This example exposes
the UTF-8 byte count to a callback while a converted buffer is temporarily owned
by C. The callback is deliberately included to exercise a nonlocal exit; a real
byte-count-only operation need not allocate a complete copy.

```c
/* sample-guile.c -- Exercise Guile conversions and native ownership.  */

#include <libguile.h>
#include <stdlib.h>

/* Release the caller-owned UTF-8 buffer DATA.  */
static void
release_utf8 (void *data)
{
  free (data);
}

/* Pass TEXT's UTF-8 byte length to PROCEDURE and return its result.
   Release the temporary buffer on both return and nonlocal exit.  */
static SCM
sample_with_utf8_size (SCM text, SCM procedure)
{
  char *data;
  size_t length;
  SCM result;

  scm_dynwind_begin (0);
  data = scm_to_utf8_stringn (text, &length);
  scm_dynwind_unwind_handler (release_utf8, data, SCM_F_WIND_EXPLICITLY);
  result = scm_call_1 (procedure, scm_from_size_t (length));
  scm_dynwind_end ();
  return result;
}
```

SCM_F_WIND_EXPLICITLY runs this cleanup on ordinary dynwind_end as well as
nonlocal exit. For plain malloc storage, scm_dynwind_free is the shorter
equivalent; the explicit handler shows where a foreign library's destructor
belongs. Never substitute free for a resource released by a Rust or other
library-specific function. Match each successful dynwind_begin with an explicit
end on ordinary return. Using flags 0 rejects continuation reentry into this
already-released resource scope; do not mark it rewindable without a working
reacquisition design.

Use length-aware UTF-8 conversion when the interface accepts embedded NUL. The
returned pointer from scm_to_utf8_stringn is caller-owned; a pointer into
Scheme-managed storage has a different lifetime. Conversion APIs can signal
type, range, encoding, or allocation errors, so account for resources acquired
before conversion as well as before callbacks.

## An explicitly closable foreign object

Append the following code to the same scratch C file. The type owns a converted
UTF-8 buffer; data == NULL means closed. The caller serializes its operations:
concurrent close/read and reentrant close during read are not supported.

```c
/* Type for a UTF-8 buffer owner, initialized once in the intended module.  */
static SCM sample_text_type;

/* Release OBJECT's buffer once and mark the owner closed.  */
static void
sample_text_finalize (SCM object)
{
  void *data = scm_foreign_object_ref (object, 0);

  if (data != NULL)
    {
      scm_foreign_object_set_x (object, 0, NULL);
      scm_foreign_object_unsigned_set_x (object, 1, 0);
      free (data);
    }
}

/* Return a new owner for a UTF-8 copy of the Scheme string TEXT.  */
static SCM
sample_text_new (SCM text)
{
  SCM object = scm_make_foreign_object_0 (sample_text_type);
  size_t length;
  char *data = scm_to_utf8_stringn (text, &length);

  scm_foreign_object_set_x (object, 0, data);
  scm_foreign_object_unsigned_set_x (object, 1, length);
  return object;
}

/* Close a typed OBJECT; repeated close is harmless.  */
static SCM
sample_text_close (SCM object)
{
  scm_assert_foreign_object_type (sample_text_type, object);
  sample_text_finalize (object);
  return SCM_UNSPECIFIED;
}

/* Return OBJECT's text, rejecting a closed or incorrectly typed owner.  */
static SCM
sample_text_read (SCM object)
{
  char *data;
  size_t length;
  SCM result;

  scm_assert_foreign_object_type (sample_text_type, object);
  data = scm_foreign_object_ref (object, 0);
  if (data == NULL)
    scm_misc_error ("sample-text-read", "Object is closed", SCM_EOL);
  length = scm_foreign_object_unsigned_ref (object, 1);
  result = scm_from_utf8_stringn (data, length);
  scm_remember_upto_here_1 (object);
  return result;
}

/* Register the example type and procedures in the current Guile module.  */
void
init_sample (void)
{
  SCM name = scm_from_utf8_symbol ("sample-text");
  SCM slots = scm_list_2 (scm_from_utf8_symbol ("data"),
                          scm_from_utf8_symbol ("length"));

  sample_text_type
      = scm_make_foreign_object_type (name, slots, sample_text_finalize);
  scm_c_define_gsubr ("sample-with-utf8-size", 2, 0, 0,
                      (scm_t_subr) sample_with_utf8_size);
  scm_c_define_gsubr ("sample-text-new", 1, 0, 0,
                      (scm_t_subr) sample_text_new);
  scm_c_define_gsubr ("sample-text-close", 1, 0, 0,
                      (scm_t_subr) sample_text_close);
  scm_c_define_gsubr ("sample-text-read", 1, 0, 0,
                      (scm_t_subr) sample_text_read);
}
```

Create the zero-initialized Scheme wrapper before acquiring the external buffer.
If conversion throws, its finalizer has nothing to release. After acquiring the
buffer, these slot setters attach it without further allocating Scheme values.
This avoids the leak window created by allocating the native object first and
then calling a potentially failing wrapper constructor. For a more complex
handoff, use a cleanup guard and an explicit ownership-transfer state.

The finalizer clears the owner before release and the explicit close operation
uses the same state transition. Finalization is a fallback: it may run at an
unexpected time or never run at process exit. Release externally scarce
resources explicitly. A finalizer cannot report ordinary API errors to a waiting
caller; keep it small and compatible with its execution context.

scm_remember_upto_here_1 keeps the finalizable owner live until after use of its
field. It does not prevent another thread or callback from explicitly closing
that object. Add synchronization only when such sharing is actually supported.
Initialize this fixture once in its intended module; real module exports and
extension loading should follow the existing Scheme module interface.

## GC roots, foreign threads, and control flow

Guile discovers SCM values in its supported stacks, registers, and static data.
A SCM stored in an unrelated C heap allocation is not automatically a durable
root. Use traced allocation or the documented protect/unprotect mechanism where
needed, and release protection when the registration or owner ends. Do not
retain only a raw field pointer and assume its Scheme owner remains reachable.

For an external thread calling the Guile API, establish Guile mode through the
documented entry mechanism such as scm_with_guile. Threads already created by
Guile have different entry requirements. Blocking outside the Guile API may need
scm_without_guile, but code in that region must obey its no-Guile-access
contract. Leaving Guile mode does not automatically make the operation
cooperative with a Fibers scheduler. See
[Initializing Guile](https://www.gnu.org/software/guile/manual/html_node/Initialization.html).

Use an actual C catch boundary when Scheme errors need to become foreign status
values. A dynwind handler releases resources but does not stop the exit from
crossing an intervening Rust frame. A continuation barrier is not a substitute
for an error-translation contract. See [Rust boundaries](rust-boundaries.md).
