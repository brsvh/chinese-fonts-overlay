import { loadAction, checkAction } from './action.mjs';
const root = document.querySelector('#action');
const button = document.querySelector('#copy-link');
const output = root.querySelector('[data-action-status]');
let active = true;
let instance = null;
const click = () => {
  instance.run().catch((error) => {
    if (active)
      output.textContent = `Unexpected action failure: ${String(error)}`;
  });
};
window.addEventListener('pagehide', (event) => {
  // A cached page resumes with this instance and its existing listeners.
  if (event.persisted) return;
  active = false;
  button.disabled = true;
  instance?.dispose();
  button.removeEventListener('click', click);
});
try {
  // The contract checks use a separate root; the real button uses Clipboard.
  const fixture = root.cloneNode(true);
  fixture.removeAttribute('id');
  const note = await checkAction(fixture);
  if (active) document.querySelector('#result').dataset.actionChecks = note;
  instance = await loadAction(root);
  if (active) {
    button.disabled = false;
    button.addEventListener('click', click);
  } else {
    instance.dispose();
  }
} catch (error) {
  if (active)
    output.textContent = `Enhancement unavailable; use the ordinary link: ${String(error)}`;
}
