#!/usr/bin/env python3
"""Extract and execute the skill's reference fragments in a new scratch directory.

Use a declared development environment with the compilers and libraries described
in references/verification.md. No dependencies are downloaded or installed.
"""
import argparse
from pathlib import Path
import os
import re
import shlex
import shutil
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("output", type=Path, help="A new, nonexistent output directory")
args = parser.parse_args()
if sys.version_info < (3, 10):
    parser.error("Python 3.10 or newer is required")
if not sys.platform.startswith("linux"):
    parser.error("This optional harness requires native Linux/ELF tools")


def tool(variable, default):
    try:
        command = shlex.split(os.environ.get(variable, default))
    except ValueError as error:
        parser.error(f"Invalid {variable}: {error}")
    if not command or shutil.which(command[0]) is None:
        parser.error(f"{variable}: executable not found; select the declared tool environment")
    # The harness changes cwd for compilation; preserve relative executable paths.
    command[0] = os.path.abspath(shutil.which(command[0]))
    return command


compiler = tool("CC", "cc")
rustc = tool("RUSTC", "rustc")
pkg_config = tool("PKG_CONFIG", "pkg-config")
guile = tool("GUILE", "guile")
try:
    flags = subprocess.run(pkg_config + ['--cflags', '--libs', 'guile-3.0'],
                           check=True, capture_output=True, encoding='utf-8',
                           timeout=30)
except (subprocess.SubprocessError, OSError) as error:
    parser.error(f"Guile 3 development files unavailable: {error}")
guile_flags = shlex.split(flags.stdout)
root = args.output.resolve()
root.mkdir(parents=True)
skill = Path(__file__).resolve().parents[1]
env = os.environ.copy()
env.update(GUILE_AUTO_COMPILE="0", XDG_CACHE_HOME=str(root / "cache"))
source = root / "source"
build = root / "build"
logs = root / "logs"
for directory in (source, build, logs):
    directory.mkdir()
steps = []

def run(label, args, expected=0, **extra):
    result = subprocess.run(list(map(str, args)), env=env, cwd=build,
                            encoding='utf-8', stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=120, **extra)
    (logs / (label + '.log')).write_text(result.stdout, encoding='utf-8')
    if (expected == 0 and result.returncode != 0
            or expected != 0 and result.returncode == 0):
        raise RuntimeError(f'{label}: exit {result.returncode}\n{result.stdout}')
    steps.append(label)
    print(f'PASS {label}', flush=True)
    return result.stdout

def snippets(name, language='c'):
    text = (skill / 'references' / name).read_text(encoding='utf-8')
    return re.findall(r'```' + language + r'\n(.*?)```', text, re.S)

def write(name, text):
    path = source / name
    path.write_text(text, encoding='utf-8')
    return path

memory = snippets('memory-and-interfaces.md')
write('sample-bytes.h', memory[0])
write('sample-bytes.c', memory[1])
write('sample-style.c', snippets('gnu-style.md')[0])
write('sample-guile.c', '\n'.join(snippets('guile-extensions.md')))
rust_c = snippets('rust-boundaries.md')
write('sample-ffi.h', rust_c[0])
write('sample-guile-ffi.c', rust_c[1])
write('sample-ffi.rs', snippets('rust-boundaries.md', 'rust')[0])

cc = compiler + [ '-std=c11', '-Wall', '-Wextra', '-Wconversion', '-Werror',
      '-g', '-I', source]
run('headers', cc + ['-x', 'c', '-fsyntax-only', source / 'sample-bytes.h',
                    source / 'sample-ffi.h'])
