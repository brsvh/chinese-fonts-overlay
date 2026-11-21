import { createHash } from 'node:crypto';
import { ensure, identifier } from './common.mjs';

export function triggerInfo(tag) {
  const site = /^ci\/site\/([a-f0-9]{40})\/[a-f0-9-]{36}$/.exec(tag);
  if (site) return { kind: 'site', rev: site[1] };
  const font =
    /^ci\/package\/(cache|preview)\/([^/]+)\/([a-f0-9]{40})\/[a-f0-9-]{36}$/.exec(
      tag,
    );
  ensure(font && identifier.test(font[2]), 'Invalid internal trigger');
  return { kind: font[1], name: font[2], rev: font[3] };
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
