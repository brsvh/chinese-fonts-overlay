/** Load an action without touching the UI until an owned action is invoked. */
export async function loadAction(
  root,
  copyLink = (text) => navigator.clipboard.writeText(text),
) {
  const output = root.querySelector('[data-action-status]');
  const [run, dispose] = await Scheme.load_main(
    new URL('action.wasm', import.meta.url).href,
    {
      reflect_wasm_dir: new URL('.', import.meta.url).href.replace(/\/$/, ''),
      user_imports: {
        action: {
          currentLink: () => root.querySelector('a').href,
          async copyLink(text) {
            await copyLink(text);
          },
          render(phase, message) {
            output.dataset.phase = phase;
            output.textContent = message;
          },
        },
      },
    },
  );
  return { run: () => run.call_async(), dispose: () => dispose.call() };
}

/** Check the compiled policy within one deadline; release owned test work.
 * timeoutMs bounds all asynchronous waits, not the underlying Wasm execution.
 */
export async function checkAction(root, { timeoutMs = 15000 } = {}) {
  if (!Number.isFinite(timeoutMs) || timeoutMs <= 0) {
    throw new RangeError('Expected a positive finite action check timeout');
  }
  const output = root.querySelector('[data-action-status]');
  const jobs = [];
  const instances = [];
  let finished = false;
  let timer;
  const timeoutError = new Error('Action checks timed out');
  const deadline = new Promise((_, reject) => {
    timer = setTimeout(() => reject(timeoutError), timeoutMs);
  });
  const wait = (promise) => Promise.race([promise, deadline]);
  const load = (copyLink) =>
    wait(
      loadAction(root, copyLink).then((instance) => {
        if (finished) {
          instance.dispose();
          throw timeoutError;
        }
        instances.push(instance);
        return instance;
      }),
    );
  const holdCopy = (text) =>
    new Promise((resolve, reject) => {
      if (finished) {
        reject(new Error('Action checks already finished'));
        return;
      }
      jobs.push({ text, resolve, reject });
    });
  const run = (instance) => {
    const result = instance.run();
    // Observe early rejection even if a different assertion fails first.
    result.catch(() => {});
    return result;
  };
  const assert = (value, message) => {
    if (!value) throw new Error(message);
  };
  const waitForJobs = async (count) => {
    const startedBy = performance.now() + 3000;
    while (jobs.length < count && performance.now() < startedBy) {
      await wait(new Promise((resolve) => setTimeout(resolve, 5)));
    }
    assert(jobs.length === count, 'Host action did not start exactly once');
  };
  try {
    const instance = await load(holdCopy);
    const first = run(instance);
    await waitForJobs(1);
    await wait(run(instance));
    assert(
      jobs.length === 1 && output.dataset.phase === 'pending',
      'Duplicate action or early success',
    );
    assert(jobs[0].text === root.querySelector('a').href, 'Wrong link copied');
    jobs[0].reject(new Error('Expected denial'));
    await wait(first);
    assert(output.dataset.phase === 'failed', 'Failure was not displayed');
    const retry = run(instance);
    await waitForJobs(2);
    jobs[1].resolve();
    await wait(retry);
    assert(output.dataset.phase === 'succeeded', 'Retry did not recover');
    const late = run(instance);
    await waitForJobs(3);
    instance.dispose();
    instance.dispose();
    const before = output.textContent;
    jobs[2].reject(new Error('Expected late rejection'));
    await wait(late);
    await wait(run(instance));
    assert(
      output.textContent === before && jobs.length === 3,
      'Disposed action published or restarted',
    );
    const lateSuccess = await load(holdCopy);
    const pending = run(lateSuccess);
    await waitForJobs(4);
    lateSuccess.dispose();
    const beforeSuccess = output.textContent;
    jobs[3].resolve();
    await wait(pending);
    assert(
      output.textContent === beforeSuccess,
      'Disposed success changed the UI',
    );
    // A throw before Promise creation follows the same Scheme failure path.
    const throwing = await load(() => {
      throw new Error('Expected host throw');
    });
    await wait(run(throwing));
    assert(
      output.dataset.phase === 'failed',
      'Synchronous throw bypassed Scheme recovery',
    );
    return 'Scheme action: pending, duplicate, failure, retry, late disposal, and host throw passed';
  } finally {
    finished = true;
    clearTimeout(timer);
    try {
      for (const instance of instances) instance.dispose();
    } finally {
      // Settle only the controlled test jobs, after invalidating their owners.
      for (const job of jobs) job.reject(new Error('Action checks finished'));
    }
  }
}
