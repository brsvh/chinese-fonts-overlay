# Build integration

Read when adopting daisyUI, changing stylesheet compilation, or styling HTML
emitted by a template language. Obtain exact paths and commands from the target
project. These are integration choices, not a required application scaffold.

## Choose the dependency boundary

daisyUI can run as a Tailwind build plugin and publish ordinary CSS. Keep the
existing renderer and event system; CSS adoption alone does not require React,
Svelte, Vite, a browser JavaScript compiler, or a new application server.

- In an existing Node-based build, use its package manager and lockfile for
  `tailwindcss`, `@tailwindcss/cli` (when using the CLI), and `daisyui`. Reuse a
  working bundler integration instead of adding a second CSS build.
- For a project without a Node setup, the official Tailwind standalone CLI can
  load the daisyUI release bundles `daisyui.mjs` and `daisyui-theme.mjs`. The
  second bundle supplies the custom-theme plugin. Pin both to the same release
  and provision them before compilation.
- Resolve dependencies through the project's existing reproducibility mechanism.
  Do not put `latest` downloads, package installation, or network requests in an
  otherwise offline build. Preserve third-party license notices.

Package imports use `@plugin "daisyui"` and `@plugin "daisyui/theme"`.
Standalone imports instead point to the corresponding local `.mjs` files.
Resolve plugins relative to the actual CSS entry file, not an assumed working
directory. Keep compiler binaries and plugin bundles out of the public site;
publish the resulting stylesheet through the normal asset pipeline.

## Source detection for generated HTML

Tailwind scans source text, not the renderer's evaluation result. Complete
classes in HTML, Scheme strings, or other templates can be discovered without
executing the application. Register the files that emit classes, including
client-side states that do not appear in the initial HTML.

For a hypothetical stylesheet at `web/style.css`:

```css
@import "tailwindcss" source(none);
@source "./index.html";
@source "./main.scm";
@source "../module";
@plugin "./vendor/daisyui.mjs" {
  themes: false;
}
```

This fragment only illustrates scanning and plugin resolution; a custom theme
must also be defined if built-in themes are disabled. Paths are relative to the
stylesheet. If configuration generates that stylesheet in a separate build
directory, configure paths to the actual sources and dependency bundles, or
preserve their relative layout. Do not accidentally scan an empty build tree.

Prefer explicit sources in repositories containing large catalogs, generated
output, caches, or vendored dependencies. Avoid scanning the whole checkout just
to find a few UI files. An ordinary CSS build should not require generating a
complete data set merely to discover classes already present in templates.

For example, Scheme can select complete class strings:

```scheme
(if selected? "btn btn-sm btn-primary" "btn btn-sm btn-ghost")
```

Constructing `"btn-"` plus a runtime color does not expose the resulting class
to the scanner. Map finite states to complete literals; use `@source inline()`
only for a small, intentional set that cannot appear in scanned sources. For
continuous values such as an image scale, prefer a validated CSS custom property
and a stable selector instead of generating arbitrary utility names.

## Renderer and interaction contracts

Emit the component's required element relationships through the existing
serializer, retaining escaping for text and attributes. Omit false Boolean HTML
attributes; do not serialize `checked="false"`. At runtime, update control
properties, not just initial attributes. In particular, a select-all checkbox's
`indeterminate` state is a DOM property, not an HTML attribute.

In Hoot applications, keep selection, reset, URL state, and asynchronous policy
in Scheme where that is the project's boundary. Add only necessary browser
operations to its host bridge. daisyUI's styling is not a second source of
application state. Native details can own disclosure state; explicit buttons
need their owning handler and accessible state. Choose one owner per control.

For a progressively enhanced site, keep static content and native controls
usable according to the existing fallback contract. Do not expose controls as
working before their required bindings have initialized.

## Nix and Autotools projects

Apply this section only when these tools belong to the target project.

- Check the locked Nixpkgs package, not just its attribute name: a default
  `tailwindcss` attribute may still select v3. Use a verified v4 compiler for
  these CSS-first examples. Prefer dependencies available in those locked
  inputs. If daisyUI is absent, identify the gap explicitly and propose a
  separately pinned package; do not advance the lockfile as an incidental fix.
  Provision standalone plugin bundles using a fixed release and hashes,
  independently of the site's catalog inputs.
- Let configure discover or accept the compiler and plugin paths and report
  missing dependencies clearly. Keep one stylesheet build rule in Make; Nix
  supplies dependencies and invokes that same rule. Do not duplicate the
  compilation in a Nix-only shell fragment.
- Declare the CSS entry, theme files, class-emitting templates, and plugin
  bundles as build inputs. A Scheme-only class change must rebuild CSS. Keep
  stylesheet compilation independent of Wasm compilation unless there is a real
  dependency between them.
- Write CSS and configured intermediates into the build directory. Support
  out-of-tree builds against read-only sources. Keep installation, distribution,
  cleanup, and final publication lists consistent with the new resource.
- Installed static output should need neither the compiler nor source checkout
  at runtime. Development shells should expose the same toolchain as packaged
  builds. Follow the project's requirements for staged installation and release
  checks when changing build rules.

## Verify the integration

Compile from the intended build directory with the declared dependencies and
source paths. Check a class emitted by the server renderer and one used only by
an interactive state; this catches an apparently successful but incomplete
stylesheet. Exercise the final rendered behavior rather than asserting entire
generated CSS files or internal hook names.

Inspect stylesheet loading under the actual deployment base path. Check the
affected controls, overflow, focus, and narrow layout in a browser when
available. Tailwind Preflight can change margins, borders, and image sizing; for
deliberately oversized previews, provide an overflow container and remove the
default image width constraint. A successful compile does not establish browser
support or visual correctness.

## Official sources

- [daisyUI with Tailwind CLI](https://daisyui.com/docs/install/cli/)
- [daisyUI with standalone CLI](https://daisyui.com/docs/install/standalone/)
- [Tailwind source detection](https://tailwindcss.com/docs/detecting-classes-in-source-files)
- [Tailwind compatibility](https://tailwindcss.com/docs/compatibility)
