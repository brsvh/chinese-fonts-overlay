import assert from 'node:assert/strict';
import test from 'node:test';
import { plan, policy, schema, system } from './common.mjs';
import { publicationKey, schedule } from './main.mjs';

const name = 'example.font';
const item = {
  buildKey: 'a'.repeat(64),
  previewKey: 'b'.repeat(64),
  cacheable: true,
  windows: false,
};
const inventory = { policy, system, packages: { [name]: item } };

test('new fonts build without PNG artifacts and reuse successful receipts', () => {
  const base = { policy, system, packages: {} };
  const fresh = plan(base, inventory);
  assert.equal(fresh.tasks.length, 1);
  assert.equal(fresh.tasks[0].build, true);
  assert.equal(fresh.tasks[0].preview, false);
  assert.equal(
    plan(base, inventory, {
      [name]: {
        policy,
        buildKey: item.buildKey,
        buildSucceeded: true,
        previewPublished: false,
      },
    }).tasks.length,
    0,
  );
});

test('retiring previews preserves pending public cache publication', async () => {
  const rev = 'c'.repeat(40);
  const old = 'd'.repeat(40);
  const pending = {
    schema,
    policy,
    observedRev: old,
    inventory,
    pending: { cache: [name], preview: [name] },
    requests: {},
    retired: [],
  };
  const writes = [];
  const tags = [];
  const state = {
    async get(key) {
      return key === 'main-plan' ? pending : null;
    },
    async put(key, value) {
      writes.push([key, structuredClone(value)]);
    },
  };
  const api = {
    async request(path, options) {
      if (path === '/git/ref/heads/main') return { object: { sha: rev } };
      if (path === '/compare/' + old + '...' + rev) return { status: 'ahead' };
      if (path === '/git/refs') {
        tags.push(options.body.ref);
        return {};
      }
      throw Error('Unexpected API request: ' + path);
    },
  };
  const result = await schedule(api, state, { rev }, inventory, inventory);
  assert.deepEqual(result.pending, { cache: [name] });
  assert.deepEqual(Object.keys(result.requests), ['cache:' + name]);
  assert.equal(tags.length, 1);
  assert.ok(tags[0].startsWith('refs/tags/ci/package/cache/' + name + '/'));
  assert.ok(writes.every(([key]) => key === 'main-plan'));
  assert.match(publicationKey('cache', name), /^cache-[0-9a-f]{64}$/);
});
