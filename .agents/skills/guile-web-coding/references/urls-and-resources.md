# Public URLs and resource responses

Read when configuring a public address, mounting under a path prefix, generating
links, or serving designated resources. Follow the application's route and
publication policy; the paths below are examples, not required routes.

## Keep addresses and paths distinct

A listening address identifies the local socket. A public base URL identifies
the scheme, authority, and optional path prefix used by clients. They can
differ; do not derive a public link from a wildcard listen address or silently
replace a configured public authority with the incoming `Host` header. Interpret
forwarded headers only when the application's proxy contract explicitly permits
it.

Parse the base URL with `(web uri)` and validate its application meaning in
addition to syntactic validity. An HTTP(S) site base normally needs a permitted
scheme and host; userinfo, query, and fragment need an explicit policy. A URI
parser accepting a numeric port is not proof that it is a usable listener port.
Do not impose a new public-address policy on an application with a different
documented contract.

Separate these values in implementation contracts: public origin, mount prefix,
route path or segments, query parameters, and filesystem resource location.
Filesystem joining and URL construction have different separator and escaping
rules. Route matching under a prefix must respect a segment boundary: a mount at
`/journal` must not accidentally accept `/journalism`.

## Construct URLs intentionally

Choose a canonical trailing-slash policy for the base. Standard URL resolution
treats a base ending in a slash as a directory and a base without it as a final
path segment. A reference beginning with `/` starts at the origin root; one
beginning with `//` can select a different authority.

For a base of `https://example.test/journal/`:

| Reference            | Result                               |
| -------------------- | ------------------------------------ |
| `about`              | `https://example.test/journal/about` |
| `/about`             | `https://example.test/about`         |
| `//other.test/about` | `https://other.test/about`           |

Use the application's chosen URL builder consistently. Do not add a mount prefix
twice or let an unexpectedly absolute path bypass it. Encode raw path segments
once; keep an already encoded path distinct from raw user text. Encode query
keys and values separately from path segments and HTML attribute values.

Guile's `build-uri` constructs a URI from components; it does not percent-encode
arbitrary raw path text on the caller's behalf. An explicit component example
is:

```scheme
(use-modules (web uri))

(uri->string
 (build-uri 'https
            #:host "example.test"
            #:path
            (string-append
             "/journal/"
             (encode-and-join-uri-path '("entries" "naïve /")))))
;; => "https://example.test/journal/entries/na%C3%AFve%20%2F"
```

This example assumes the prefix is already validated and the remaining segments
are raw text. Decoding an encoded slash later must not turn that segment into a
filesystem path boundary. See [HTTP URI handling](web-http.md#uri-components).

## Serve only designated resources

Resolve a public URL through the application's resource mapping before opening a
file. Keep URL space separate from configured resource directories. When a
directory mapping is used, enforce containment under the intended decoding and
symlink policy; a textual string-prefix check alone is not sufficient. Do not
expose the checkout or instance data as an unrestricted static root.

Return the representation's actual media type: CSS uses `text/css`, JavaScript
modules need a JavaScript media type such as `text/javascript`, and Wasm uses
`application/wasm`. Preserve binary bytes for Wasm and other binary resources.
An HTML error page with status 200 is not a missing JavaScript or Wasm response.

Distinguish an unknown public URL, a missing mapped file, and an unreadable
file. Use the application's status and diagnostic policy; do not turn every
filesystem exception into a successful empty response or a silent not-found
result. For HEAD, report representation metadata without transmitting the body.
Apply body length and streaming behavior through the selected server's response
contract, including late failures described in [Web and HTTP](web-http.md).

Select cache behavior according to resource identity. A stable URL whose bytes
can change has a different contract from an immutable versioned resource. Do not
copy an upstream application's cache lifetime or timestamp policy without the
same assumptions, and do not hide stale development output by changing headers
instead of fixing which resource is served.

## Focused verification

Exercise root and non-root mounts, a near-match prefix, trailing slashes,
encoded segments, and query values through the selected URL builder and route
matcher. Check an asset's status, media type, bytes, and HEAD behavior. Include
an unknown asset and a non-public path; test the configured symlink policy if it
is relevant. Run resource lookup from another working directory to expose
accidental relative filesystem paths. These are server checks, not instructions
for frontend build integration or a browser test workflow.

## Source basis

[Guile 3.0.11](https://codeberg.org/guile/guile/src/tag/v3.0.11) provides
`module/web/uri.scm`, `module/web/http.scm`, and the `web-uri.test` and
`web-http.test` suites under `test-suite/tests/`. URI components and reference
syntax follow its RFC 3986 model. The resource mapping in
[Guix Data Service at 029880e5](https://codeberg.org/guix/data-service/src/commit/029880e5633789ce96ec363a94d98aed6451430f/guix-data-service/web/render.scm)
is an application example, not a required filesystem or cache policy.
