# Building a small request pipeline

Read when adding the first handlers and pages or when route, view, and response
responsibilities have become entangled. These cases concern native Guile Web;
stylesheet generation and browser automation are separate work.

## Guix Data Service: dispatch, represent, then respond

At
[Guix Data Service 029880e5](https://codeberg.org/guix/data-service/src/commit/029880e5633789ce96ec363a94d98aed6451430f),
trace these functions under `guix-data-service/web/`:

| Operation                        | Observed responsibility                                              |
| -------------------------------- | -------------------------------------------------------------------- |
| `server.scm:handler`             | Extracts method/path and acceptable representations before dispatch. |
| `controller.scm:controller`      | Chooses startup or normal handling from explicit readiness state.    |
| `controller.scm:base-controller` | Handles shared routes or returns a non-match for further dispatch.   |
| `view/html.scm:layout`           | Builds the document around supplied head/body data.                  |
| `render.scm:render-html`         | Converts the view to the server's response protocol.                 |

The separation allows route selection to change without rewriting the common
HTML document and permits error responses to choose HTML or JSON at the response
boundary. Its current HTML response uses Safsaf; it is not a Guile built-in. Its
database pools and extensive delegation are reasons for some of this structure,
not prerequisites for a two-page site.

For a first small server, a `match` on method and path can call ordinary page
procedures and one response constructor. Use a deliberate non-match value only
inside dispatch; translate the final non-match into an actual 404. Do not
confuse an unhandled route with an empty page or a handler exception. Extract a
controller abstraction only when multiple routes share a real task such as
validation or loading. Pass page data explicitly instead of making layout
helpers recover the current request from mutable global state.

Guix Data Service allows basic routes while application startup is incomplete
and responds with 503 for other requests. This is useful for asynchronous
initialization. A server whose initialization finishes before listening can
avoid a separate readiness state; adding a health route does not itself make
startup reliable.

## Haunt: compose a body with a layout

[Haunt a154de4a](https://git.dthompson.us/haunt/tree/haunt/builder/blog.scm?id=a154de4a02cfb11c185a851170400ad83b1c914e)
uses ordinary procedures for the post body, collection body, and surrounding
layout. Its blog builder supplies title/body to `with-layout`, then associates
the resulting SXML with `sxml->html` in a serialized artifact.

The transferable part is the explicit flow of content into a document. A small
dynamic site can use `page-body` and `layout` procedures directly and serialize
at its response boundary; it does not need Haunt's theme record, builder
registry, or file-output lifecycle. Introduce a common layout when a second page
shares document structure. Keep a genuinely page-specific section in that page
instead of parameterizing the layout for every possible variant.

Test title, navigation, and body composition with distinct data for two pages.
Repeated content is not proof of successful composition: ensure that one page's
title or metadata does not leak into another request. An empty child sequence
and a text node containing markup characters should retain their intended
meaning through the selected serializer.

## Guix Data Service: classify a failure before choosing a response

`server.scm:start-guix-data-service-web-server` wraps the application handler.
It distinguishes resource-pool exhaustion from other failures, selects 503 or
500 accordingly, and chooses a representation from the request's accepted media
types. An inner handler captures stack context before unwinding; an outer
handler produces the response. This preserves diagnostic context that could
otherwise be lost at the recovery point.

The useful design question is which information must survive unwinding, and
which boundary still owns a response. A small server may need only one recovery
boundary. Add the inner capture only if its exception representation would
otherwise lose needed context; do not duplicate logging in every layer.
Likewise, use 503 for an actual temporary-unavailability policy, not every I/O
exception. A view should not decide retry status or log a request twice.

The upstream fallback can itself render HTML. That does not guarantee recovery
from a broken serializer. Keep a last-resort failure representation independent
of the failed operation when that failure is in scope. A producer that fails
after response commitment follows
[HTTP error stages](web-http.md#error-stages-and-response-commitment), not a
second trip through route dispatch.

## Knots: error reporting must accept the actual request target

[Knots fix 4fa0b99c](https://forge.cbaines.net/cbaines/guile-knots/commit/4fa0b99c454d90f342ab675c1c794b5c739c225c)
repairs `OPTIONS *`. Guile represents this asterisk-form target with a false
`request-uri`; calling `uri-path` on it fails. The assumption appeared in active
request tracking, handler-exception logging, and response-write error logging.
An otherwise legitimate request could fail before its handler, or an intended
500 could fail again while trying to describe the original exception.

The fix introduces a logging helper that emits `"*"` for that representation,
and uses it at each affected observation point. It does not rewrite `*` to `/`
or decide the application's routing policy. Keep diagnostic formatting total for
accepted request representations; sanitizing log output and routing the request
remain separate responsibilities.

The added tests send an actual `OPTIONS * HTTP/1.1` request. With active
tracking enabled, an ordinary handler returns 200. With a deliberately raising
handler, the client still receives 500. Both matter: a successful route alone
would not exercise the broken recovery path. The patch updates response-write
logging too, but these two tests do not demonstrate a failed write after
commitment.

A local check parsed the literal asterisk-form request and verified the false
URI and the corrected helper's `"*"` output at 9a048088. The 200/500
observations above describe the inspected upstream tests, not a local socket
test.

For an analogous change, test the request target at the parser boundary, then
its normal and exceptional paths through the selected server. Preserve the
original failure if diagnostic formatting or output itself fails. A logging
helper is not a replacement for the response-commitment policy in
[HTTP error stages](web-http.md#error-stages-and-response-commitment).

## A task that exposes misplaced responsibilities

Add a second page with distinct title/body, an unknown route, and a deliberate
failure while obtaining page data. Check route selection without a listener,
view composition through the real serializer, and final status/body through the
selected server. Then change the shared document title format in one place.

Success means the two pages remain distinct, the non-match becomes 404, the
unexpected failure stays a failure, and the layout change does not require
editing each handler. This exercises responsibility placement; merely compiling
the handlers or matching one SXML fragment does not.

## Retained selected-backend recovery check

The [server checker](../scripts/check-server.py) runs the small
[server fixture](../examples/server.scm) with `(fibers web server)`. Invoke the
checker by its resolved skill path in an environment providing Guile and native
Fibers. It checks a normal response after handler failure and a disconnected
client, HEAD, asterisk-form targets, and a body producer that fails after a 200
has been committed. The latter must not append a second HTTP status line.

The wrapper closes its own listener when the backend returns on SIGINT, reports
that cleanup, exits, and starts a new process on the same port. This is a
process stop/restart check after bounded requests; it does not prove graceful
draining of in-flight requests. Fibers 1.4.3's `run-server` waits for its signal
condition and does not expose an application worker-join protocol. A returning
server call therefore must not be documented as proof that all handlers ended.
HTTP recovery observations from this fixture apply to this backend, not to Knots
or Guile's other server adapters.

## Optional harness environment

The bundled `scripts/check-server.py` is an optional POSIX fixture requiring
Python 3.10 or newer, Guile 3, and native Fibers. Resolve the script from this
skill's installed directory; it finds its own example without relying on the
working directory. `GUILE` selects the command (including optional arguments),
and the caller supplies module paths. It uses an operating-system-assigned
loopback port and a private temporary directory. The signal/pipe checks are not
a native Windows portability claim. Missing dependencies and unavailable
platform support must be reported rather than counted as successful checks.
