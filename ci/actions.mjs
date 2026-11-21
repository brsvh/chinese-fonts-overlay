import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { createHash } from 'node:crypto';
import {
  auditClosure,
  cacheRestrictions,
  command,
  digest,
  ensure,
  evaluate,
  inventory,
  plan,
  policy,
  repository,
  schema,
  writeJson,
} from './common.mjs';
import { output } from './github.mjs';
import { planningState } from './receipts.mjs';
import {
  same,
  validateContext,
  validatePlan,
  workflowPath,
} from './records.mjs';

export function controllerDigest(root) {
  const files = fs
    .readdirSync(path.join(root, 'ci'))
    .filter((file) => /\.(mjs|nix)$/.test(file))
    .map((file) => 'ci/' + file);
  files.push(workflowPath);
  return digest(
    Object.fromEntries(
      files.sort().map((file) => [
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
  const base = path.join(directory, 'base');
  ensure(!fs.existsSync(base), 'Use a fresh baseline directory');
  git(root, 'worktree', 'add', '--detach', base, event.pull_request.base.sha);

  try {
    return inventory(base);
  } finally {
    git(root, 'worktree', 'remove', '--force', base);
  }
}

export async function preparePlan(root, directory, event, api) {
  const context = runContext(root, event);
  directory = path.resolve(directory);
  fs.mkdirSync(directory, { recursive: true });
  const base = baselineInventory(root, directory, event);
  const current = inventory(root);
  const controller = controllerDigest(root);
  const number = event.number;
  const headRepository = event.pull_request.head.repo.full_name;
  const state = await planningState(api, number, headRepository, controller);
  const required = plan(base, current);
  const selected = plan(base, current, state.receipts);
  const packages = {};

  for (const task of required.tasks) {
    const item = current.packages[task.package];
    packages[task.package] = {
      vendor: item.vendor,
      pname: item.pname,
      buildKey: item.buildKey,
      previewKey: item.previewKey,
      cacheable: item.cacheable,
      preview: task.preview,
      affected: true,
    };
  }

  const tasks = selected.tasks.map((task) => task.package);
  const value = validatePlan({
    schema,
    policy,
    repository,
    pr: number,
    headRepository,
    context,
    controller,
    packages,
    tasks,
    shards: selected.shards.map((shard) => ({
      ...shard,
      tasks: shard.tasks.map((task) => task.package),
    })),
    reused: Object.keys(packages).filter((name) => !tasks.includes(name)),
  });
  writeJson(path.join(directory, 'plan.json'), value);
  current.forbiddenPaths = cacheRestrictions(current, base);
  writeJson(path.join(directory, 'inventory.json'), current);
  output({
    matrix: JSON.stringify(
      value.shards.map((shard) => ({
        id: shard.id,
        label:
          shard.tasks.length === 1
            ? packages[shard.tasks[0]].pname
            : String(shard.id),
        cacheable: shard.cacheable,
        cacheKey: digest(shard.tasks.map((name) => packages[name].buildKey)),
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
    required.skipped.length,
  );
  return value;
}

export function exportCache(roots, forbidden, destination) {
  const selected = [...roots].sort();
  const closure = auditClosure(selected, forbidden);
  fs.rmSync(destination, { recursive: true, force: true });
  fs.mkdirSync(destination, { recursive: true });
  const uri = pathToFileURL(path.resolve(destination)).href;
  command('nix', ['copy', '--to', uri, ...selected]);
  const saved = command('nix', ['path-info', '--all', '--store', uri])
    .split('\n')
    .filter(Boolean)
    .sort();
  ensure(
    same(saved, Object.keys(closure).sort()),
    'Exported cache differs from the audited closure',
  );
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
  writeJson(path.join(directory, 'inventory.json'), current);
  const receipts = {
    schema,
    context,
    controller: plan.controller,
    shard: shardId,
    packages: {},
  };
  const roots = new Set();
  let failed = false;
  process.env.FONT_CI_CACHE_PATH = path.join(directory, 'cache');

  for (const name of shard.tasks) {
    const item = current.packages[name];
    const expected = plan.packages[name];
    ensure(
      !item.windows &&
        item.cacheable === shard.cacheable &&
        item.buildKey === expected.buildKey &&
        item.previewKey === expected.previewKey,
      'Re-evaluated build policy differs: ' + name,
    );
    const receipt = {
      buildKey: item.buildKey,
      previewKey: item.previewKey,
      buildSucceeded: false,
      previewGenerated: false,
    };
    receipts.packages[name] = receipt;

    try {
      const built = evaluate(root, 'outputs', [name], true);
      const realized = built.flatMap((result) => Object.values(result.outputs));
      ensure(
        same(
          [...new Set(realized)].sort(),
          [...new Set(Object.values(item.outputs))].sort(),
        ),
        'Realized outputs differ from the plan',
      );
      receipt.buildSucceeded = true;
      realized.forEach((value) => roots.add(value));
    } catch (error) {
      failed = true;
      console.error('Failed', name, error.message, error.details ?? '');
    } finally {
      writeJson(path.join(artifacts, 'receipts.json'), receipts);
    }
  }

  if (!failed && shard.cacheable) {
    exportCache(roots, current.forbiddenPaths, path.join(directory, 'cache'));
  }

  return !failed;
}
