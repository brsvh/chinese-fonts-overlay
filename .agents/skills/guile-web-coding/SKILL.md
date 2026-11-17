---
name: guile-web-coding
description: >-
  Write, review, and debug native Guile HTTP handlers, request and response
  conversion, URI routing, public-resource serving, and SXML/HTML generation.
  Use guile-coding for general Scheme and hoot-coding for compiled browser
  code when those companion skills are available.
---

# Guile Web Coding

Apply this skill to native Guile's HTTP and HTML-generation contracts. Read the
actual project's applicable `AGENTS.md`, server implementation, serializer, and
build instructions. Preserve its chosen static or dynamic architecture; this
skill does not require a font catalog, a particular framework, or Hoot.

Resolve bundled references and scripts relative to this skill's installed
directory, independently of the application checkout. Use the target's declared
environment and discover companion skills by name when available. Do not assume
a Nix installation, adjacent skills, a fixed local port, or a particular browser
automation tool.

## Read only the relevant references

- [Request pipeline](references/request-pipeline.md) for handlers, page
  composition, dispatch, and response recovery, with application cases.
- [Web and HTTP](references/web-http.md) for parsed headers, request bodies,
  response encoding, HEAD, URI components, and response failure stages.
- [Public URLs and resources](references/urls-and-resources.md) for public base
  URLs, path prefixes, link construction, and static-resource responses.
- [SXML and HTML](references/web-sxml.md) for component data, serializer
  contracts, escaping, HTML element semantics, and output verification.

The examples identify their source basis; their routes and dependencies are
illustrative, not application requirements. Read the relevant combination when a
change spans several concerns.

## Boundaries with other skills

Use `guile-coding`, when available, for native Scheme modules, errors, resource
ownership, and test drivers. Use `hoot-coding` for Scheme compiled to Wasm;
native Guile Web APIs are not automatically available on that target. Use the
target project's Nix guidance, or `nix-coding` when available, for Nix changes.
A missing optional companion does not invalidate this skill's own guidance.

## HTML generation and resource serving

Preserve the product's language, labels, and metadata ownership. Escape text and
attributes once with the selected SXML serializer. Encode URL path segments
separately; build source permalinks from the target repository's hosting service
and full revision when that feature is required. Keep private input paths and
internal diagnostics out of public HTML, JSON, and browser errors.

Resolve assets against the application's deployment base. Verify root and
subpath hosting where supported. A local preview server should serve only its
configured public output and default to loopback; retain existing bind/port
options and handle occupied ports without terminating unrelated processes.
Resolve URL decoding, traversal, and symlink containment before opening files.
Do not use the whole source checkout as a public document root by accident.

Serve binary assets with their actual media types. Check GET and HEAD through
the real server; HEAD must retain representation metadata without a body.
Distinguish missing files, malformed requests, unsupported methods, and internal
I/O failures. A final recovery handler must not turn every exception into a 404
or an empty success.

Preserve the application's existing no-script and enhancement-failure contract.
Test empty non-void elements and escaping through an HTML parser when changing
markup: an XML serializer alone does not establish HTML correctness. Add
sessions, dynamic endpoints, or build-on-request behavior only when the task and
application architecture require them.

## Verify the changed boundary

Match checks to the actual handler, server, and serializer. Test HTTP
representation through the server when normalization matters, and generated HTML
through its serializer or an available browser when parsing or interaction
matters. Use automation available in the current environment, or report which
browser checks remain unverified. A handler-only change does not require a full
browser workflow. Optional example harnesses document their own dependencies and
platform limits; they are not application runtime dependencies.
