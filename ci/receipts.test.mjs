import assert from 'node:assert/strict';
import test from 'node:test';
import { bytes, policy, repository, schema } from './common.mjs';
import { buildStateBranch, statePath, Superseded } from './github.mjs';
import { planningState, saveReceipts } from './receipts.mjs';

const context = {
  headSha: 'a'.repeat(40),
  mergeSha: 'b'.repeat(40),
  runId: 12,
  runAttempt: 1,
};
const run = { id: 12, run_attempt: 1 };
const pull = { number: 3 };
const name = 'example.font';
const controller = 'c'.repeat(64);
const plan = {
  controller,
  context,
  headRepository: repository,
  packages: { [name]: { pname: 'example-font' } },
};
const receipt = {
  buildKey: 'd'.repeat(64),
  previewKey: 'e'.repeat(64),
  buildSucceeded: true,
  previewGenerated: true,
};

function stored(receipts = {}, runId = 1) {
  return {
    schema,
    repository,
    pr: 3,
    headRepository: repository,
    controller,
    runId,
    runAttempt: 1,
    receipts,
  };
}

function apiWithState(initial = null, legacy = null) {
  let state = initial;
  const api = {
    changes: null,
    async branch(branch) {
      const value = branch === buildStateBranch ? state : legacy;
      return { entries: value ? { [statePath(3)]: { value } } : {} };
    },
    async blob(entry) {
      return bytes(entry.value);
    },
    async updateImages(branch, message, prepare) {
      assert.equal(branch, buildStateBranch);
      api.changes = await prepare((await api.branch(branch)).entries);
      state = JSON.parse(api.changes[statePath(3)]);
    },
  };
  return api;
}

test('successful builds remain reusable without a preview artifact or App', async () => {
  const api = apiWithState();
  await saveReceipts(api, run, pull, plan, {
    [name]: receipt,
    'example.failed': { ...receipt, buildSucceeded: false },
  });
  assert.deepEqual(Object.keys(api.changes), [statePath(3)]);
  const state = await planningState(api, 3, repository, controller);
  assert.deepEqual(Object.keys(state.receipts), [name]);
  assert.equal(state.receipts[name].buildKey, receipt.buildKey);
  assert.equal(state.receipts[name].previewPublished, false);
});

test('old preview branch still supplies build receipts until migration', async () => {
  const saved = {
    policy,
    pname: 'example-font',
    ...receipt,
    ...context,
    previewPublished: false,
  };
  const api = apiWithState(null, stored({ [name]: saved }));
  const state = await planningState(api, 3, repository, controller);
  assert.equal(state.receipts[name].buildKey, receipt.buildKey);
});

test('an older run cannot overwrite newer build records', async () => {
  const api = apiWithState(stored({}, 13));
  await assert.rejects(
    saveReceipts(api, run, pull, plan, { [name]: receipt }),
    Superseded,
  );
  assert.equal(api.changes, null);
});
