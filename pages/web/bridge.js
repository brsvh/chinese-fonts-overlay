// Browser APIs exposed to Hoot. Catalog and preview policy lives in main.scm.
const visibilityCallbacks = new WeakMap();
// Each fixed-size option owns its callback for this static page's lifetime.
const sizeCallbacks = new WeakMap();
const sizeObserver = new ResizeObserver((entries) => {
  for (const entry of entries) {
    if (entry.contentRect.width > 0 && entry.contentRect.height > 0)
      sizeCallbacks.get(entry.target)?.();
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

Promise.resolve()
  .then(() =>
    Scheme.load_main('./main.wasm', {
      user_imports: {
        document: {
          getElementById: (id) => document.getElementById(id),
          querySelectorAll: (selector) => document.querySelectorAll(selector),
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
            return rect.width > 0 &&
              rect.height > 0 &&
              rect.bottom > -margin &&
              rect.top < innerHeight + margin
              ? 1
              : 0;
          },
          setDisabled: (element, value) => {
            element.disabled = value !== 0;
          },
          setText: (element, value) => {
            element.textContent = value;
          },
          setAttribute: (element, name, value) =>
            element.setAttribute(name, value),
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
            } else queueMicrotask(() => callback(1));
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
            requestAnimationFrame(() =>
              requestAnimationFrame(() => callback()),
            ),
          onPresentationReady: (callback) =>
            window.sitePresentationReady.then(() => callback()),
          finishStartup: () => window.finishSiteStartup(),
          url: () => new URL(location.href),
          parameter: (url, key, fallback) =>
            url.searchParams.get(key) ?? fallback,
          setParameter: (url, key, value) => url.searchParams.set(key, value),
          deleteParameter: (url, key) => url.searchParams.delete(key),
          pushURL: (url) => {
            if (url.href !== location.href) history.pushState(null, '', url);
          },
          copyText: (text, success, failure) => {
            Promise.resolve()
              .then(() => navigator.clipboard.writeText(text))
              .then(
                () => success(),
                () => failure(),
              );
          },
          onHistory: (callback) =>
            window.addEventListener('popstate', () => callback()),
          timer: (delay, callback) => setTimeout(() => callback(), delay),
          clearTimer: (id) => clearTimeout(id),
          now: () => String(Date.now()),
          fetchJSON: (url, success, failure) => {
            const controller = new AbortController();
            fetch(url, { signal: controller.signal })
              .then((response) => {
                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                return response.json();
              })
              .then(
                (data) => success(data),
                () => failure(),
              );
            return controller;
          },
          abort: (controller) => controller.abort(),
        },
      },
    }),
  )
  .catch((error) => {
    for (const row of document.querySelectorAll('#packages > article'))
      row.hidden = false;
    for (const control of document.querySelectorAll('[data-interactive]'))
      control.disabled = true;
    document.getElementById('status').hidden = false;
    document.getElementById('status').textContent =
      '交互功能未能启动，仍可阅读完整目录和源代码。请刷新页面或使用更新的浏览器后重试。';
    document
      .getElementById('preview-content')
      .setAttribute('aria-busy', 'false');
    document.getElementById('preview-content').inert = false;
    document.getElementById('preview-loading').hidden = true;
    window.finishSiteStartup();
    console.error('Unable to start the font catalog:', error);
  });
