// Browser APIs exposed to Hoot. Catalog and preview policy lives in main.scm.
const visibilityCallbacks = new WeakMap();
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
      attribute: (element, name) => element.getAttribute(name) ?? '',
      text: (element) => element.textContent,
      query: (element, selector) => element.querySelector(selector),
      has: (element, selector) => (element.querySelector(selector) ? 1 : 0),
      setValue: (element, value) => {
        element.value = value;
      },
      setHidden: (element, value) => {
        element.hidden = value !== 0;
      },
      setDisabled: (element, value) => {
        element.disabled = value !== 0;
      },
      setText: (element, value) => {
        element.textContent = value;
      },
      setAttribute: (element, name, value) => element.setAttribute(name, value),
      onEvent: (element, name, callback) =>
        element.addEventListener(name, () => callback()),
      replace: (element, child) => element.replaceChildren(child),
      clear: (element) => element.replaceChildren(),
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
      url: () => new URL(location.href),
      parameter: (url, key, fallback) => url.searchParams.get(key) ?? fallback,
      setParameter: (url, key, value) => url.searchParams.set(key, value),
      deleteParameter: (url, key) => url.searchParams.delete(key),
      replaceURL: (url) => history.replaceState(null, '', url),
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
}).catch((error) => {
  document.getElementById('status').textContent =
    '交互功能未能启动，仍可阅读完整目录和源代码。请刷新页面或使用更新的浏览器后重试。';
  console.error('Unable to start the font catalog:', error);
});
