import {
  bytes,
  ensure,
  fingerprint,
  identifier,
  matches,
  parseJson,
  policy,
  positiveInteger,
  repository,
  sha,
} from './common.mjs';
import {
  fields,
  packageName,
  recordSchema,
  validateContext,
} from './records.mjs';
import { blobSha } from './github.mjs';
import { ApiError } from './http.mjs';

const buildStateBranch = 'font-build-state';

async function readBuildTree(api) {
  const ref = await api.request('/git/ref/heads/' + buildStateBranch, {
    missing: true,
  });

  if (!ref) {
    return { parent: null, tree: null, entries: {} };
  }

  ensure(matches(sha, ref.object.sha), 'Invalid branch revision');

  const commit = await api.request('/git/commits/' + ref.object.sha);
  ensure(matches(sha, commit.tree?.sha), 'Invalid branch tree revision');

  const tree = await api.request(
    '/git/trees/' + commit.tree.sha + '?recursive=1',
  );
  ensure(!tree.truncated, 'Record tree is truncated');
  return {
    parent: ref.object.sha,
    tree: commit.tree.sha,
    entries: Object.fromEntries(
      tree.tree
        .filter((entry) => entry.type !== 'tree')
        .map((entry) => [entry.path, entry]),
    ),
  };
}

function statePath(number) {
  ensure(positiveInteger(number), 'Invalid PR number');
  return 'prs/' + number + '/state.json';
}

export async function readState(
  api,
  number,
  headRepository,
  controller,
  entries,
) {
  entries ??= (await readBuildTree(api)).entries;
  const entry = entries[statePath(number)];

  if (!entry) {
    return {
      schema: recordSchema,
      repository,
      pr: number,
      headRepository,
      controller,
      runId: 0,
      runAttempt: 0,
      receipts: {},
    };
  }

  const state = parseJson(await api.blob(entry));
  fields(state, [
    'schema',
    'repository',
    'pr',
    'headRepository',
    'controller',
    'runId',
    'runAttempt',
    'receipts',
  ]);
  ensure(
    state.schema === recordSchema &&
      state.repository === repository &&
      state.pr === number &&
      state.headRepository === headRepository &&
      positiveInteger(state.runId) &&
      positiveInteger(state.runAttempt) &&
      matches(fingerprint, state.controller) &&
      state.receipts !== null &&
      typeof state.receipts === 'object' &&
      !Array.isArray(state.receipts),
    'PR state identity mismatch',
  );

  if (state.controller !== controller) {
    state.controller = controller;
    state.receipts = {};
    return state;
  }

  for (const [name, item] of Object.entries(state.receipts)) {
    fields(item, [
      'policy',
      'pname',
      'buildKey',
      'buildSucceeded',
      'headSha',
      'mergeSha',
      'runId',
      'runAttempt',
    ]);
    ensure(
      matches(identifier, name) &&
        item.policy === policy &&
        item.buildSucceeded === true &&
        matches(packageName, item.pname) &&
        matches(fingerprint, item.buildKey),
      'Invalid successful receipt',
    );
    validateContext({
      headSha: item.headSha,
      mergeSha: item.mergeSha,
      runId: item.runId,
      runAttempt: item.runAttempt,
    });
  }

  return state;
}

export async function updateBuildState(api, plan, update, guard) {
  ensure(api.writable, 'Record branch writes are disabled');
  const file = statePath(plan.pr);

  for (let attempt = 0; attempt < 5; attempt += 1) {
    await guard();

    const { parent, tree, entries } = await readBuildTree(api);
    const state = await readState(
      api,
      plan.pr,
      plan.headRepository,
      plan.controller,
      entries,
    );
    update(state);

    const data = bytes(state);
    const digest = blobSha(data);

    if (entries[file]?.sha === digest) {
      return parent;
    }

    const blob = await api.request('/git/blobs', {
      method: 'POST',
      body: { encoding: 'base64', content: data.toString('base64') },
    });
    ensure(blob.sha === digest, 'Uploaded blob integrity error');

    const created = await api.request('/git/trees', {
      method: 'POST',
      body: {
        ...(tree ? { base_tree: tree } : {}),
        tree: [{ path: file, mode: '100644', type: 'blob', sha: digest }],
      },
    });
    const commit = await api.request('/git/commits', {
      method: 'POST',
      body: {
        message: 'Record font builds for PR #' + plan.pr,
        tree: created.sha,
        parents: parent ? [parent] : [],
      },
    });
    await guard();

    try {
      if (parent) {
        await api.request('/git/refs/heads/' + buildStateBranch, {
          method: 'PATCH',
          body: { sha: commit.sha, force: false },
        });
      } else {
        await api.request('/git/refs', {
          method: 'POST',
          body: { ref: 'refs/heads/' + buildStateBranch, sha: commit.sha },
        });
      }

      return commit.sha;
    } catch (error) {
      if (!(error instanceof ApiError) || ![409, 422].includes(error.status)) {
        throw error;
      }
    }
  }

  throw new Error('Concurrent record updates; retry publication');
}
