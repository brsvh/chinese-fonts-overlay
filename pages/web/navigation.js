// Every view is also a complete static page, including under a deployment prefix.
const root = new URL('.', import.meta.url);
const views = new Map();
let pending;
let settleController;
let scrollFrame;

function pagePath(url) {
  return url.pathname.endsWith('/')
    ? url.pathname + 'index.html'
    : url.pathname;
}

function section(url) {
  if (url.origin !== root.origin || !url.pathname.startsWith(root.pathname))
    return;

  const path = pagePath(url).slice(root.pathname.length);

  if (path === 'index.html') return 'preview';
  if (/^manual\/[^/]+\.html$/.test(path)) return 'manual';
}

function readView(page, url) {
  const body = page.body;
  const kind = body.dataset.view;

  if (
    kind !== section(url) ||
    !body.querySelector('main') ||
    (kind === 'manual' &&
      (!body.querySelector('.manual-content') ||
        !body.querySelector('.manual-pager')))
  )
    throw new Error('Unexpected site view');

  return {
    kind,
    body,
    title: page.title,
    href: url.href,
    path: pagePath(url),
    description: page.querySelector('meta[name="description"]')?.content,
    chapter: body
      .querySelector('#manual-sidebar [aria-current="page"]')
      ?.getAttribute('href'),
  };
}

let active = readView(document, new URL(location.href));
views.set(active.kind, active);
const revision = active.body.querySelector('.site-footer').dataset.revision;

// Keep the favicon valid across URL changes, including the move to manual/.
for (const link of document.head.querySelectorAll('link[rel="icon"][href]'))
  link.setAttribute('href', link.href);

function filterKey(url) {
  const params = new URLSearchParams(url.search);
  params.delete('size');
  return params.toString();
}

function savePosition() {
  if (
    !settleController &&
    !document.documentElement.hasAttribute('data-starting') &&
    active.href === location.href
  )
    history.replaceState(
      { ...history.state, position: [scrollX, scrollY] },
      '',
    );
}

function selectChapter(url) {
  const sidebar = active.body.querySelector('.manual-sidebar');
  if (!sidebar) return;

  const links = [...sidebar.querySelectorAll('nav a')];
  const exact = url.hash && links.find((link) => link.href === url.href);
  const current =
    exact || links.find((link) => link.getAttribute('href') === active.chapter);

  for (const link of sidebar.querySelectorAll('[aria-current]'))
    link.removeAttribute('aria-current');

  if (!current) return;
  current.setAttribute('aria-current', exact ? 'location' : 'page');

  for (
    let parent = current.parentElement;
    parent !== sidebar;
    parent = parent.parentElement
  )
    if (parent.tagName === 'DETAILS') parent.open = true;
}

function updateLinks() {
  for (const link of active.body.querySelectorAll('[data-section]')) {
    const last = views.get(link.dataset.section);
    if (last && last !== active) link.href = last.href;
  }
}

function moveToPage(url, position) {
  const main = active.body.querySelector('main');
  const menu = document.getElementById('manual-menu-toggle');
  if (menu) menu.checked = false;

  let target;
  try {
    target = document.getElementById(decodeURIComponent(url.hash.slice(1)));
  } catch {
    // A malformed fragment still has a readable page destination.
  }

  if (target?.closest('[hidden]')) target = undefined;

  // Texinfo node anchors and notice headings are also keyboard destinations.
  if (target && target.tabIndex < 0 && !target.hasAttribute('tabindex'))
    target.tabIndex = -1;

  (target || main).focus({ preventScroll: true });

  if (position) scrollTo(...position);
  else if (target) target.scrollIntoView();
  else scrollTo(0, 0);

  selectChapter(url);
}

