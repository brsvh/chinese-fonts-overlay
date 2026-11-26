import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import {
  ensure,
  matches,
  maxData,
  parseJson,
  policy,
  positiveInteger,
  readJson,
  repository,
  sha,
} from './common.mjs';
import { blobSha, GitHub, Superseded } from './github.mjs';
import {
  same,
  validatePlan,
  validateReceipts,
  workflowPath,
} from './records.mjs';
import {
  controllerDigest,
  controllerFiles,
  controllerPaths,
} from './builds.mjs';
import { updateBuildState } from './build-state.mjs';
import { unzip } from './artifacts.mjs';

const sealedControllerFiles = new Set(controllerFiles);

function isControllerPath(file) {
  return (
    typeof file === 'string' &&
    (sealedControllerFiles.has(file) || file.startsWith('ci/'))
  );
}

const allowedBlobModes = new Set(['100644', '100755']);

async function readControllerTree(api, treeSha) {
  ensure(matches(sha, treeSha), 'Invalid Git tree SHA');
  const tree = await api.request('/git/trees/' + treeSha + '?recursive=1');

  if (tree.truncated || !Array.isArray(tree.tree)) {
    throw new Superseded('Git tree is truncated');
  }

  const entries = Object.create(null);

  for (const entry of tree.tree) {
    if (entry.type === 'tree' || !isControllerPath(entry.path)) {
      continue;
    }

    if (entry.type !== 'blob' || !allowedBlobModes.has(entry.mode)) {
      throw new Superseded(
        'Unexpected controller entry type or mode: ' + entry.path,
      );
    }

    entries[entry.path] = { mode: entry.mode, sha: entry.sha };
  }

  return entries;
}

async function verifyController(api, root, run, merge) {
  const baseSha = merge.parents[0].sha;
  ensure(matches(sha, baseSha), 'Invalid merge base SHA');
  ensure(matches(sha, merge.tree?.sha), 'Invalid merge tree SHA');

  const baseCompare = await api.request('/compare/' + baseSha + '...main');
  if (baseCompare.status !== 'ahead' && baseCompare.status !== 'identical') {
    throw new Superseded('Build merge base is not on the default branch');
  }

  const prCompare = await api.request(
    '/compare/' + baseSha + '...' + run.head_sha,
  );
  const mergeBaseTreeSha = prCompare.merge_base_commit?.commit?.tree?.sha;
  const headCommit = await api.request('/git/commits/' + run.head_sha);

  const [mergeBaseEntries, headEntries, mergeEntries] = await Promise.all([
    readControllerTree(api, mergeBaseTreeSha),
    readControllerTree(api, headCommit.tree?.sha),
    readControllerTree(api, merge.tree.sha),
  ]);

  const mergeBaseKeys = Object.keys(mergeBaseEntries).sort();
  const headKeys = Object.keys(headEntries).sort();

  if (
    !same(headKeys, mergeBaseKeys) ||
    headKeys.some(
      (file) =>
        headEntries[file].sha !== mergeBaseEntries[file].sha ||
        headEntries[file].mode !== mergeBaseEntries[file].mode,
    )
  ) {
    throw new Superseded('PR modifies build controller files');
  }

  const expectedPaths = controllerPaths(root);
  const mergeKeys = Object.keys(mergeEntries).sort();

  if (!same(mergeKeys, expectedPaths)) {
    throw new Superseded('Build merge tree controller paths differ from main');
  }

  for (const file of expectedPaths) {
    if (
      mergeEntries[file].sha !== blobSha(fs.readFileSync(path.join(root, file)))
    ) {
      throw new Superseded('Build merge tree controller differs from main');
    }
  }
}

async function resolveRun(api, event) {
  const source = event.workflow_run;
  ensure(positiveInteger(source.id), 'Invalid workflow run ID');

  const run = await api.request('/actions/runs/' + source.id);
  const workflow = await api.request('/actions/workflows/build.yml');
  ensure(
    run.repository.full_name === repository &&
      run.event === 'pull_request' &&
      run.workflow_id === workflow.id &&
      workflow.path === workflowPath &&
      run.path === workflowPath,
    'Unexpected producer workflow',
  );

  if (
    run.run_attempt !== source.run_attempt ||
    run.head_sha !== source.head_sha
  ) {
    throw new Superseded('A newer workflow attempt exists');
  }

  ensure(matches(sha, run.head_sha), 'Invalid workflow run head SHA');

  const headRepository = run.head_repository?.full_name;
  ensure(
    typeof headRepository === 'string',
    'Missing workflow head repository',
  );

  let pulls = run.pull_requests;

  if (!pulls.length) {
    pulls = await api.pages('/commits/' + run.head_sha + '/pulls');
  }

  const candidates = [];

  for (const number of new Set(pulls.map((pull) => pull.number))) {
    ensure(positiveInteger(number), 'Invalid PR number');
    const pull = await api.request('/pulls/' + number);

    if (
      pull.base.repo.full_name === repository &&
      pull.base.ref === 'main' &&
      pull.head.sha === run.head_sha &&
      pull.head.repo?.full_name === headRepository &&
      (pull.state === 'open' || pull.merged)
    ) {
      candidates.push(pull);
    }
  }

  if (candidates.length !== 1) {
    throw new Superseded('No unique current PR matches this run');
  }

  return { run, pull: candidates[0] };
}

