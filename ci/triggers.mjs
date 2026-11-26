import { createHash } from 'node:crypto';
import { ensure, identifier, matches } from './common.mjs';

function triggerInfo(tag) {
  const font =
    typeof tag === 'string'
      ? /^ci\/package\/([^/]+)\/([a-f0-9]{40})\/[a-f0-9-]{36}$/.exec(tag)
      : null;
  ensure(font && matches(identifier, font[1]), 'Invalid internal trigger');
  return { name: font[1], rev: font[2] };
}

export function triggerKey(tag) {
  triggerInfo(tag);
  return 'trigger-' + createHash('sha256').update(tag).digest('hex');
}

async function reference(api, tag, revision) {
  ensure(triggerInfo(tag).rev === revision, 'Trigger revision differs');

  const ref = await api.request('/git/ref/tags/' + tag, { missing: true });
  ensure(
    !ref || (ref.object.type === 'commit' && ref.object.sha === revision),
    'Trigger was moved',
  );
  return ref;
}

export async function createTrigger(api, tag, revision) {
  if (await reference(api, tag, revision)) return;

  try {
    await api.request('/git/refs', {
      method: 'POST',
      body: { ref: 'refs/tags/' + tag, sha: revision },
    });
  } catch (error) {
    // Reconcile a lost response before deciding that creation failed.
    if (!(await reference(api, tag, revision))) throw error;
  }
}

export async function deleteTrigger(api, tag, revision) {
  if (!(await reference(api, tag, revision))) return;

  try {
    await api.request('/git/refs/tags/' + tag, { method: 'DELETE' });
  } catch (error) {
    if (await reference(api, tag, revision)) throw error;
  }
}
