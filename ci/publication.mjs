import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import {
  ApiError,
  applyPolicy,
  auditClosure,
  command,
  derivationGraph,
  ensure,
  fetchResponse,
  identifier,
  pathInfo,
  policy,
  readJson,
  repository,
  request,
  schema,
  sha,
  storePattern,
} from './common.mjs';
import { GitHub, Superseded } from './github.mjs';
import { same } from './records.mjs';
import { createTrigger, deleteTrigger, triggerKey } from './triggers.mjs';

const planKey = 'main-plan';
const kinds = ['cache'];

export class State {
  constructor(token, baseUrl, guard) {
    const url = new URL(baseUrl);
    ensure(url.protocol === 'https:' && token, 'Invalid state connection');
    ensure(typeof guard === 'function', 'Missing state write guard');
    this.token = token;
    this.url = baseUrl.replace(/\/$/, '') + '/api/v1/current-task/state/';
    this.guard = guard;
  }

  async access(name, value) {
    ensure(/^[a-z0-9-]+$/.test(name), 'Invalid state key');
    return request(this.url + name + '/data', this.token, {
      method: value === undefined ? 'GET' : 'PUT',
      body: value,
      missing: value === undefined,
      limit: 32 * 1024 * 1024,
      contentType: 'application/octet-stream',
      headers: {
        accept:
          value === undefined ? 'application/octet-stream' : 'application/json',
      },
      retryPut: this.guard,
    });
  }

  get(name) {
    return this.access(name);
  }

  put(name, value) {
    return this.access(name, value);
  }
}

export function publicationKey(kind, name) {
  ensure(kinds.includes(kind) && identifier.test(name), 'Invalid state name');
  return kind + '-' + createHash('sha256').update(name).digest('hex');
}

export async function current(api, revision) {
  ensure(sha.test(revision), 'Invalid main revision');
  const ref = await api.request('/git/ref/heads/main');

  if (ref.object.sha !== revision) {
    throw new Superseded('A newer main revision exists');
  }
}

export async function rootsAvailable(outputs, cache) {
  for (const value of outputs) {
    ensure(storePattern.test(value), 'Invalid cache output');
    const hash = path.basename(value).slice(0, 32);
    const response = await fetchResponse(cache.url + '/' + hash + '.narinfo', {
      method: 'HEAD',
      redirect: 'manual',
    });

    if (response.status === 404) {
      return false;
    }

    if (!response.ok) {
      throw new ApiError(response.status, 'HEAD', cache.url);
    }
  }

  return outputs.length > 0;
}

export function cacheIdentity(closure) {
  return Object.fromEntries(
    Object.entries(closure).map(([name, item]) => [
      name,
      {
        narHash: item.narHash,
        narSize: item.narSize,
        references: [...item.references].sort(),
      },
    ]),
  );
}

export function verifyCache(outputs, cache, source) {
  const target = pathInfo(outputs, cache.url);
  ensure(
    same(cacheIdentity(source), cacheIdentity(target)),
    'Public cache metadata differs from the built closure',
  );
  const args = [
    'store',
    'verify',
    '--sigs-needed',
    '1',
    '--store',
    cache.url,
    '--option',
    'trusted-public-keys',
    cache.publicKey,
  ];
  command('nix', [...args, '--recursive', '--no-contents', ...outputs]);
  const probe = [...outputs].sort(
    (a, b) => source[a].narSize - source[b].narSize,
  )[0];
  command('nix', [...args, probe]);
}

export async function publishCache(outputs, denied, cache, netrc, guard) {
  const source = auditClosure(outputs, denied);
  await guard();

  try {
    verifyCache(outputs, cache, source);
  } catch {
    ensure(
      typeof netrc === 'string' && netrc.length > 0,
      'Missing public-cache-upload netrc',
    );
    const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'font-cache-'));

    try {
      const file = path.join(directory, 'netrc');
      fs.writeFileSync(file, netrc, { mode: 0o600 });
      await guard();
      command('nix', [
        'copy',
        '--to',
        cache.url + '?compression=zstd',
        '--option',
        'netrc-file',
        file,
        ...outputs,
      ]);
    } finally {
      fs.rmSync(directory, { recursive: true, force: true });
    }

    verifyCache(outputs, cache, source);
  }

  await guard();
}

function eligible(item) {
  return item?.cacheable === true && item.windows === false;
}

export function candidates(baseline, inventory, pending) {
  return Object.entries(inventory.packages)
    .filter(
      ([name, item]) =>
        eligible(item) &&
        (baseline.packages[name]?.buildKey !== item.buildKey ||
          pending.cache.includes(name)),
    )
    .map(([name]) => name)
    .sort();
}

