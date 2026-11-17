# Native Guile Web and HTTP

Read only for native HTTP handlers, routing, request/response conversion, or
public resource serving. Ordinary Scheme edits do not require this reference.
For markup, additionally read [SXML and HTML](web-sxml.md). For native
concurrency, inspect the actual backend's scheduler and resource contracts; a
static preview alone does not justify adding a concurrent server.

## Keep the server contract visible

Guile's `(web server)` handler receives a request and a materialized body and
returns a response and body. That server also supports explicit state through
additional arguments and values. Do not assume a different backend or concurrent
server preserves this state protocol. Knots currently supplies a body port; read
it within its request lifetime and apply the application's size limits.

Use `(web request)`, `(web response)`, and `(web uri)` accessors instead of
inspecting private records. Guile headers use parsed Scheme values, not
uniformly raw strings: for example,
`(content-type . (text/plain (charset . "utf-8")))`. Use `build-response` for
status and headers, and preserve repeated-header semantics where the particular
header allows them.

Keep the handler's content decisions separate from transport effects. Define
expected method, path, and content failures through the existing response
contract. Handle unexpected exceptions at a boundary that still owns the failed
operation and can perform its recovery policy. Do not expose a backtrace or turn
an unexpected error into successful empty content.

## Error stages and response commitment

Determine which implementation owns parsing, handler invocation, normalization,
and writing before adding another catch around the handler. A handler wrapper
does not automatically catch a later response producer or socket-write failure.

| Stage                                                            | Recovery boundary                                                                                                                                                          |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Request parsing or body reading                                  | The server's request reader decides whether a valid error response is possible and whether to close the connection.                                                        |
| Routing and input validation                                     | Return the application's expected failure response; keep diagnostics distinct from a successful result.                                                                    |
| Rendering, encoding, or normalization before response commitment | The request owner may produce its failure response, while preserving useful internal diagnostics.                                                                          |
| Response production or writing after commitment                  | Do not attempt a second status line or append an error page to a partial body. End the failed response/connection according to the server contract and report the failure. |

Treat commitment as the point after which the server can no longer replace the
response cleanly; buffering details do not justify assuming that replacement is
always possible. Distinguish a disconnected client from an application renderer
failure in diagnostics. Release the request's owned resources on either path. Do
not swallow process termination or interruption as an ordinary application 500;
honor the selected server's control-flow contract.

Keep a fallback error response simple enough that it does not repeat the failing
renderer or resource lookup. Preserve the original failure if reporting or
cleanup also fails. These are response-recovery rules, not a new application
error type hierarchy or a mandate to expose exception objects publicly.

## Strings, bytes, and HEAD

In Guile 3.0.11, `sanitize-response` encodes string bodies using the declared
charset, defaulting to UTF-8, and adds byte-based content length. A supplied
length must match the encoded bytes. A procedure body is buffered into a string
or bytevector by this implementation; it is not evidence of streaming support.
This is the ordinary `(web server)` path, including its `'fibers` I/O backend.

Fibers 1.4.3's separate `(fibers web server)` implementation has its own
`sanitize-response`. It retains a procedure body and calls it from `client-loop`
after `write-response`; without a declared content length it uses chunked
output. Errors while running that producer occur outside its handler-to-500
conversion. Do not transfer the ordinary Guile server's buffering and error
timing to this entry point merely because procedure names match. Check the
actual version and response path before selecting buffered or streaming
production.

A small explicit byte boundary avoids confusing character count with byte count:

```scheme
(use-modules (rnrs bytevectors)
             (web response))

(define (text-response text)
  "Return an HTTP response and UTF-8 bytes for TEXT."
  (values
   (build-response
    #:headers '((content-type . (text/plain (charset . "utf-8")))))
   (string->utf8 text)))
```

Let the server compute length when it owns body normalization. For file or
streaming responses, use the selected implementation's supported byte-count and
lifetime contract rather than copying this in-memory example.

For HEAD, route according to the application's intended GET/HEAD relationship.
Guile's normalizer can suppress the outgoing body while retaining the computed
representation length; it does not make a GET-only route accept HEAD. Avoid
discarding the representation before calculating metadata. Responses whose
status forbids a body need the corresponding bodyless contract, not a normal
error-page body with a different status code.

## URI components

Decode the component whose grammar is known. `uri-decode` defaults to converting
`+` to a space, which is appropriate for form-encoded components but not
ordinary path segments. `split-and-decode-uri-path` splits before decoding,
preserves literal plus signs, and removes empty components; it therefore erases
distinctions such as repeated or trailing slashes. Preserve the raw path when
those distinctions matter to routing or canonical redirects.

Decode once. A decoded `%2F` becomes a slash inside a segment; it must not
silently become a new filesystem boundary. Percent decoding alone does not
validate a route or path. Check how the actual decoder handles malformed escapes
and invalid UTF-8 instead of assuming it rejects every malformed spelling. Parse
query separators before decoding individual keys and values.

Encode individual path segments with `uri-encode` or the corresponding path
builder. URI encoding and HTML attribute escaping are separate operations.

For base URLs, mount prefixes, and file responses, read
[Public URLs and resources](urls-and-resources.md). URI decoding alone does not
establish a route's public-resource authorization.

## Focused verification

Use a non-ASCII body to check encoded bytes, declared charset, content length,
and HEAD output through the actual server. Exercise the relevant method and
not-found behavior. When routing changes, cover encoded delimiters, literal `+`,
and decoding exactly once. Test malformed input according to the intended error
contract rather than whichever incidental exception currently escapes.

For an error-handling change, separately provoke a handler or renderer failure
before commitment and a producer or write failure after commitment where the
selected server supports that path. Assert the promised status or terminated
response, useful diagnostics, and cleanup; do not infer late-failure behavior
from a successful GET/HEAD test against a different server entry point.

Handler-only tests cannot establish network response normalization. Use an
available browser when HTML parsing, rendering, or interaction is the outcome
being changed, and honor any browser explicitly selected by the user.

## Source basis

- [Guile 3.0.11](https://codeberg.org/guile/guile/src/tag/v3.0.11):
  `module/web/server.scm`, `request.scm`, `response.scm`, `uri.scm`, and
  `doc/ref/web.texi`; corresponding `test-suite/tests/web-*.test` files provide
  parser and representation regressions.
- [Fibers 1.4.3 concurrent server](https://codeberg.org/guile/fibers/src/tag/v1.4.3/fibers/web/server.scm)
  contains a separate `sanitize-response`, `handle-request`, and `client-loop`;
  their call order establishes procedure-body streaming and error timing.
- [Guix Data Service 029880e5](https://codeberg.org/guix/data-service/src/commit/029880e5633789ce96ec363a94d98aed6451430f/guix-data-service/web/render.scm)
  illustrates explicit asset handling. Its current response helpers come from
  Safsaf and are not Guile built-ins. Its caching, timestamp, and database
  policies are application choices.

These are provenance references, not mandatory dependency versions or framework
selections.
