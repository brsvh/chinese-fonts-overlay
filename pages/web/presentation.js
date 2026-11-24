// Shared font readiness for the catalog and static pages, independent of Hoot.
// CSS uses only system fonts until every declared interface face has loaded.
async function loadInterfaceFonts() {
  const timeout = setTimeout(() => window.settleSiteFonts(false), 10000);

  try {
    const faces = [...document.fonts].filter((face) =>
      ['Concourse', 'Triplicate', 'YuYang'].includes(face.family),
    );

    if (faces.length < 2) {
      window.settleSiteFonts(false);
      return;
    }

    await Promise.all(faces.map((face) => face.load()));
    window.settleSiteFonts(true);
  } catch {
    window.settleSiteFonts(false);
  } finally {
    clearTimeout(timeout);
  }
}

loadInterfaceFonts().catch(console.error);

// The manual's HTML is ready immediately; the shared loader still awaits fonts.
if (document.body.dataset.view === 'manual') window.finishSiteStartup();
