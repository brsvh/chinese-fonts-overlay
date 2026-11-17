/** Check harness failure containment with a controlled reflection stub.
 * Run with node --test. These tests do not validate the compiled Scheme policy.
 */
import assert from 'node:assert/strict';
import { setImmediate as nextTurn } from 'node:timers/promises';
import test from 'node:test';
import { checkAction } from '../examples/browser-probe/action.mjs';

function fixture(t, load) {
  const previous = globalThis.Scheme;
  globalThis.Scheme = { load_main: load };
  t.after(() => {
    if (previous === undefined) delete globalThis.Scheme;
    else globalThis.Scheme = previous;
  });
  const output = { dataset: {}, textContent: 'Static status' };
  const link = { href: 'https://example.invalid/item' };
  return {
    root: { querySelector: (selector) => (selector === 'a' ? link : output) },
    output,
  };
}

function deferred() {
  let resolve;
  let reject;
  const promise = new Promise((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}

test('a timed-out load disposes its late instance without running it', {
  timeout: 2000,
}, async (t) => {
  const loading = deferred();
  let disposed = 0;
  let runs = 0;
  const { root, output } = fixture(t, () => loading.promise);
  await assert.rejects(
    checkAction(root, { timeoutMs: 30 }),
    /Action checks timed out/,
  );
  loading.resolve([
    {
      call_async() {
        runs += 1;
        return Promise.resolve();
      },
    },
    {
      call() {
        disposed += 1;
      },
    },
  ]);
  await nextTurn();
  assert.equal(disposed, 1);
  assert.equal(runs, 0);
  assert.equal(output.textContent, 'Static status');
});

test('lost reflected completion times out even after the host rejects', {
  timeout: 2000,
}, async (t) => {
  const completion = deferred();
  let disposed = 0;
  let runs = 0;
  let hostRejected = false;
  const { root } = fixture(t, async (_url, options) => {
    const host = options.user_imports.action;
    return [
      {
        call_async() {
          runs += 1;
          if (runs > 1) return Promise.resolve();
          host.render('pending', 'Pending');
          host.copyLink(host.currentLink()).catch(() => {
            hostRejected = true;
            host.render('failed', 'Failed');
          });
          return completion.promise;
        },
      },
      {
        call() {
          disposed += 1;
        },
      },
    ];
  });
  await assert.rejects(
    checkAction(root, { timeoutMs: 30 }),
    /Action checks timed out/,
  );
  assert.equal(hostRejected, true);
  assert.equal(disposed, 1);
  completion.reject(new Error('Late reflection failure'));
  await nextTurn();
  assert.equal(runs, 2);
});

test('a stalled duplicate releases held host work after disposing its owner', {
  timeout: 2000,
}, async (t) => {
  let disposed = false;
  let runs = 0;
  let cleanupReason;
  let disposedAtRejection;
  const { root, output } = fixture(t, async (_url, options) => {
    const host = options.user_imports.action;
    return [
      {
        call_async() {
          runs += 1;
          if (runs > 1) return new Promise(() => {});
          host.render('pending', 'Pending');
          return host.copyLink(host.currentLink()).catch((error) => {
            cleanupReason = error.message;
            disposedAtRejection = disposed;
            if (!disposed) host.render('failed', 'Unexpected publication');
          });
        },
      },
      {
        call() {
          disposed = true;
        },
      },
    ];
  });
  await assert.rejects(
    checkAction(root, { timeoutMs: 30 }),
    /Action checks timed out/,
  );
  await nextTurn();
  assert.equal(cleanupReason, 'Action checks finished');
  assert.equal(disposedAtRejection, true);
  assert.equal(output.textContent, 'Pending');
});

test('an assertion failure releases held work and observes its later rejection', {
  timeout: 2000,
}, async (t) => {
  let disposed = false;
  let runs = 0;
  let hostRejected = false;
  const { root } = fixture(t, async (_url, options) => {
    const host = options.user_imports.action;
    return [
      {
        call_async() {
          runs += 1;
          if (runs > 1) return Promise.resolve();
          host.render('wrong', 'Wrong phase');
          return host.copyLink(host.currentLink()).catch((error) => {
            hostRejected = true;
            assert.equal(disposed, true);
            throw error;
          });
        },
      },
      {
        call() {
          disposed = true;
        },
      },
    ];
  });
  await assert.rejects(
    checkAction(root, { timeoutMs: 500 }),
    /Duplicate action or early success/,
  );
  await nextTurn();
  assert.equal(hostRejected, true);
});
