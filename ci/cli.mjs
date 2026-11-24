import { parseArgs } from 'node:util';
import { ensure, readJson, writeJson } from './common.mjs';
import { inventory } from './inventory.mjs';
import { GitHub } from './github.mjs';
import { validatePlan } from './records.mjs';
import { buildShard, preparePlan } from './builds.mjs';
import { recordBuilds } from './receipts.mjs';
import { checkLanguages } from './languages.mjs';

try {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      root: { type: 'string', default: '.' },
      directory: { type: 'string', default: '.ci-work' },
      output: { type: 'string' },
      plan: { type: 'string' },
      shard: { type: 'string' },
    },
  });

  ensure(positionals.length === 1, 'Exactly one command is required');
  const [command] = positionals;

  if (command === 'inventory') {
    writeJson(values.output, inventory(values.root));
  } else if (command === 'pr-plan') {
    await preparePlan(
      values.root,
      values.directory,
      readJson(process.env.GITHUB_EVENT_PATH),
      new GitHub(process.env.GITHUB_TOKEN),
    );
  } else if (command === 'pr-build') {
    const shard = Number(values.shard);
    ensure(Number.isSafeInteger(shard) && shard >= 0, 'Invalid shard');

    const ok = buildShard(
      values.root,
      validatePlan(readJson(values.plan)),
      shard,
      values.directory,
      readJson(process.env.GITHUB_EVENT_PATH),
    );

    process.exitCode = ok ? 0 : 1;
  } else if (command === 'pr-check-languages') {
    checkLanguages(
      values.root,
      values.directory,
      readJson(process.env.GITHUB_EVENT_PATH),
    );
  } else if (command === 'record-builds') {
    await recordBuilds();
  } else {
    throw new Error('Unknown command: ' + command);
  }
} catch (error) {
  console.error(error.message, error.details ?? '');
  process.exitCode = 1;
}
