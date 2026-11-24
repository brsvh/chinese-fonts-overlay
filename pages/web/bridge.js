// Browser APIs exposed to the Hoot preview runtime.
const visibilityCallbacks = new WeakMap();
// Each fixed-size option owns its callback for this static page's lifetime.
const sizeCallbacks = new WeakMap();

const sizeObserver = new ResizeObserver((entries) => {
  for (const entry of entries) {
    if (entry.contentRect.width > 0 && entry.contentRect.height > 0) {
      sizeCallbacks.get(entry.target)?.();
    }
  }
});

const visibilityObserver = globalThis.IntersectionObserver
  ? new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          visibilityCallbacks.get(entry.target)?.(entry.isIntersecting ? 1 : 0);
        }
      },
      { rootMargin: '500px' },
    )
  : null;

async function fetchJSON(url, signal) {
  const response = await fetch(new URL(url, import.meta.url), { signal });

  if (!response.ok) {
    await response.body?.cancel();
    throw new Error(`HTTP ${response.status}`);
  }

  return response.json();
}

function catalogImports(view, pushURL) {
  const body = view.body;

  return {
    document: {
      getElementById: (id) => body.querySelector(`#${CSS.escape(id)}`),
      querySelectorAll: (selector) => body.querySelectorAll(selector),
      createElement: (tag) => document.createElement(tag),
    },

    collection: {
      length: (collection) => collection.length,
      ref: (collection, index) => collection[index],
    },

    element: {
      value: (element) => element.value,
      checked: (element) => (element.checked ? 1 : 0),
      attribute: (element, name) => element.getAttribute(name) ?? '',
      text: (element) => element.textContent,
      query: (element, selector) => element.querySelector(selector),

      setValue: (element, value) => {
        element.value = value;
      },
      setChecked: (element, value) => {
        element.checked = value !== 0;
      },
      setIndeterminate: (element, value) => {
        element.indeterminate = value !== 0;
      },
      setHidden: (element, value) => {
        element.hidden = value !== 0;
      },
      setInert: (element, value) => {
        element.inert = value !== 0;
      },

      inViewport: (element, margin) => {
        if (element.closest('details:not([open])')) return 0;

        const rect = element.getBoundingClientRect();
        const visible =
          rect.width > 0 &&
          rect.height > 0 &&
          rect.bottom > -margin &&
          rect.top < innerHeight + margin;

        return visible ? 1 : 0;
      },

      setDisabled: (element, value) => {
        element.disabled = value !== 0;
      },
      setText: (element, value) => {
        element.textContent = value;
      },
      setAttribute: (element, name, value) =>
        element.setAttribute(
          name,
          name === 'src' ? new URL(value, import.meta.url).href : value,
        ),
      setStyle: (element, name, value) =>
        element.style.setProperty(name, value),

      textFits: (element) =>
        element.scrollWidth <= element.clientWidth &&
        element.scrollHeight <= element.clientHeight
          ? 1
          : 0,

      observeSize: (element, callback) => {
        sizeCallbacks.set(element, callback);
        sizeObserver.observe(element);
      },

      onEvent: (element, name, callback) =>
        element.addEventListener(name, () => callback()),

      clear: (element) => element.replaceChildren(),
      append: (element, child) => element.append(child),

      observe: (element, callback) => {
        if (visibilityObserver) {
          visibilityCallbacks.set(element, callback);
          visibilityObserver.observe(element);
        } else {
          queueMicrotask(() => callback(1));
        }
      },
    },

    json: {
      parse: (text) => JSON.parse(text),
      object: (value, key) => value[key] ?? {},
      text: (value, key) => String(value[key] ?? ''),
      has: (value, key) => (Object.hasOwn(value, key) ? 1 : 0),
    },

    browser: {
      afterPaint: (callback) =>
        requestAnimationFrame(() => requestAnimationFrame(() => callback())),
      onPresentationReady: (callback) =>
        window.sitePresentationReady
          .then(() => callback())
          .catch(console.error),
      finishStartup: () => window.finishSiteStartup(),

      url: () => new URL(view.href),
      parameter: (url, key, fallback) => url.searchParams.get(key) ?? fallback,
      setParameter: (url, key, value) => url.searchParams.set(key, value),
      deleteParameter: (url, key) => url.searchParams.delete(key),
      pushURL,

      copyText: (text, success, failure) => {
        Promise.resolve()
          .then(() => navigator.clipboard.writeText(text))
          .then(
            () => success(),
            () => failure(),
          )
          .catch(console.error);
      },

      onHistory: (callback) =>
        body.addEventListener('catalog-location', () => callback()),
      timer: (delay, callback) => setTimeout(() => callback(), delay),
      clearTimer: (id) => clearTimeout(id),
      now: () => String(Date.now()),

      fetchJSON: (url, success, failure) => {
        const controller = new AbortController();

        fetchJSON(url, controller.signal)
          .then(
            (data) => success(data),
            () => failure(),
          )
          .catch(console.error);

        return controller;
      },
      abort: (controller) => controller.abort(),
    },
  };
}

export async function startCatalogRuntime(view, pushURL) {
  await new Promise((resolve, reject) => {
    const runtime = document.createElement('script');
    runtime.src = new URL('reflect.js', import.meta.url).href;
    runtime.onload = resolve;
    runtime.onerror = reject;

    document.head.append(runtime);
  });

  await Scheme.load_main(new URL('main.wasm', import.meta.url).href, {
    reflect_wasm_dir: new URL('.', import.meta.url).href.replace(/\/$/, ''),
    user_imports: catalogImports(view, pushURL),
  });
}