write('check-style.c', r'''
#include <assert.h>
#include "sample-style.c"
int
main (void)
{
  const unsigned char input[] = {'A', 0xce, 0xbb, 0, 'B'};
  assert (sample_prefix_length (NULL, 0) == 0);
  assert (sample_prefix_length (input, 0) == 0);
  assert (sample_prefix_length (input, 3) == 3);
  assert (sample_prefix_length (input, sizeof input) == 3);
  assert (sample_prefix_length (input + 3, 1) == 0);
  return 0;
}
''')
run('compile-style', cc + [source / 'check-style.c', '-o', build / 'check-style'])
run('style', [build / 'check-style'])
write('allocation-hooks.h', '#include <stddef.h>\nvoid *test_malloc (size_t);\nvoid test_free (void *);\n')
write('check-bytes.c', r'''
#include "sample-bytes.h"
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#ifdef INJECT_ALLOCATION
static int fail_next;
static size_t live;
void *test_malloc (size_t length)
{
  void *data;
  if (fail_next)
    {
      fail_next = 0;
      return NULL;
    }
  data = malloc (length);
  if (data != NULL)
    ++live;
  return data;
}
void
test_free (void *data)
{
  if (data != NULL)
    {
      assert (live > 0);
      --live;
    }
  free (data);
}
#endif
int
main (void)
{
  const unsigned char input[] = {'A', 0, 0xce, 0xbb};
  struct sample_bytes out = {NULL, 0};
  assert (sample_bytes_copy (input, sizeof input, &out) == SAMPLE_OK);
  assert (out.data != input && out.length == sizeof input);
  assert (memcmp (out.data, input, sizeof input) == 0);
  assert (out.data[out.length] == 0);
  sample_bytes_clear (&out);
  assert (out.data == NULL && out.length == 0);
  sample_bytes_clear (&out);
  sample_bytes_clear (NULL);
  assert (sample_bytes_copy (NULL, 0, &out) == SAMPLE_OK);
  assert (out.data != NULL && out.length == 0 && out.data[0] == 0);
  sample_bytes_clear (&out);
  assert (sample_bytes_copy (NULL, 1, &out) == SAMPLE_INVALID);
  assert (out.data == NULL && out.length == 0);
  assert (sample_bytes_copy (input, SIZE_MAX, &out) == SAMPLE_RANGE);
  assert (out.data == NULL && out.length == 0);
  assert (sample_bytes_copy (input, sizeof input, NULL) == SAMPLE_INVALID);
#ifdef INJECT_ALLOCATION
  assert (live == 0);
  fail_next = 1;
  assert (sample_bytes_copy (input, sizeof input, &out) == SAMPLE_NOMEM);
  assert (out.data == NULL && out.length == 0 && live == 0);
  assert (sample_bytes_copy (input, sizeof input, &out) == SAMPLE_OK);
  assert (live == 1);
  sample_bytes_clear (&out);
  assert (live == 0);
#endif
  return 0;
}
''')
run('compile-allocation-hooks', cc + ['-include', source / 'allocation-hooks.h',
    '-Dmalloc=test_malloc', '-Dfree=test_free', '-c', source / 'sample-bytes.c',
    '-o', build / 'sample-bytes-hooks.o'])
run('compile-allocation-test', cc + ['-DINJECT_ALLOCATION',
    source / 'check-bytes.c', build / 'sample-bytes-hooks.o',
    '-o', build / 'check-allocation'])
run('allocation-failure', [build / 'check-allocation'])

san = ['-fsanitize=address,undefined', '-fno-omit-frame-pointer', '-O1']
run('compile-sanitized', cc + san + [source / 'sample-bytes.c',
    source / 'check-bytes.c', '-o', build / 'check-sanitized'])
write('bad-control.c', '''#include <stdlib.h>
int
main (void)
{
  volatile char *data = malloc (8);
  if (data == NULL)
    return 2;
  data[8] = 1;
  free ((void *) data);
  return 0;
}
''')
run('compile-bad-control', cc + san + [source / 'bad-control.c',
    '-o', build / 'bad-control'])
env['ASAN_OPTIONS'] = 'detect_leaks=1'
output = run('sanitizer-control', [build / 'bad-control'], expected=1)
if 'heap-buffer-overflow' not in output:
    raise RuntimeError('The sanitizer control did not report the expected defect: ' + output)
run('sanitized-bytes', [build / 'check-sanitized'])
env.pop('ASAN_OPTIONS')

run('compile-rust', rustc + ['--edition=2024', '--crate-name=sample_ffi',
    '--crate-type=cdylib', '-C', 'opt-level=2', '-D', 'warnings',
    source / 'sample-ffi.rs', '-o', build / 'libsample_ffi.so'])
write('check-ffi.c', r'''
#include "sample-ffi.h"
#include <assert.h>
int
main (void)
{
  const uint8_t text[] = {'A', 0xce, 0xbb, 0};
  const uint8_t emoji[] = {0xf0, 0x9f, 0x98, 0x80};
  const uint8_t invalid[] = {0xff};
  size_t count = 99;
  assert (sample_utf8_count (text, sizeof text, &count) == 0 && count == 3);
  assert (sample_utf8_count (emoji, sizeof emoji, &count) == 0 && count == 1);
  assert (sample_utf8_count (NULL, 0, &count) == 0 && count == 0);
  assert (sample_utf8_count (text, 0, &count) == 0 && count == 0);
  count = 99;
  assert (sample_utf8_count (NULL, 1, &count) == 1 && count == 99);
  assert (sample_utf8_count (text, sizeof text, NULL) == 1);
  assert (sample_utf8_count (text, SIZE_MAX, &count) == 2 && count == 99);
  assert (sample_utf8_count (invalid, sizeof invalid, &count) == 3 && count == 99);
  return 0;
}
''')
rust_link = ['-L', build, '-lsample_ffi', '-Wl,-rpath,' + str(build)]
run('compile-c-rust', cc + [source / 'check-ffi.c'] + rust_link
    + ['-o', build / 'check-ffi'])
