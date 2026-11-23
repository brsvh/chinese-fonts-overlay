// Shared font readiness for the catalog and static pages, independent of Hoot.
// CSS uses only system fonts until every declared interface face has loaded.
const fontTimeout = setTimeout(() => window.settleSiteFonts(false), 10000);
Promise.resolve()
  .then(() => {
    const faces = [...document.fonts].filter((face) =>
      ['Concourse', 'Triplicate', 'YuYang'].includes(face.family),
    );
    if (faces.length < 2)
      throw new Error('Interface font declarations missing');
    return Promise.all(faces.map((face) => face.load()));
  })
  .then(
    () => window.settleSiteFonts(true),
    () => window.settleSiteFonts(false),
  )
  .finally(() => clearTimeout(fontTimeout));

if (!document.documentElement.hasAttribute('data-catalog'))
  window.finishSiteStartup();
