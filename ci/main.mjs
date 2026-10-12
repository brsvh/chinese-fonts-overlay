import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import {
  ApiError,
  applyPolicy,
  auditClosure,
  bytes,
  command,
  derivationGraph,
  ensure,
  fetchResponse,
  identifier,
  parseJson,
  pathInfo,
  policy,
  previewKeys,
  readJson,
  repository,
  request,
  schema,
  sha,
  storePattern,
} from './common.mjs';
import { GitHub, Superseded } from './github.mjs';
import {
  expectedPreview,
  formalBranch,
  imagePath,
  maxBundle,
  maxImage,
  maxImages,
  packageName,
  render,
  same,
  validateManifest,
} from './previews.mjs';

const planKey = 'main-plan';
const kinds = ['cache', 'preview'];

export class State {
  constructor(token, baseUrl) {
    const url = new URL(baseUrl);
    ensure(url.protocol === 'https:' && token, 'Invalid state connection');
    this.token = token;
    this.url = baseUrl.replace(/\/$/, '') + '/api/v1/current-task/state/';
  }

  async access(name, value) {
    ensure(/^[a-z0-9-]+$/.test(name), 'Invalid state key');
    return request(this.url + name + '/data', this.token, {
      method: value === undefined ? 'GET' : 'PUT',
      body: value,
      missing: value === undefined,
      limit: 32 * 1024 * 1024,
      contentType: 'application/octet-stream',
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

export function triggerInfo(tag) {
  const pattern = /^ci\/package\/(cache|preview)\/([^/]+)\/([a-f0-9]{40})\//;
  const match = pattern.exec(tag);
  ensure(
    match &&
      identifier.test(match[2]) &&
      /^[a-f0-9-]{36}$/.test(tag.slice(match[0].length)),
    'Invalid internal trigger',
  );
  return { kind: match[1], name: match[2], rev: match[3] };
}

export async function deleteTrigger(api, tag, revision) {
  ensure(triggerInfo(tag).rev === revision, 'Trigger revision differs');
  const ref = await api.request('/git/ref/tags/' + tag, { missing: true });

  if (!ref) {
    return;
  }

  ensure(ref.object.sha === revision, 'Trigger was moved');

  try {
    await api.request('/git/refs/tags/' + tag, { method: 'DELETE' });
  } catch (error) {
    if (
      !(error instanceof ApiError) ||
      ![404, 422].includes(error.status) ||
      (await api.request('/git/ref/tags/' + tag, { missing: true }))
    ) {
      throw error;
    }
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
      throw new ApiError(response.status);
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

export function manifestPath(name) {
  ensure(identifier.test(name), 'Invalid formal preview package');
  return '.font-ci/' + name + '.json';
}

export async function ownership(api, entries, name) {
  const entry = entries[manifestPath(name)];

  if (!entry) {
    return null;
  }

  const manifest = parseJson(await api.blob(entry, 1024 * 1024));
  ensure(
    manifest.package === name &&
      typeof manifest.pname === 'string' &&
      packageName.test(manifest.pname) &&
      Array.isArray(manifest.images) &&
      manifest.images.length > 0 &&
      manifest.images.length <= maxImages,
    'Invalid formal preview ownership',
  );
  const paths = manifest.images.map((image) =>
    imagePath(image.path, name.split('.')[0], manifest.pname),
  );
  ensure(new Set(paths).size === paths.length, 'Duplicate owned image');
  return { manifest, paths };
}

export async function formalBundle(api, entries, name, item) {
  const owned = await ownership(api, entries, name);

  if (!owned) {
    return null;
  }

  const expected = expectedPreview(name, item);

  const matching = Object.entries(expected).every(
    ([key, value]) => owned.manifest[key] === value,
  );

  if (!matching || owned.manifest.source?.kind !== 'main') {
    return null;
  }

  const files = {};
  let total = 0;

  for (const file of owned.paths) {
    if (!entries[file]) {
      return null;
    }

    const data = await api.blob(entries[file], maxImage);
    total += data.length;
    ensure(total <= maxBundle, 'Formal bundle is too large');
    files[file] = data;
  }

  validateManifest(owned.manifest, files, expected);
  return { manifest: owned.manifest, files };
}

export async function writeFormal(api, bundles, removed, guard) {
  return api.updateImages(
    formalBranch,
    'Render main font previews',
    async (entries) => {
      const changes = {};
      const owners = new Map();
      const managed = {};

      for (const file of Object.keys(entries)) {
        const match = /^\.font-ci\/(.+)\.json$/.exec(file);

        if (!match) {
          continue;
        }

        const name = match[1];
        const owned = await ownership(api, entries, name);
        managed[name] = owned;

        for (const image of owned.paths) {
          ensure(!owners.has(image), 'Multiple image owners');
          owners.set(image, name);
        }
      }

      for (const name of new Set([...Object.keys(bundles), ...removed])) {
        const old = managed[name]?.paths ?? [];
        const result = bundles[name];

        if (!result) {
          for (const file of old) {
            changes[file] = null;
          }

          if (managed[name]) {
            changes[manifestPath(name)] = null;
          }

          continue;
        }

        const { manifest, files } = result;
        validateManifest(manifest, files, { package: name });
        ensure(manifest.source.kind === 'main', 'Formal source must be main');

        for (const file of old.filter((file) => !Object.hasOwn(files, file))) {
          changes[file] = null;
        }

        for (const [file, data] of Object.entries(files)) {
          ensure(
            !owners.has(file) || owners.get(file) === name,
            'Cannot overwrite another package preview',
          );
          changes[file] = data;
        }

        changes[manifestPath(name)] = bytes(manifest);
      }

      return changes;
    },
    guard,
  );
}

function eligible(item) {
  return item?.cacheable === true && item.windows === false;
}

export function candidates(baseline, inventory, pending, repairs, before) {
  const result = { cache: new Set(), preview: new Set() };

  for (const [name, item] of Object.entries(inventory.packages)) {
    if (!eligible(item)) {
      continue;
    }

    const old = baseline.packages[name];

    if (old?.buildKey !== item.buildKey || pending.cache.includes(name)) {
      result.cache.add(name);
    }

    if (
      !old ||
      old.previewKey !== item.previewKey ||
      pending.preview.includes(name) ||
      repairs[name] !== before[name]
    ) {
      result.preview.add(name);
    }
  }

  return result;
}

export async function schedule(api, state, metadata, inventory, bootstrap) {
  const revision = metadata.rev;
  await current(api, revision);
  const previous = await state.get(planKey);
  ensure(
    !previous || (previous.schema === schema && previous.policy === policy),
    'Main state requires explicit migration',
  );
  const baseline = previous?.inventory ?? bootstrap;
  const comparison = await api.request(
    '/compare/' +
      (previous?.observedRev ?? metadata.bootstrapRev) +
      '...' +
      revision,
  );
  ensure(
    ['ahead', 'identical'].includes(comparison.status),
    'Main baseline is not an ancestor',
  );
  const repairs = metadata.previewRequests;

  for (const name of Object.keys(repairs)) {
    ensure(inventory.packages[name], 'Unknown preview repair package');
  }

  const selected = candidates(
    baseline,
    inventory,
    previous?.pending ?? { cache: [], preview: [] },
    repairs,
    previous?.previewRequests ?? {},
  );
  const requests = {};
  const retired = [
    ...(previous?.retired ?? []),
    ...Object.values(previous?.requests ?? {}),
  ];
  const { entries } = await api.branch(formalBranch);
  const managed = Object.keys(entries)
    .map((file) => /^\.font-ci\/(.+)\.json$/.exec(file)?.[1])
    .filter(Boolean);
  const removed = managed.filter((name) => !eligible(inventory.packages[name]));
  const previewTargets = [
    ...new Set([
      ...(previous?.previewTargets ?? []),
      ...managed,
      ...selected.preview,
    ]),
  ].filter((name) => eligible(inventory.packages[name]));

  for (const name of previewTargets) {
    selected.preview.add(name);
  }

  const pending = { cache: [], preview: [] };

  for (const kind of kinds) {
    for (const name of [...selected[kind]].sort()) {
      const item = inventory.packages[name];
      const published = await state.get(publicationKey(kind, name));
      const valid =
        published?.schema === schema &&
        published.policy === policy &&
        published.package === name &&
        published.buildKey === item.buildKey;
      let complete = false;

      if (kind === 'cache') {
        complete =
          valid &&
          same(published.cache, metadata.cache) &&
          (await rootsAvailable(Object.values(item.outputs), metadata.cache));
      } else {
        try {
          complete = !!(await formalBundle(api, entries, name, item));
        } catch (error) {
          console.error('Preview needs repair:', name, error.message);
        }

        if (
          complete &&
          (!valid ||
            published.previewKey !== item.previewKey ||
            published.repair !== (repairs[name] ?? null))
        ) {
          await current(api, revision);
          await state.put(publicationKey(kind, name), {
            schema,
            policy,
            package: name,
            rev: revision,
            buildKey: item.buildKey,
            previewKey: item.previewKey,
            repair: repairs[name] ?? null,
          });
        }
      }

      if (complete) {
        continue;
      }

      ensure(
        kind !== 'preview' || item.sampleKey,
        'Missing preview sample key: ' + name,
      );
      pending[kind].push(name);
      requests[kind + ':' + name] = {
        kind,
        name,
        rev: revision,
        buildKey: item.buildKey,
        previewKey: item.previewKey,
        repair: repairs[name] ?? null,
        tag:
          'ci/package/' +
          kind +
          '/' +
          name +
          '/' +
          revision +
          '/' +
          randomUUID(),
      };
    }
  }

  const observed = {
    schema,
    policy,
    observedRev: revision,
    inventory,
    pending,
    requests,
    retired,
    previewTargets,
    previewRequests: repairs,
  };
  await current(api, revision);
  await state.put(planKey, observed);

  if (removed.length) {
    await writeFormal(api, {}, removed, () => current(api, revision));
  }

  for (const trigger of retired) {
    await current(api, revision);
    await deleteTrigger(api, trigger.tag, trigger.rev);
  }

  observed.retired = [];
  await current(api, revision);
  await state.put(planKey, observed);

  for (const item of Object.values(requests)) {
    await current(api, revision);
    await api.request('/git/refs', {
      method: 'POST',
      body: { ref: 'refs/tags/' + item.tag, sha: revision },
    });
    console.log('Scheduled', item.kind, item.name);
  }

  return observed;
}

export async function verifyRequest(api, state, metadata, inventory) {
  await current(api, metadata.rev);
  const item = inventory.packages[metadata.name];
  ensure(eligible(item), 'Package cannot enter the public build pipeline');
  const observed = await state.get(planKey);
  const selected = observed?.requests[metadata.mode + ':' + metadata.name];

  if (
    !selected ||
    selected.tag !== metadata.tag ||
    selected.rev !== metadata.rev ||
    selected.buildKey !== item.buildKey ||
    selected.previewKey !== item.previewKey
  ) {
    throw new Superseded('This request was replaced or never scheduled');
  }

  return { item, selected };
}

export async function publishPackage(api, state, metadata, inventory, secrets) {
  const { item, selected } = await verifyRequest(
    api,
    state,
    metadata,
    inventory,
  );
  const guard = () => verifyRequest(api, state, metadata, inventory);
  const record = {
    schema,
    policy,
    package: metadata.name,
    buildKey: item.buildKey,
    rev: metadata.rev,
  };

  if (metadata.mode === 'cache') {
    await publishCache(
      Object.values(item.outputs),
      inventory.forbiddenPaths,
      metadata.cache,
      secrets['public-cache']?.data.netrc,
      guard,
    );
    record.cache = metadata.cache;
  } else {
    await guard();
    const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'main-preview-'));

    try {
      const result = render(metadata.renderer, directory, metadata.name, item, {
        kind: 'main',
        rev: metadata.rev,
      });
      await writeFormal(api, { [metadata.name]: result }, [], guard);
      const { entries } = await api.branch(formalBranch);
      ensure(
        await formalBundle(api, entries, metadata.name, item),
        'Published main preview is missing',
      );
    } finally {
      fs.rmSync(directory, { recursive: true, force: true });
    }

    record.previewKey = item.previewKey;
    record.repair = selected.repair;
  }

  await guard();
  await state.put(publicationKey(metadata.mode, metadata.name), record);
  await deleteTrigger(api, metadata.tag, metadata.rev);
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
  );
  const raw = metadata.inventory;
  const inventory = previewKeys(
    applyPolicy(raw, derivationGraph(raw.packages)),
    metadata.previewConfiguration,
  );

  try {
    if (metadata.mode === 'plan') {
      const base = metadata.bootstrap;
      const bootstrap = previewKeys(
        applyPolicy(base, derivationGraph(base.packages)),
        metadata.previewConfiguration,
      );
      await schedule(api, state, metadata, inventory, bootstrap);
    } else {
      ensure(kinds.includes(metadata.mode), 'Unknown Hercules mode');
      await publishPackage(api, state, metadata, inventory, secrets);
    }
  } catch (error) {
    if (!(error instanceof Superseded)) {
      throw error;
    }

    if (kinds.includes(metadata.mode)) {
      await deleteTrigger(api, metadata.tag, metadata.rev);
    }

    console.log(error.message);
  }
}

try {
  await run(readJson(process.argv[2]));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