run('c-rust', [build / 'check-ffi'])

write('check-guile.c', r'''
#include <stdlib.h>
#include <stdatomic.h>
static atomic_ulong release_count;
static void
tracked_free (void *data)
{
  if (data != NULL)
    atomic_fetch_add (&release_count, 1);
  free (data);
}
#define free tracked_free
#include "sample-guile.c"
#include "sample-guile-ffi.c"
#undef free
static SCM
releases (void)
{
  return scm_from_ulong (atomic_load (&release_count));
}
static SCM
finalize_now (SCM object)
{
  scm_assert_foreign_object_type (sample_text_type, object);
  sample_text_finalize (object);
  return SCM_UNSPECIFIED;
}
void
init_sample_test (void)
{
  init_sample ();
  scm_c_define_gsubr ("sample-release-count", 0, 0, 0, (scm_t_subr) releases);
  scm_c_define_gsubr ("sample-finalize-now", 1, 0, 0, (scm_t_subr) finalize_now);
  scm_c_define_gsubr ("sample-count-scalars", 1, 0, 0,
                      (scm_t_subr) sample_count_scalars);
}
''')
# Treat dependency include directories as system headers while retaining all
# selected warnings for the handwritten extension and test wrapper.
guile_flags = [item for flag in guile_flags
               for item in (['-isystem', flag[2:]] if flag.startswith('-I')
                            else [flag])]
run('compile-guile', cc + ['-O2', '-shared', '-fPIC', source / 'check-guile.c']
    + guile_flags + rust_link + ['-o', build / 'libsample_guile.so'])
write('check-guile.scm', r'''
(use-modules (srfi srfi-64))
(load-extension (cadr (command-line)) "init_sample_test")
(test-begin "c-coding-boundaries")
(define runner (test-runner-current))
(define text (string #\A #\nul (integer->char #x3bb)))
(define before (sample-release-count))
(test-equal "UTF-8 byte count" 4 (sample-with-utf8-size text identity))
(test-equal "ordinary callback cleanup" (+ before 1) (sample-release-count))
(set! before (sample-release-count))
(test-equal "throw exits callback" 'caught
  (catch 'sample-failure
    (lambda () (sample-with-utf8-size text (lambda (n) (throw 'sample-failure))))
    (lambda args 'caught)))
(test-equal "throw cleanup" (+ before 1) (sample-release-count))
(set! before (sample-release-count))
(test-error "wrong callback" #t (sample-with-utf8-size text #f))
(test-equal "wrong callback cleanup" (+ before 1) (sample-release-count))
(set! before (sample-release-count))
(test-error "wrong text" #t (sample-with-utf8-size 17 identity))
(test-equal "no buffer acquired" before (sample-release-count))
(define owner (sample-text-new text))
(test-equal "NUL and Unicode round trip" text (sample-text-read owner))
(do ((i 0 (+ i 1))) ((= i 20))
  (gc)
  (test-equal "live owner survives GC" text (sample-text-read owner)))
(set! before (sample-release-count))
(sample-text-close owner)
(test-equal "close releases once" (+ before 1) (sample-release-count))
(sample-text-close owner)
(sample-finalize-now owner)
(test-equal "close/finalizer idempotence" (+ before 1) (sample-release-count))
(test-error "closed read rejected" #t (sample-text-read owner))
(define empty (sample-text-new ""))
(test-equal "empty owner" "" (sample-text-read empty))
(set! before (sample-release-count))
(sample-finalize-now empty)
(test-equal "finalizer callback releases" (+ before 1) (sample-release-count))
(test-error "finalized read rejected" #t (sample-text-read empty))
(sample-text-close empty)
(test-equal "close after finalizer" (+ before 1) (sample-release-count))
(test-error "wrong object" #t (sample-text-read #f))
(set! before (sample-release-count))
(test-equal "Guile-C-Rust scalar count" 3 (sample-count-scalars text))
(test-equal "Guile-C-Rust cleanup" (+ before 1) (sample-release-count))
(test-equal "Guile-C-Rust empty input" 0 (sample-count-scalars ""))
(test-end "c-coding-boundaries")
(exit (if (and (= 0 (test-runner-fail-count runner))
               (= 0 (test-runner-xpass-count runner))) 0 1))
''')
print(run('guile-boundaries', guile + ['--no-auto-compile', '-s',
          source / 'check-guile.scm', build / 'libsample_guile.so']))
print(f'{len(steps)} build/run checks passed')
