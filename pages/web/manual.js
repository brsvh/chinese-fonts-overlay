// Progressively enhance real manual links; the static HTML remains authoritative.
(() => {
  const main = document.getElementById('manual-main');
  const sidebar = document.getElementById('manual-sidebar');
  const menu = document.getElementById('manual-menu-toggle');
  const status = document.getElementById('manual-status');
  const base = new URL('./', location.href);
  let renderedPath = location.pathname;
  let pageLink = sidebar.querySelector('[aria-current="page"]').href;
  let pending;
  let scrollFrame;

  function savePosition() {
    if (location.pathname !== renderedPath) return;
    history.replaceState(
      { ...history.state, manualPosition: [scrollX, scrollY] },
      '',
    );
  }

  function selectChapter(url) {
    const links = [...sidebar.querySelectorAll('a')];
    const exact = url.hash && links.find((link) => link.href === url.href);
    const current = exact || links.find((link) => link.href === pageLink);
    for (const link of links) link.removeAttribute('aria-current');
    if (!current) return;
    current.setAttribute('aria-current', exact ? 'location' : 'page');
    for (
      let ancestor = current.parentElement;
      ancestor !== sidebar;
      ancestor = ancestor.parentElement
    ) {
      if (ancestor.tagName === 'DETAILS') ancestor.open = true;
    }
  }

  function moveToPage(url, position) {
    menu.checked = false;
    main.focus({ preventScroll: true });
    let target;
    try {
      target = document.getElementById(decodeURIComponent(url.hash.slice(1)));
    } catch {
      /* A malformed fragment still has a readable page destination. */
    }
    if (position) scrollTo(...position);
    else if (target) target.scrollIntoView();
    else scrollTo(0, 0);
    selectChapter(url);
    savePosition();
  }

  function cancelNavigation() {
    pending?.abort();
    pending = undefined;
    main.removeAttribute('aria-busy');
    status.textContent = '';
  }

  async function navigate(url, fromHistory = false, position) {
    cancelNavigation();
    if (url.pathname === renderedPath) {
      moveToPage(url, position);
      return;
    }
    const request = new AbortController();
    pending = request;
    main.setAttribute('aria-busy', 'true');
    status.textContent = '正在加载章节…';
    const timeout = setTimeout(() => request.abort(), 10000);
    try {
      const response = await fetch(url, { signal: request.signal });
      if (!response.ok || new URL(response.url).pathname !== url.pathname)
        throw new Error('Manual page unavailable');
      const page = new DOMParser().parseFromString(
        await response.text(),
        'text/html',
      );
      if (pending !== request) return;
      const content = page.querySelector('#manual-main .manual-content');
      const pager = page.querySelector('#manual-main .manual-pager');
      const selected = page.querySelector(
        '#manual-sidebar [aria-current="page"]',
      );
      // A different source revision may need new shared styles or scripts.
      const footer = page.querySelector('.site-footer').innerHTML;
      if (
        !content ||
        !pager ||
        !selected ||
        footer !== document.querySelector('.site-footer').innerHTML
      )
        throw new Error('Manual shell changed');
      pageLink = new URL(selected.getAttribute('href'), url).href;
      if (!fromHistory) {
        savePosition();
        history.pushState(null, '', url);
      }
      main.querySelector('.manual-content').replaceWith(content);
      main.querySelector('.manual-pager').replaceWith(pager);
      document.title = page.title;
      renderedPath = url.pathname;
      moveToPage(url, position);
      status.textContent = `已打开：${page.title}`;
    } catch {
      // A newer click supersedes this request. Other failures use the real link.
      if (pending === request) location.assign(url);
    } finally {
      clearTimeout(timeout);
      if (pending === request) {
        pending = undefined;
        main.removeAttribute('aria-busy');
      }
    }
  }

  document.addEventListener('click', (event) => {
    if (
      event.defaultPrevented ||
      event.button !== 0 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey
    )
      return;
    const link = event.target.closest('a[href]');
    if (
      !link ||
      link.hasAttribute('download') ||
      (link.target && link.target !== '_self')
    )
      return;
    const url = new URL(link.href);
    if (
      url.origin !== base.origin ||
      !url.pathname.startsWith(base.pathname) ||
      !url.pathname.endsWith('.html')
    )
      return;
    if (url.pathname === renderedPath) {
      cancelNavigation();
      menu.checked = false;
      if (!url.hash) {
        event.preventDefault();
        if (url.href !== location.href) {
          savePosition();
          history.pushState(null, '', url);
        }
        moveToPage(url);
      }
      return; // Preserve native fragment navigation and history.
    }
    event.preventDefault();
    navigate(url);
  });

  history.scrollRestoration = 'manual';
  addEventListener('popstate', (event) => {
    navigate(new URL(location.href), true, event.state?.manualPosition);
  });
  addEventListener('hashchange', () => selectChapter(new URL(location.href)));
  addEventListener(
    'scroll',
    () => {
      cancelAnimationFrame(scrollFrame);
      scrollFrame = requestAnimationFrame(savePosition);
    },
    { passive: true },
  );
  selectChapter(new URL(location.href));
  savePosition();
})();
