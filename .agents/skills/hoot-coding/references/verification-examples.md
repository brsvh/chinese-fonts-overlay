# Verification Across Targets and Hosts

Use the narrowest checks that establish the changed contract. Hoot's
[native test driver](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/test/utils.scm)
keeps SRFI-64 in native Guile while compiling and executing target programs. Its
[FFI tests](https://codeberg.org/spritely/hoot/src/commit/16914de6b483a7406c23ef79139d31fddd5b8534/test/test-ffi.scm)
also exercise imports using host implementations. These are testing patterns,
not instructions to copy Hoot's test infrastructure into the project.

## Execute the shared contract

Save this as `check-shared.scm` beside the scratch `example` directory from
[host examples](host-examples.md#shared-transformation):

```scheme
(import (rename (scheme base)
                (error fail)
                (raise re-raise)
                (for-each for-each-case))
        (scheme write)
        (example preview))

(let ((text (string #\A (integer->char #x1f642) #\B)))
  (unless (equal? (substring text 0 2) (preview-text text 2))
    (fail "Preview changed non-ASCII characters"))
  (unless (equal? "" (preview-text text 0))
    (fail "Zero-length preview was not empty"))
  (unless (equal? text (preview-text text 20))
    (fail "Preview changed a short input")))

(for-each-case
 (lambda (limit)
   (unless
       (eq? 'rejected
            (guard (exception
                    ((error-object? exception) 'rejected)
                    (else (re-raise exception)))
              (preview-text "text" limit)
              'accepted))
     (fail "Invalid character limit was accepted" limit)))
 (list -1 1/2 "2"))

(display "Shared preview checks passed\n")
(flush-output-port)
```

The supplementary character tests a case that differs from indexing a JavaScript
string by UTF-16 code units. This does not establish grapheme segmentation or
normalization. Invalid inputs must actually take the error path; loading the
module alone does not test that contract.

## Compile into the selected output directory

Use project commands first. For an isolated fixture, the following illustrates
separate source and output paths with the inspected Hoot CLI. Here `source_dir`
is the fixture source directory and `artifact_dir` is an existing writable build
or temporary directory; neither is a prescribed project location.

```sh
guile --no-auto-compile -L "$source_dir" "$source_dir/check-shared.scm"
hoot compile -L "$source_dir" -o "$artifact_dir/check-shared.wasm" \
  --run=node "$source_dir/check-shared.scm"
hoot compile -L "$source_dir" --bundle \
  -o "$artifact_dir/browser-main.wasm" "$source_dir/browser-main.scm"
hoot compile --bundle -o "$artifact_dir/async-main.wasm" \
  "$source_dir/async-main.scm"
```

Check the installed `hoot compile --help` and supported warning flags if the
project uses another toolchain. The
[CLI reference](https://files.spritely.institute/docs/guile-hoot/latest/Compiling-from-the-command-line.html)
explains load paths, output paths, bundling, and execution hosts. `--bundle`
copies runtime support files; deploy the matching set through the project's
existing rules rather than maintaining an assumed permanent list of filenames.

A Hoot interpreter run, a JavaScript shell run, and a browser run exercise
different environments. Select the required host explicitly. If a JavaScript
engine lacks a required Wasm feature, report that limitation instead of silently
substituting a different host and calling the original target tested.

## Verify host and asynchronous contracts

A host stub is useful for deterministic contract checks before using a browser:

- Load `browser-main.wasm` with the three `status` imports. Confirm that loading
  alone does not change the text or register a listener. Invoke the returned
  mount procedure, then the registered callback, and confirm the updated text.
- Invoke the returned reflected cleanup procedure. Verify that the registered
  callback can no longer cause updates through the host. A second cleanup should
  leave that disposed instance unchanged.
- Deliberately omit a required import in an isolated test and verify that
  loading fails. Do not replace a missing operation with a no-op to pass it.
- Load `async-main.wasm` and use `call_async(false)` to obtain both result
  values. Use `call_async(true)` to observe rejection. Bound the test wait so an
  unsettled promise is reported as failure rather than hanging the suite.

These are candidate checks for the examples, not a fixed checklist for every
change. JavaScript syntax checking and mock imports do not establish DOM event
semantics or real network loading.

## Verify the actual browser behavior

Serve only designated fixture assets, or use the project's normal application
server. Use the browser tools available in the session for navigation, input,
DOM, console and network inspection. Keep scratch tabs and server processes
owned by the check and clean up only those resources.

For the disposable status example, observe these behaviors through the real page
and its owner lifecycle:

| Scenario                    | Observable evidence                                                      |
| --------------------------- | ------------------------------------------------------------------------ |
| Normal mount                | The existing status becomes `Ready` after the entry executes.            |
| Button input                | Successive clicks produce `Updates: 1`, then `Updates: 2`.               |
| Disposal                    | After cleanup, clicking no longer changes the status.                    |
| Replacement                 | After disposing and mounting again, the first click produces one update. |
| Missing optional markup     | Mount returns no instance and preserves the page.                        |
| Failed Wasm or helper fetch | Initialization reports failure and retains the server-rendered content.  |
| Scripts disabled            | The page retains its established reading or navigation behavior.         |

If the owner supports replacement during loading, also verify disposal of a late
result. Reuse its existing lifecycle rather than adding production state only to
satisfy a test. Browser globals used by a scratch test harness are not an
application API.

Wait for an observable readiness or interaction result with a bounded timeout.
Document readiness alone is insufficient. Check the actual requested asset URLs,
status, MIME type, and console errors when loading fails. Distinguish fetch,
compilation, linking, initialization, and later callback failures.

## Report precisely

For a native SRFI-64 driver, preserve its failure exit status, including
unexpected passes where the runner distinguishes them. A scratch assertion
failure or rejected promise must also reach a nonzero process exit or an
explicit browser-test failure.

Report which toolchain and hosts ran, behavior covered, results, and any
remaining gaps. Do not pin those observed versions in the skill or claim all
browser support from one Chrome session. Generated Wasm, compiler caches,
browser profiles, traces, and test logs belong in selected build or temporary
locations.

## Retained current-runtime browser probe

This optional fixture uses Python 3.10 or newer and a selected Hoot compiler.
Its separate host-stub checks need Node with `node:test` and the APIs imported
by `scripts/check-action.mjs`; actual browser checks need an engine supporting
the selected Hoot runtime. These are fixture requirements, not application
runtime dependencies or a replacement for the target's build/test architecture.
Use the target project's prescribed language for maintained test drivers.

The [builder](../scripts/build-browser-probe.py) extracts the actual Scheme and
loader fences from host-examples and host-promises, then invokes the selected
Hoot compiler with bundled matching runtime resources. It copies only the
[small browser harness](../examples/browser-probe/index.html) into a new output
directory. No application source, package manager, or TypeScript is involved.

Resolve `skill_dir` to this skill's installed directory and allocate a unique
`scratch_dir` through the environment's temporary-directory facility. Choose a
nonexistent `probe` child for the builder. The compiler is found on PATH or via
`HOOT` (a shell-style command/argument list, executed without a shell). The
following POSIX-shell example works independently of the invocation directory:

```sh
python3 "$skill_dir/scripts/build-browser-probe.py" "$scratch_dir/probe"
python3 -m http.server 0 --bind 127.0.0.1 --directory "$scratch_dir/probe"
```

Use the assigned port reported by the server, or explicitly choose an available
port if the selected server cannot report an ephemeral port. Serve only this
generated fixture directory and stop the owned server afterwards. Load
index.html in the actual browser and use keyboard input to activate Update
twice: status must become Updates: 2. Dispose, activate Update again, then
remount and activate once: disposed state must remain unchanged; the new count
must be 1.

Run contract checks for repeated lifetimes, cleanup of a late mount result,
missing application/helper Wasm, and compiled host-Promise outcomes. The
late-result test gates the mount's returned cleanup handle; it checks both
absence of publication after invalidation and eventual resource cleanup, not
cancellation of a network request. The fixture's async adapter normalizes both
rejected Promises and synchronous host throws. A held Promise must remain
pending until explicitly released; a subsequent successful call must work.

Load index.html?missing to check that failure leaves static content readable.
Load with scripts disabled separately when validating the no-script contract.
The status harness reports a timeout after 15 seconds; timing out does not
cancel an underlying Wasm/host operation. Reload or close that isolated page
before retrying a timed-out run. Intentional missing URLs produce expected
console and network failures; normal load and keyboard actions should not.

This probe is an original adaptation of the callback-identity and ownership
lessons in the historical browser case, compiled with the current toolchain. It
does not claim that the old demo was ported, that permissions were tested, or
that all browser engines support this runtime.

The recorded probe used Hoot 0.9.0 with its bundled runtime and Chrome 152 on
Linux. Actual keyboard input produced counts 1 and 2, disposal prevented a new
count, and remount restarted at 1. The retained contract checks also passed. An
additional page served with `script-src 'none'` kept its static status and
disabled enhancement controls; this is script-blocking evidence, not a claim
that every browser preference or extension was tested.

The browser probe also compiles the actual `make-action-owner` fence into the
[Scheme action](../examples/browser-probe/action.scm). Its
[adapter and checks](../examples/browser-probe/action.mjs) hold host settlement,
reject and retry, reject a duplicate while pending, normalize a synchronous
throw, and settle both success and failure after disposal. The state policy and
visible messages live in Scheme. JavaScript only loads the instance, adapts host
methods, forwards events, and drives test-controlled outcomes.

The Copy link button uses the real Clipboard API. Its normal link remains
available on failure. In Chrome 152 with Hoot 0.9.0, keyboard activation copied
the link, and an actual paste into a temporary text field matched that URL. The
deterministic rejection tests use a controlled host; they do not claim coverage
of every browser's permission policy. The modified mount check also passed with
no DOM publication after pending ownership was invalidated.

For the page lifetime regression, open the navigation target and use browser
Back, then activate Copy link again. Repeat the round trip. Observe
`pageshow.persisted` with a temporary lifecycle probe: a full reload does not
test BFCache restoration. Verify that a cached return keeps one working instance
and that ordinary non-persisted departure still disposes it. Do not use a
synthetic event as evidence that the browser actually cached the page.

The action checks have a separate fifteen-second deadline shared by all their
awaits, including loading and reflected completion. Completion, assertion
failure, and timeout release loaded instances and reject held test jobs; a load
that finishes after timeout is disposed without being run. This ends the
harness's wait, not an arbitrary Wasm computation or host operation. Reload or
close a timed-out isolated page before retrying.

Run the [harness regressions](../scripts/check-action.mjs) with `node --test`
and the resolved script path. They inject a stalled load, a lost reflected
completion, a stalled duplicate, and an assertion failure while host work is
held. They check bounded failure, late disposal, settlement of held jobs, and
observation of late rejection. These Node stubs validate test containment; rerun
the actual compiled action checks in the browser to validate Scheme behavior.

With Hoot 0.9.0 and Chrome 152, two actual BFCache returns retained working Copy
link input, with one pending/success sequence per activation. A subsequent
reload produced a non-persisted departure and disabled the old control before
fresh initialization. A separate injected stalled reflection result around the
compiled action timed out, disposed its owner, and settled the held host job
without a late status update. The four Node containment regressions also passed;
the previous harness timed out in three and failed cleanup in the fourth. These
are local regression results, not additional upstream coverage.
