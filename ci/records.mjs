import {
  canonical,
  ensure,
  fingerprint,
  identifier,
  policy,
  repository,
  sha,
} from './common.mjs';

export const packageName = /^[a-z0-9][a-z0-9_+-]*$/;
export const workflowPath = '.github/workflows/build.yml';
export const recordSchema = 2;

export function same(left, right) {
  return JSON.stringify(canonical(left)) === JSON.stringify(canonical(right));
}

export function fields(value, expected) {
  ensure(
    value !== null &&
      typeof value === 'object' &&
      !Array.isArray(value) &&
      same(Object.keys(value).sort(), [...expected].sort()),
    'Unexpected data fields',
  );
}

export function positive(value) {
  return Number.isSafeInteger(value) && value > 0;
}

export function safePath(value) {
  ensure(
    typeof value === 'string' &&
      value.length > 0 &&
      !value.startsWith('/') &&
      !value.includes('\\') &&
      !/[\x00-\x1f\x7f]/.test(value) &&
      !value.split('/').some((part) => ['', '.', '..'].includes(part)) &&
      Buffer.byteLength(value) <= 1024,
    'Unsafe relative path',
  );
  return value;
}

export function validateContext(value) {
  fields(value, ['headSha', 'mergeSha', 'runId', 'runAttempt']);
  ensure(
    sha.test(value.headSha) &&
      sha.test(value.mergeSha) &&
      positive(value.runId) &&
      positive(value.runAttempt),
    'Invalid run context',
  );
  return value;
}

export function validatePlan(value) {
  fields(value, [
    'schema',
    'policy',
    'repository',
    'pr',
    'headRepository',
    'context',
    'controller',
    'packages',
    'tasks',
    'shards',
    'reused',
  ]);
  ensure(
    value.schema === recordSchema &&
      value.policy === policy &&
      value.repository === repository &&
      positive(value.pr) &&
      /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(value.headRepository) &&
      fingerprint.test(value.controller),
    'Invalid plan identity',
  );
  validateContext(value.context);
  ensure(
    value.packages &&
      typeof value.packages === 'object' &&
      !Array.isArray(value.packages) &&
      Object.keys(value.packages).length <= 5000,
    'Invalid package plan',
  );

  for (const [name, item] of Object.entries(value.packages)) {
    fields(item, ['vendor', 'pname', 'buildKey', 'cacheable', 'affected']);
    ensure(
      identifier.test(name) &&
        item.vendor === name.split('.')[0] &&
        typeof item.pname === 'string' &&
        packageName.test(item.pname) &&
        fingerprint.test(item.buildKey) &&
        ['cacheable', 'affected'].every(
          (key) => typeof item[key] === 'boolean',
        ),
      'Invalid package metadata',
    );
  }

  const tasks = value.tasks;
  ensure(
    Array.isArray(tasks) &&
      new Set(tasks).size === tasks.length &&
      tasks.every((name) => Object.hasOwn(value.packages, name)),
    'Invalid task selection',
  );
  ensure(
    Array.isArray(value.shards) && value.shards.length <= 256,
    'Invalid build matrix',
  );
  const scheduled = [];

  for (const [index, shard] of value.shards.entries()) {
    fields(shard, ['id', 'cacheable', 'tasks']);
    ensure(
      shard.id === index &&
        typeof shard.cacheable === 'boolean' &&
        Array.isArray(shard.tasks) &&
        shard.tasks.length > 0,
      'Invalid shard',
    );

    for (const name of shard.tasks) {
      ensure(
        tasks.includes(name) &&
          shard.cacheable === value.packages[name].cacheable,
        'Mixed cache policy in shard',
      );
      scheduled.push(name);
    }
  }

  ensure(same(scheduled.sort(), [...tasks].sort()), 'Shard task mismatch');
  const reused = value.reused;
  ensure(
    Array.isArray(reused) &&
      new Set(reused).size === reused.length &&
      reused.every((name) => !tasks.includes(name)) &&
      same([...tasks, ...reused].sort(), Object.keys(value.packages).sort()),
    'Missing or duplicate package evidence',
  );
  return value;
}

export function validateReceipts(value, plan, shard) {
  fields(value, ['schema', 'context', 'controller', 'shard', 'packages']);
  ensure(
    value.schema === recordSchema &&
      same(value.context, plan.context) &&
      value.controller === plan.controller &&
      value.shard === shard.id,
    'Receipt run mismatch',
  );

  for (const [name, item] of Object.entries(value.packages)) {
    fields(item, ['buildKey', 'buildSucceeded']);
    ensure(
      shard.tasks.includes(name) &&
        item.buildKey === plan.packages[name].buildKey &&
        typeof item.buildSucceeded === 'boolean',
      'Invalid package receipt',
    );
  }

  return value;
}