async function activatePreview(view) {
  view.body.addEventListener(
    'catalog-settled',
    () => {
      view.catalogReady = true;
    },
    { once: true },
  );

  try {
    const { startCatalogRuntime } = await import('./bridge.js');

    await startCatalogRuntime(view, (url) => {
      if (url.hash && filterKey(url) !== filterKey(new URL(view.href)))
        url.hash = '';
      if (active !== view || url.href === location.href) return;

      cancelNavigation();
      savePosition();
      history.pushState({ position: [scrollX, scrollY] }, '', url);
      view.href = url.href;
    });
  } catch (error) {
    for (const row of view.body.querySelectorAll('#packages > article')) {
      row.hidden = false;
    }

    for (const control of view.body.querySelectorAll('[data-interactive]')) {
      control.disabled = true;
    }

    const status = view.body.querySelector('#status');
    status.hidden = false;
    status.textContent =
      '交互功能未能启动，仍可阅读完整目录和源代码。请刷新页面或使用更新的浏览器后重试。';

    const content = view.body.querySelector('#preview-content');
    content.setAttribute('aria-busy', 'false');
    content.inert = false;
    view.body.querySelector('#preview-loading').hidden = true;

    view.catalogFailed = true;
    window.finishSiteStartup();
    view.body.dispatchEvent(new Event('catalog-settled'));
    console.error('Unable to start the font catalog:', error);
  }
}

async function fetchView(url, signal) {
  const response = await fetch(url, { signal });
  const finalUrl = new URL(response.url);

  if (
    !response.ok ||
    finalUrl.origin !== url.origin ||
    pagePath(finalUrl) !== pagePath(url)
  ) {
    await response.body?.cancel();
    throw new Error('Site page unavailable');
  }

  const page = new DOMParser().parseFromString(
    await response.text(),
    'text/html',
  );

  if (page.querySelector('.site-footer')?.dataset.revision !== revision)
    throw new Error('Site revision changed');

  return readView(page, url);
}

function showView(next) {
  const previous = views.get(next.kind);
  if (previous && previous !== next && next.kind === 'manual') {
    // Keep the open directory branches and the sidebar's own scroll position.
    for (const selector of ['.manual-content', '.manual-pager'])
      previous.body
        .querySelector(selector)
        .replaceWith(next.body.querySelector(selector));
    next.body = previous.body;
  }

  const openDialog = active.body.querySelector('#site-notices[open]');
  if (openDialog && (active.body !== next.body || !history.state?.notices)) {
    openDialog.dataset.navigating = 'true';
    openDialog.close();
  }

  if (active.body !== next.body) {
    document.body.replaceWith(next.body);
  }
  active = next;
  views.set(next.kind, next);

  document.title = next.title;
  const description = document.head.querySelector('meta[name="description"]');
  if (next.description) {
    const meta = description || document.createElement('meta');
    meta.name = 'description';
    meta.content = next.description;
    if (!description) document.head.append(meta);
  } else description?.remove();

  if (next.kind === 'manual') window.finishSiteStartup();
  else if (!previous) activatePreview(next).catch(console.error);
}

function afterReveal(callback) {
  if (document.documentElement.hasAttribute('data-starting'))
    window.siteRevealed.then(callback).catch(console.error);
  else callback();
}

function cancelNavigation() {
  cancelAnimationFrame(scrollFrame);

  if (settleController) {
    settleController.abort();
    settleController = undefined;
  }

  if (!pending) return;

  pending.abort();
  pending = undefined;
  active.body.querySelector('main').removeAttribute('aria-busy');

  const status = document.getElementById('manual-status');
  if (status) status.textContent = '';
}

function scheduleMove(next, url, position, waitForCatalog = true, move = true) {
  cancelAnimationFrame(scrollFrame);
  if (settleController) settleController.abort();

  const controller = new AbortController();
  settleController = controller;

  const finish = () => {
    if (controller.signal.aborted) return;
    if (settleController === controller) settleController = undefined;

    if (active === next && active.href === url.href) {
      if (move) moveToPage(url, position);
      savePosition();
      syncNotices();
    }
  };

  if (waitForCatalog) {
    next.body.addEventListener('catalog-settled', () => afterReveal(finish), {
      once: true,
      signal: controller.signal,
    });
  } else {
    afterReveal(finish);
  }
}

