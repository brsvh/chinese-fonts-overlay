# Rust Boundaries

Use the [Rustonomicon FFI chapter](https://doc.rust-lang.org/nomicon/ffi.html),
[Rust type layout](https://doc.rust-lang.org/reference/type-layout.html), and
[undefined behavior rules](https://doc.rust-lang.org/reference/behavior-considered-undefined.html)
for the language contract. These rules supplement the C API's own preconditions;
they do not choose the project's crate layout or linkage mode.

## Describe a C ABI, not Rust internals

Use matching declarations for argument types, return types, calling convention,
and exported symbol names. repr(C) controls applicable data layout, not
ownership or validation. Do not expose Rust String, Vec, references, ordinary
enums, or Result by assuming their internal representation is a C struct. Prefer
opaque handles when clients do not need the representation. Validate foreign
numeric tags before constructing a Rust enum.

State whether lengths count bytes or elements and whether buffers can be NULL
when empty. size_t and Rust usize are the matching size types for this example's
shared target, not a portable on-disk format. A pointer/length descriptor does
not itself prove the described allocation exists.

## A borrowed UTF-8 input with a success-only output

This original scratch example distinguishes byte length from Unicode scalar
count and uses an integer status instead of exporting Result. Save as
sample-ffi.h:

```c
/* sample-ffi.h -- Borrowed UTF-8 input for a Rust implementation.  */

#ifndef SAMPLE_FFI_H
#define SAMPLE_FFI_H

#include <stddef.h>
#include <stdint.h>

/* 0: success; 1: invalid NULL argument; 2: unrepresentable input range;
   3: invalid UTF-8.  OUT changes only on success.
   For an accepted nonempty range, DATA covers LENGTH bytes in one live
   allocation, is not modified during the call, and does not overlap OUT.
   OUT is a valid aligned writable size_t object.  No pointer is retained.
   NULL DATA is accepted for LENGTH == 0.  */
int sample_utf8_count (const uint8_t *data, size_t length, size_t *out);

#endif /* not SAMPLE_FFI_H */
```

The companion Rust code uses edition-2024 syntax as a tested example; the
project's selected edition and compiler remain authoritative:

```rust
use std::{ffi::c_int, slice, str};

/// Count Unicode scalar values in a borrowed UTF-8 buffer.
///
/// # Safety
/// For accepted nonempty ranges, data must identify one live allocation of
/// at least length readable bytes and remain unmodified during the call.
/// A non-null out must be aligned, writable for usize, and disjoint from data.
/// The caller must satisfy the target C ABI and these aliasing obligations.
// SAFETY: the fixture reserves this symbol with the declared C signature.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn sample_utf8_count(
    data: *const u8,
    length: usize,
    out: *mut usize,
) -> c_int {
    if out.is_null() || (data.is_null() && length != 0) {
        return 1;
    }
    if length > isize::MAX as usize {
        return 2;
    }
    let bytes = if length == 0 {
        &[]
    } else {
        // SAFETY: the caller supplies a single readable, immutable range;
        // its length was checked above and u8 has alignment one.
        unsafe { slice::from_raw_parts(data, length) }
    };
    let text = match str::from_utf8(bytes) {
        Ok(text) => text,
        Err(_) => return 3,
    };
    let count = text.chars().count();
    // SAFETY: the caller supplies a writable, aligned, disjoint output.
    unsafe { out.write(count) };
    0
}
```

Rust's from_raw_parts requires a non-null aligned pointer even for an empty
slice, so the explicit empty branch matters. It also requires one allocation, an
appropriate maximum length, and a valid lifetime; the simple checks above cannot
verify all caller obligations. See
[from_raw_parts](https://doc.rust-lang.org/std/slice/fn.from_raw_parts.html).
Unicode scalar count is not grapheme count or a browser UTF-16 index.

This function has no allocation, callbacks, unchecked indexing, or unwrap-based
error path. If the real implementation adds work that can panic, reassess its
boundary behavior rather than inheriting the example's simple control flow.

## Calling through a Guile C adapter

This wrapper uses release_utf8 from [Guile extensions](guile-extensions.md).
Compile it in that same translation unit and register sample-count-scalars as a
one-argument procedure using the existing extension registration mechanism.

```c
#include "sample-ffi.h"

/* Return TEXT's Unicode scalar count through the Rust C interface.
   Release the converted input before reporting a foreign failure.  */
static SCM
sample_count_scalars (SCM text)
{
  size_t length;
  size_t count;
  char *data;
  int status;

  scm_dynwind_begin (0);
  data = scm_to_utf8_stringn (text, &length);
  scm_dynwind_unwind_handler (release_utf8, data, SCM_F_WIND_EXPLICITLY);
  status = sample_utf8_count ((const uint8_t *) data, length, &count);
  scm_dynwind_end ();
  if (status != 0)
    scm_misc_error ("sample-count-scalars", "Native conversion failed: ~A",
                    scm_list_1 (scm_from_int (status)));
  return scm_from_size_t (count);
}
```

Rust has returned before the wrapper raises a Scheme exception. This example
does not permit callbacks from Rust; adding them requires the catch boundary
described below, not just this cleanup handler.

## Owned results and matching release functions

For a Rust-owned result, expose the matching Rust destructor alongside creation
or transfer. Document nullability, whether the handle is consumed on failure,
and the lifetime of borrowed accessors. Do not deallocate Box, Vec, or CString
with C free merely because their address looks like a malloc pointer.
Conversely, do not create Rust ownership from arbitrary C-allocated storage.

If a library explicitly transfers ownership through a data/length/capacity
tuple, use its exact allocator, element layout, allocation base, initialized
length, and capacity contract. Do not reconstruct Vec::from_raw_parts from an
arbitrary pointer and length. An opaque owner with accessors is often simpler
than publishing allocator metadata, but follow the actual existing API.

[cbindgen](https://github.com/mozilla/cbindgen/blob/master/docs.md) can derive
headers from Rust declarations when useful. Header generation reduces signature
drift; it does not establish ownership, nullability, aliasing, or concurrency
semantics. The header and linked library must represent the same features and
target. Use the project's build mechanism for generation rather than writing
headers into an assumed source location.

## Exceptions and callbacks

Expected Rust failures should return the agreed status/data representation. A
Rust panic reaching an extern "C" boundary is not a recoverable C error: the
non-unwinding boundary aborts for a Rust panic. If the API promises conversion
of unwinding panics, implement that policy on the Rust side. catch_unwind does
not catch panic=abort, invalid-pointer undefined behavior, or arbitrary foreign
nonlocal exits. Do not switch to C-unwind merely to make those problems appear
handled.

For a Guile-to-Rust operation, convert and acquire in C, call Rust, regain C
control, then release or translate an error to Scheme. If Rust invokes a C
callback that calls Scheme, catch and translate the Scheme exception inside that
callback before returning to Rust. Do not allow a Guile throw or continuation
jump to skip Rust frames needing destructors. Guile dynwind cleanup and Rust
Drop solve different portions of this problem.

For registered callbacks, preserve the context and any Scheme GC roots until
deregistration guarantees that callbacks have stopped. Define reentrancy and the
race with destruction. A native thread must enter Guile correctly before calling
it; a callback being synchronous or asynchronous is part of the API, not
something a function-pointer typedef establishes.