async function currentGuard(api, run, pull) {
  const latest = await api.request('/pulls/' + pull.number);
  const attempt = await api.request('/actions/runs/' + run.id);

  if (
    latest.head.sha !== run.head_sha ||
    !(latest.state === 'open' || latest.merged) ||
    attempt.run_attempt !== run.run_attempt
  ) {
    throw new Superseded('The PR or workflow attempt has changed');
  }
}

async function artifactFiles(api, artifacts, name) {
  const matches = artifacts.filter((item) => item.name === name);

  ensure(
    matches.length === 1 &&
      !matches[0].expired &&
      matches[0].size_in_bytes <= maxData,
    'Missing, ambiguous, expired or oversized artifact: ' + name,
  );

  const artifact = matches[0];
  const data = await api.artifact(artifact.id);

  if (artifact.digest) {
    const digest = createHash('sha256').update(data).digest('hex');
    ensure(
      artifact.digest === 'sha256:' + digest,
      'Artifact digest differs from the GitHub API',
    );
  }

  return unzip(data);
}

async function readBuildReceipts(api, root, run, pull, expectedController) {
  const artifacts = await api.pages(
    '/actions/runs/' + run.id + '/artifacts',
    'artifacts',
  );
  const attempt = run.run_attempt;
  const planFiles = await artifactFiles(api, artifacts, 'font-plan-' + attempt);
  ensure(same(Object.keys(planFiles), ['plan.json']), 'Invalid plan files');

  const plan = validatePlan(parseJson(planFiles['plan.json']));
  ensure(
    plan.pr === pull.number &&
      plan.headRepository === pull.head.repo.full_name &&
      plan.context.headSha === run.head_sha &&
      plan.context.runId === run.id &&
      plan.context.runAttempt === attempt,
    'Plan context differs from authenticated workflow run',
  );

  if (plan.controller !== expectedController) {
    throw new Superseded('Build controller differs from the default branch');
  }

  const merge = await api.request('/git/commits/' + plan.context.mergeSha);
  ensure(
    merge.parents.length === 2 && merge.parents[1].sha === run.head_sha,
    'Build merge commit does not contain the PR head',
  );
  await verifyController(api, root, run, merge);

  const jobs = await api.pages(
    '/actions/runs/' + run.id + '/attempts/' + attempt + '/jobs',
    'jobs',
  );
  const records = {};
  const errors = [];

  for (const shard of plan.shards) {
    try {
      const label =
        shard.tasks.length === 1 ? shard.tasks[0] : String(shard.id);
      const matching = jobs.filter(
        (job) => job.name === 'Build fonts / ' + label,
      );
      ensure(
        matching.length === 1 && matching[0].status === 'completed',
        'Build job is missing or incomplete',
      );

      const receipts = await artifactFiles(
        api,
        artifacts,
        'font-receipts-' + attempt + '-' + shard.id,
      );
      ensure(
        same(Object.keys(receipts), ['receipts.json']),
        'Unexpected receipt files',
      );

      const value = validateReceipts(
        parseJson(receipts['receipts.json']),
        plan,
        shard,
      );
      Object.assign(records, value.packages);
    } catch (error) {
      errors.push('Shard ' + shard.id + ': ' + error.message);
    }
  }

  return { plan, records, errors };
}

async function saveReceipts(api, run, pull, plan, records) {
  return updateBuildState(
    api,
    plan,
    (state) => {
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
            buildSucceeded: true,
            ...plan.context,
          };
        }
      }

      state.runId = run.id;
      state.runAttempt = run.run_attempt;
    },
    () => currentGuard(api, run, pull),
  );
}

export async function recordBuilds(root = '.') {
  ensure(
    process.env.GITHUB_EVENT_NAME === 'workflow_run' &&
      process.env.GITHUB_REPOSITORY === repository,
    'Receipt publisher requires an upstream workflow_run context',
  );
  ensure(process.env.GITHUB_EVENT_PATH, 'Missing GITHUB_EVENT_PATH');

  const expectedController = controllerDigest(root);
  const api = new GitHub(process.env.GITHUB_TOKEN, true);

  try {
    const { run, pull } = await resolveRun(
      api,
      readJson(process.env.GITHUB_EVENT_PATH),
    );
    ensure(run.status === 'completed', 'Build run is incomplete');
    await currentGuard(api, run, pull);

    const { plan, records, errors } = await readBuildReceipts(
      api,
      root,
      run,
      pull,
      expectedController,
    );
    await saveReceipts(api, run, pull, plan, records);

    ensure(errors.length === 0, errors.join('\n'));
  } catch (error) {
    if (!(error instanceof Superseded)) throw error;
    console.log(error.message);
  }
}