async function navigate(url, fromHistory = false) {
  cancelNavigation();

  const request = new AbortController();
  pending = request;

  const main = active.body.querySelector('main');
  const previous = views.get(section(url));
  const position = fromHistory && history.state?.position;
  const timeout = setTimeout(() => request.abort(), 10000);

  try {
    let next = previous;
    if (next?.path !== pagePath(url)) {
      main.setAttribute('aria-busy', 'true');
      const status = document.getElementById('manual-status');
      if (status) status.textContent = '正在打开页面…';

      next = await fetchView(url, request.signal);
    }

    if (pending !== request) return;

    if (!fromHistory && url.href !== location.href) {
      savePosition();
      history.pushState(null, '', url);
    }

    const filterChange =
      next.kind === 'preview' &&
      !next.catalogFailed &&
      new URL(next.href).search !== url.search;
    const deferMove =
      next.kind === 'preview' &&
      !next.catalogFailed &&
      (filterChange || !next.catalogReady);
    next.href = url.href;
    showView(next);

    if (deferMove) scheduleMove(next, url, position, true);

    if (filterChange) next.body.dispatchEvent(new Event('catalog-location'));
    updateLinks();

    const status = document.getElementById('manual-status');
    if (status) status.textContent = `已打开：${next.title}`;

    if (!deferMove) scheduleMove(next, url, position, false);
  } catch {
    if (pending === request) {
      if (fromHistory) location.replace(url);
      else location.assign(url);
    }
  } finally {
    clearTimeout(timeout);

    if (pending === request) {
      pending = undefined;
      main.removeAttribute('aria-busy');
    }
  }
}

document.addEventListener('click', (event) => {
  if (event.defaultPrevented || event.button !== 0) return;

  if (event.target.closest('button[commandfor="site-notices"]')) {
    event.preventDefault();
    cancelNavigation();
    savePosition();
    history.pushState({ ...history.state, notices: true }, '');
    syncNotices();
    return;
  }

  if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

  const link = event.target.closest('a[href]');
  if (
    !link ||
    link.hasAttribute('download') ||
    (link.target && link.target !== '_self')
  )
    return;

  let url;
  try {
    url = new URL(link.href);
  } catch {
    return;
  }

  if (!section(url)) return;

  event.preventDefault();
  navigate(url).catch(console.error);
});

// The overlay owns one history entry at exactly the underlying view's URL.
function syncNotices() {
  const dialog = document.getElementById('site-notices');
  if (history.state?.notices && !dialog.open) {
    delete dialog.dataset.navigating;
    dialog.showModal();
    dialog.querySelector('article').scrollTop = 0;
  } else if (!history.state?.notices && dialog.open) {
    dialog.close();
  }
}

document.addEventListener(
  'close',
  (event) => {
    const dialog = document.getElementById('site-notices');
    if (event.target === dialog && !dialog.open) {
      const fromNavigation = dialog.dataset.navigating === 'true';
      delete dialog.dataset.navigating;

      if (!fromNavigation) {
        document
          .querySelector('button[commandfor="site-notices"]')
          ?.focus({ preventScroll: true });
        if (history.state?.notices) history.back();
      }
    }
  },
  true,
);

history.scrollRestoration = 'manual';

addEventListener('popstate', () => {
  if (location.href === active.href) {
    if (document.documentElement.hasAttribute('data-starting')) {
      if (pending) cancelNavigation();
      if (!settleController) {
        const current = new URL(location.href);
        const position = history.state?.position;
        scheduleMove(
          active,
          current,
          position,
          false,
          Boolean(position || current.hash),
        );
      }
    } else {
      cancelNavigation();
      syncNotices();
    }
  } else navigate(new URL(location.href), true).catch(console.error);
});

addEventListener(
  'scroll',
  () => {
    cancelAnimationFrame(scrollFrame);
    scrollFrame = requestAnimationFrame(savePosition);
  },
  { passive: true },
);

const initialUrl = new URL(location.href);
const initialPosition = history.state?.position;
const initialMove = Boolean(initialPosition || initialUrl.hash);

updateLinks();
selectChapter(initialUrl);

scheduleMove(active, initialUrl, initialPosition, false, initialMove);
if (active.kind === 'preview') activatePreview(active).catch(console.error);
