import { mountStatus } from './adapter.mjs';

const output = document.querySelector('#result');
const root = document.querySelector('#interactive');
const button = root.querySelector('button');
const disposeButton = document.querySelector('#dispose');
const remountButton = document.querySelector('#remount');
const checksButton = document.querySelector('#checks');

const wasmUrl = new URL('browser-main.wasm', import.meta.url).href;
const supportUrl = new URL('.', import.meta.url).href;
let cleanup = null;

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function status(element) {
  return element.querySelector('[data-status]').textContent;
}

/** Own a pending mount result; observe failure through ready. */
function ownMount(start) {
  const controller = new AbortController();
  let active = true;
  let release = null;

  const ready = start(controller.signal).then((dispose) => {
    if (active) release = dispose;
    else dispose?.();
  });
  return {
    ready,
    dispose() {
      active = false;
      controller.abort();
      release?.();
      release = null;
    },
  };
}

async function runChecks() {
  const scratch = root.cloneNode(true);
  scratch.removeAttribute('id');
  scratch.querySelector('button').disabled = false;
  document.body.append(scratch);

  const update = scratch.querySelector('button');
  const notes = [];
  const resources = [];

  try {
    for (let cycle = 0; cycle < 2; cycle += 1) {
      const dispose = await mountStatus(scratch, wasmUrl, supportUrl);
      resources.push(dispose);
      assert(
        status(scratch) === 'Ready',
        'Mount did not initialize Scheme state',
      );
      update.click();
      update.click();
      assert(
        status(scratch) === 'Updates: 2',
        'Repeated events lost or duplicated',
      );
      dispose();
      dispose();
      update.click();
      assert(status(scratch) === 'Updates: 2', 'Disposed listener still ran');
    }
    notes.push('Mount, repeat, dispose, and remount passed');

    let allowResult;
    const gate = new Promise((resolve) => {
      allowResult = resolve;
    });

    const beforeLateMount = status(scratch);
    const delayed = ownMount(async (signal) => {
      const dispose = await mountStatus(scratch, wasmUrl, supportUrl, signal);
      resources.push(dispose);
      await gate;
      return dispose;
    });

    delayed.dispose();
    allowResult();
    await delayed.ready;

    const afterLateMount = status(scratch);
    assert(
      afterLateMount === beforeLateMount,
      'Cancelled mount changed the DOM',
    );
    update.click();
    assert(status(scratch) === afterLateMount, 'Late mount kept its listener');
    notes.push('Disposed owner released a late mount result');

    for (const urls of [
      ['missing.wasm', supportUrl],
      [wasmUrl, 'missing-runtime/'],
    ]) {
      scratch.querySelector('[data-status]').textContent = 'Static status';
      let rejected = false;

      try {
        const unexpected = await mountStatus(scratch, ...urls);
        resources.push(unexpected);
      } catch {
        rejected = true;
      }
      assert(
        rejected && status(scratch) === 'Static status',
        'Failed load did not preserve static status',
      );
    }
    notes.push(
      'Missing program and helper both rejected without replacing content',
    );

    let releaseHost;
    const [runHostWork] = await Scheme.load_main('host-work.wasm', {
      reflect_wasm_dir: supportUrl.replace(/\/$/, ''),
      user_imports: {
        probe: {
          async beginWork(mode) {
            if (mode === 0) return;
            if (mode === 1)
              return Promise.reject(new Error('Expected rejection'));
            if (mode === 2)
              throw new Error('Expected synchronous host failure');
            return new Promise((resolve) => {
              releaseHost = resolve;
            });
          },
        },
      },
    });
    for (const mode of [1n, 2n]) {
      let rejected = false;

      try {
        await runHostWork.call_async(mode);
      } catch {
        rejected = true;
      }
      assert(rejected, 'Host failure became success');
      const values = await runHostWork.call_async(0n);
      assert(values.reflector.car(values) === 'Completed', 'Recovery failed');
    }

    let settled = false;
    const pending = runHostWork.call_async(3n).then((values) => {
      settled = true;
      assert(values.reflector.car(values) === 'Completed', 'Wrong held result');
    });

    const deadline = performance.now() + 3000;
    while (!releaseHost && performance.now() < deadline) {
      await new Promise((resolve) => setTimeout(resolve, 10));
    }
    assert(
      releaseHost && !settled,
      'Pending host work settled early or never started',
    );

    releaseHost();
    await pending;
    notes.push(
      'Async failure, retry, synchronous-throw normalization, and wait passed',
    );
    return notes;
  } finally {
    for (const dispose of resources.reverse()) dispose?.();
    scratch.remove();
  }
}

/** Report a test failure without removing static page content. */
function reportFailure(error) {
  output.textContent = `Probe failed: ${String(error)}`;
}

disposeButton.addEventListener('click', () => {
  cleanup?.();
  cleanup = null;
  output.textContent = 'Disposed; Update should no longer change status';
});

remountButton.addEventListener('click', async () => {
  remountButton.disabled = true;
  disposeButton.disabled = true;
  cleanup?.();
  cleanup = null;

  try {
    cleanup = await mountStatus(root, wasmUrl, supportUrl);
    output.textContent = 'Remounted';
  } catch (error) {
    reportFailure(error);
  } finally {
    remountButton.disabled = false;
    disposeButton.disabled = false;
  }
});

checksButton.addEventListener('click', async () => {
  checksButton.disabled = true;
  output.textContent = 'Checks running';
  let timeout;

  try {
    const notes = await Promise.race([
      runChecks(),
      new Promise((_, reject) => {
        timeout = setTimeout(
          () => reject(new Error('Checks timed out')),
          15000,
        );
      }),
    ]);
    output.textContent = notes.join('\n');
  } catch (error) {
    reportFailure(error);
  } finally {
    clearTimeout(timeout);
    checksButton.disabled = false;
  }
});

try {
  const missing = new URL(location.href).searchParams.has('missing');
  cleanup = await mountStatus(
    root,
    missing ? 'missing.wasm' : wasmUrl,
    supportUrl,
  );
  for (const control of [button, disposeButton, remountButton, checksButton]) {
    control.disabled = false;
  }
  output.textContent = 'Ready for keyboard interaction';
} catch (error) {
  reportFailure(error);
}