export async function planFonts(api, state, metadata, inventory) {
  const revision = metadata.rev;
  await current(api, revision);
  const previous = await state.get(planKey);
  ensure(
    !previous || (previous.schema === schema && previous.policy === policy),
    'Main state requires explicit migration',
  );
  const baseline = previous?.inventory ?? { packages: {} };
  if (previous) {
    const comparison = await api.request(
      '/compare/' + previous.observedRev + '...' + revision,
    );
    ensure(
      ['ahead', 'identical'].includes(comparison.status),
      'Main baseline is not an ancestor',
    );
  }
  const selected = candidates(
    baseline,
    inventory,
    previous?.pending ?? { cache: [] },
  );
  const requests = {};
  const retired = [...(previous?.retired ?? [])];
  const pending = { cache: [] };

  for (const name of selected) {
    const item = inventory.packages[name];
    const published = await state.get(publicationKey('cache', name));
    const complete =
      published?.schema === schema &&
      published.policy === policy &&
      published.package === name &&
      published.buildKey === item.buildKey &&
      same(published.cache, metadata.cache) &&
      (await rootsAvailable(Object.values(item.outputs), metadata.cache));
    if (complete) continue;
    pending.cache.push(name);
    const old = previous?.requests?.['cache:' + name];
    requests['cache:' + name] =
      old?.rev === revision && old.buildKey === item.buildKey
        ? old
        : {
            kind: 'cache',
            name,
            rev: revision,
            buildKey: item.buildKey,
            tag:
              'ci/package/cache/' + name + '/' + revision + '/' + randomUUID(),
          };
  }

  for (const item of Object.values(previous?.requests ?? {})) {
    if (requests['cache:' + item.name]?.tag !== item.tag) retired.push(item);
  }

  const observed = {
    schema,
    policy,
    observedRev: revision,
    inventory,
    pending,
    requests,
    retired,
  };
  await current(api, revision);
  await state.put(planKey, observed);

  for (const trigger of retired) {
    await current(api, revision);
    await deleteTrigger(api, trigger.tag, trigger.rev);
  }

  observed.retired = [];
  await current(api, revision);
  await state.put(planKey, observed);

  for (const item of Object.values(requests)) {
    await current(api, revision);
    if (item.queued) continue;
    const accepted = await state.get(triggerKey(item.tag));
    if (accepted) {
      ensure(
        accepted.tag === item.tag && accepted.rev === revision,
        'Accepted request differs from the plan',
      );
    } else {
      await createTrigger(api, item.tag, revision);
    }
    item.queued = true;
    await current(api, revision);
    await state.put(planKey, observed);
    console.log('Scheduled publishFont', item.name);
  }

  return observed;
}

export async function verifyRequest(api, state, metadata, inventory) {
  await current(api, metadata.rev);
  const item = inventory.packages[metadata.name];
  ensure(eligible(item), 'Package cannot enter the public build pipeline');
  const observed = await state.get(planKey);
  const selected = observed?.requests['cache:' + metadata.name];

  if (
    !selected ||
    selected.tag !== metadata.tag ||
    selected.rev !== metadata.rev ||
    selected.buildKey !== item.buildKey
  ) {
    throw new Superseded('This request was replaced or never scheduled');
  }

  return { item, selected };
}

export async function publishFont(api, state, metadata, inventory, secrets) {
  const { item } = await verifyRequest(api, state, metadata, inventory);
  const guard = () => verifyRequest(api, state, metadata, inventory);
  await state.put(triggerKey(metadata.tag), {
    tag: metadata.tag,
    rev: metadata.rev,
  });
  // Delete with the fresh job credential, before a long cache transfer.
  await deleteTrigger(api, metadata.tag, metadata.rev);
  const record = {
    schema,
    policy,
    package: metadata.name,
    buildKey: item.buildKey,
    rev: metadata.rev,
  };

  ensure(
    metadata.action === 'publishFont',
    'Only audited font caches are published',
  );
  await publishCache(
    Object.values(item.outputs),
    inventory.forbiddenPaths,
    metadata.cache,
    secrets['public-cache']?.data.netrc,
    guard,
  );
  record.cache = metadata.cache;

  await guard();
  await state.put(publicationKey('cache', metadata.name), record);
}

export async function run(metadata) {
  ensure(
    process.env.HERCULES_CI_PROJECT_PATH === 'github/' + repository &&
      metadata.repository === repository,
    'Not the upstream Hercules project',
  );
  const secrets = readJson(process.env.HERCULES_CI_SECRETS_JSON);
  const api = new GitHub(secrets.git.data.token, true);
  const state = new State(
    secrets['hercules-ci'].data.token,
    process.env.HERCULES_CI_API_BASE_URL,
    () => current(api, metadata.rev),
  );
  const raw = metadata.inventory;
  const inventory = applyPolicy(raw, derivationGraph(raw.packages));

  try {
    if (metadata.action === 'planFonts') {
      await planFonts(api, state, metadata, inventory);
    } else {
      ensure(metadata.action === 'publishFont', 'Unknown Hercules action');
      await publishFont(api, state, metadata, inventory, secrets);
    }
  } catch (error) {
    if (!(error instanceof Superseded)) {
      throw error;
    }

    if (metadata.action === 'publishFont') {
      await deleteTrigger(api, metadata.tag, metadata.rev);
    }

    console.log(error.message);
  }
}

if (
  process.argv[1] &&
  import.meta.url === pathToFileURL(process.argv[1]).href
) {
  try {
    await run(readJson(process.argv[2]));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
