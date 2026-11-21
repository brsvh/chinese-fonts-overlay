import { bytes, ensure, policy, readJson, repository } from './common.mjs';
import {
  GitHub,
  Superseded,
  buildStateBranch,
  consume,
  currentGuard,
  readState,
  resolveRun,
  statePath,
} from './github.mjs';

// Preserve preview receipts during the transition, without depending on them
// for successful package builds once the image publisher is retired.
export async function planningState(api, number, headRepository, controller) {
  const legacy = await readState(api, number, headRepository, controller);
  const { entries } = await api.branch(buildStateBranch);
  const saved = await readState(
    api,
    number,
    headRepository,
    controller,
    entries,
  );
  for (const [name, receipt] of Object.entries(saved.receipts)) {
    const previous = legacy.receipts[name];
    if (
      !previous ||
      receipt.runId > previous.runId ||
      (receipt.runId === previous.runId &&
        receipt.runAttempt >= previous.runAttempt)
    ) {
      legacy.receipts[name] =
        previous?.buildKey === receipt.buildKey &&
        previous?.previewKey === receipt.previewKey
          ? previous
          : receipt;
    }
  }
  return legacy;
}

export async function saveReceipts(api, run, pull, plan, records) {
  return api.updateImages(
    buildStateBranch,
    'Record font builds for PR #' + pull.number,
    async (entries) => {
      const state = await readState(
        api,
        pull.number,
        plan.headRepository,
        plan.controller,
        entries,
      );
      if (
        state.runId > run.id ||
        (state.runId === run.id && state.runAttempt > run.run_attempt)
      ) {
        throw new Superseded('Newer build receipts are already recorded');
      }
      for (const [name, receipt] of Object.entries(records)) {
        if (receipt.buildSucceeded) {
          state.receipts[name] = {
            policy,
            pname: plan.packages[name].pname,
            buildKey: receipt.buildKey,
            previewKey: receipt.previewKey,
            buildSucceeded: true,
            previewPublished: false,
            ...plan.context,
          };
        }
      }
      state.runId = run.id;
      state.runAttempt = run.run_attempt;
      return { [statePath(pull.number)]: bytes(state) };
    },
    () => currentGuard(api, run, pull),
  );
}

export async function recordBuilds() {
  ensure(
    process.env.GITHUB_EVENT_NAME === 'workflow_run' &&
      process.env.GITHUB_REPOSITORY === repository,
    'Receipt publisher requires an upstream workflow_run context',
  );
  const api = new GitHub(process.env.GITHUB_TOKEN, true);
  try {
    const { run, pull } = await resolveRun(
      api,
      readJson(process.env.GITHUB_EVENT_PATH),
    );
    ensure(run.status === 'completed', 'Build run is incomplete');
    await currentGuard(api, run, pull);
    const { plan, records, errors } = await consume(api, run, pull, {
      previews: false,
    });
    await saveReceipts(api, run, pull, plan, records);
    ensure(errors.length === 0, errors.join('\n'));
  } catch (error) {
    if (!(error instanceof Superseded)) throw error;
    console.log(error.message);
  }
}
