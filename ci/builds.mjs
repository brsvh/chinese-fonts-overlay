import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import {
  command,
  digest,
  ensure,
  policy,
  repository,
  writeJson,
} from './common.mjs';
import {
  auditClosure,
  cacheRestrictions,
  evaluate,
  inventory,
  withBaseWorktree,
} from './inventory.mjs';
import { output } from './github.mjs';
import { readState } from './build-state.mjs';
import {
  recordSchema,
  same,
  validateContext,
  validatePlan,
  workflowPath,
} from './records.mjs';

export const controllerFiles = [
  workflowPath,
  'flake.nix',
  'flake.lock',
  'lib/default.nix',
  'lib/flake.nix',
  'pages/default.nix',
  'tools/default.nix',
  'tools/flake.nix',
  'tools/flake.lock',
];

export const controllerDirectories = ['ci', 'tools/update-font-languages'];

export function controllerPaths(root) {
  const files = [...controllerFiles];

  function collect(relative) {
    for (const entry of fs.readdirSync(path.join(root, relative), {
      withFileTypes: true,
    })) {
      const child = relative + '/' + entry.name;

      if (entry.isDirectory()) {
        collect(child);
      } else {
        ensure(entry.isFile(), 'Unexpected non-file in controller: ' + child);
        files.push(child);
      }
    }
  }

  for (const directory of controllerDirectories) {
    collect(directory);
  }

  return files.sort();
}

export function controllerDigest(root) {
  return digest(
    Object.fromEntries(
      controllerPaths(root).map((file) => [
        file,
        createHash('sha256')
          .update(fs.readFileSync(path.join(root, file)))
          .digest('hex'),
      ]),
    ),
  );
}

function git(root, ...args) {
  return command('git', ['-C', path.resolve(root), ...args]);
}

export function runContext(root, event, env = process.env) {
  const pull = event.pull_request;
  ensure(
    env.GITHUB_EVENT_NAME === 'pull_request' &&
      env.GITHUB_REPOSITORY === repository &&
      pull.base.ref === 'main' &&
      pull.base.repo.full_name === repository,
    'Not an upstream main-targeting PR',
  );

  const merge = git(root, 'rev-parse', 'HEAD');
  ensure(merge === env.GITHUB_SHA, 'Checkout differs from the workflow');

  const parents = git(root, 'show', '--no-patch', '--format=%P', merge).split(
    ' ',
  );
  ensure(
    same(parents, [pull.base.sha, pull.head.sha]),
    'Merge commit parents differ from the PR event',
  );

  return validateContext({
    headSha: pull.head.sha,
    mergeSha: merge,
    runId: Number(env.GITHUB_RUN_ID),
    runAttempt: Number(env.GITHUB_RUN_ATTEMPT),
  });
}

function baselineInventory(root, directory, event) {
  return withBaseWorktree(
    root,
    directory,
    event.pull_request.base.sha,
    (base) => inventory(base),
  );
}

function planBuilds(base, current, receipts) {
  ensure(
    base.policy === policy &&
      current.policy === policy &&
      base.system === current.system,
    'A matching evaluated baseline is required',
  );

  const packages = {};
  const tasks = [];
  const reused = [];
  let skipped = 0;

  for (const name of Object.keys(current.packages).sort()) {
    const item = current.packages[name];
    const before = base.packages[name];
    if (before?.buildKey === item.buildKey) {
      continue;
    }

    if (item.windows) {
      skipped++;
      continue;
    }

    packages[name] = {
      vendor: item.vendor,
      pname: item.pname,
      buildKey: item.buildKey,
      cacheable: item.cacheable,
      affected: true,
    };

    const receipt = receipts[name];

    if (
      receipt?.policy === policy &&
      receipt.buildKey === item.buildKey &&
      receipt.buildSucceeded === true
    ) {
      reused.push(name);
    } else {
      tasks.push(name);
    }
  }

  const shards = [];

  for (const cacheable of [true, false]) {
    const selected = tasks.filter(
      (name) => packages[name].cacheable === cacheable,
    );
    const size = Math.max(1, Math.ceil(selected.length / 128));

    for (let index = 0; index < selected.length; index += size) {
      shards.push({
        id: shards.length,
        cacheable,
        tasks: selected.slice(index, index + size),
      });
    }
  }

  return { packages, tasks, shards, reused, skipped };
}

export async function preparePlan(root, directory, event, api) {
  const context = runContext(root, event);
  directory = path.resolve(directory);
  fs.mkdirSync(directory, { recursive: true });

  const base = baselineInventory(root, directory, event);
  const current = inventory(root);
  const controller = controllerDigest(root);
  const number = event.number;
  const headRepository = event.pull_request.head.repo?.full_name;
  ensure(typeof headRepository === 'string', 'Missing PR head repository');
  const state = await readState(api, number, headRepository, controller);

  const { packages, tasks, shards, reused, skipped } = planBuilds(
    base,
    current,
    state.receipts,
  );
  const value = validatePlan({
    schema: recordSchema,
    policy,
    repository,
    pr: number,
    headRepository,
    context,
    controller,
    packages,
    tasks,
    shards,
    reused,
  });

  writeJson(path.join(directory, 'plan.json'), value);

  output({
    matrix: JSON.stringify(
      value.shards.map((shard) => ({
        id: shard.id,
        label: shard.tasks.length === 1 ? shard.tasks[0] : String(shard.id),
      })),
    ),
    count: tasks.length,
  });

  console.log(
    'Selected',
    tasks.length,
    'packages; reused',
    value.reused.length,
    'successes; skipped',
    skipped,
  );
  return value;
}

export function buildShard(root, plan, shardId, directory, event) {
  const context = runContext(root, event);
  ensure(
    same(context, plan.context) && controllerDigest(root) === plan.controller,
    'Build plan is for different inputs',
  );

  const shard = plan.shards[shardId];
  ensure(shard, 'Invalid shard selection');

  const current = inventory(root);
  directory = path.resolve(directory);
  fs.mkdirSync(directory, { recursive: true });

  if (shard.cacheable) {
    const base = baselineInventory(root, directory, event);
    current.forbiddenPaths = cacheRestrictions(current, base);
  }

  const artifacts = path.join(directory, 'artifacts');
  ensure(!fs.existsSync(artifacts), 'Use a fresh artifact directory');
  fs.mkdirSync(artifacts, { recursive: true });

  const receipts = {
    schema: recordSchema,
    context,
    controller: plan.controller,
    shard: shardId,
    packages: {},
  };
  let failed = false;

  for (const name of shard.tasks) {
    const item = current.packages[name];
    const expected = plan.packages[name];
    ensure(
      !item.windows &&
        item.cacheable === shard.cacheable &&
        item.buildKey === expected.buildKey,
      'Re-evaluated build policy differs: ' + name,
    );

    const receipt = {
      buildKey: item.buildKey,
      buildSucceeded: false,
    };
    receipts.packages[name] = receipt;

    try {
      const built = evaluate(root, 'outputs', [name], true);
      const realized = [
        ...new Set(built.flatMap((result) => Object.values(result.outputs))),
      ].sort();
      ensure(
        same(realized, [...new Set(Object.values(item.outputs))].sort()),
        'Realized outputs differ from the plan',
      );

      if (shard.cacheable) {
        auditClosure(realized, current.forbiddenPaths);
      }

      receipt.buildSucceeded = true;
    } catch (error) {
      failed = true;
      console.error('Failed', name, error.message, error.details ?? '');
    } finally {
      writeJson(path.join(artifacts, 'receipts.json'), receipts);
    }
  }

  return !failed;
}
