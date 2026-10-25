import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createHash, randomUUID } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { setTimeout as delay } from 'node:timers/promises';

export const schema = 1;
export const policy = 2;
export const repository = 'brsvh/chinese-fonts-overlay';
export const system = 'x86_64-linux';
export const identifier = /^[a-z0-9][a-z0-9_-]*\.[a-z0-9][a-z0-9_+-]*$/;
export const storePattern = /^\/nix\/store\/[0-9a-df-np-sv-z]{32}-[^/\s]+$/;
export const sha = /^[0-9a-f]{40}$/;
export const fingerprint = /^[0-9a-f]{64}$/;
export const maxData = 128 * 1024 * 1024;

const evaluator = fileURLToPath(new URL('./default.nix', import.meta.url));

export const nixFlags = [
  '--option',
  'accept-flake-config',
  'false',
  '--option',
  'allow-import-from-derivation',
  'false',
  '--option',
  'builders',
  '',
  '--no-update-lock-file',
  '--no-write-lock-file',
];

export function ensure(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

export function canonical(value) {
  if (Array.isArray(value)) {
    return value.map(canonical);
  }

  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, canonical(value[key])]),
    );
  }

  return value;
}

export function digest(value) {
  return createHash('sha256')
    .update(JSON.stringify(canonical(value)))
    .digest('hex');
}

export function bytes(value) {
  return Buffer.from(JSON.stringify(canonical(value), null, 2) + '\n');
}

export function parseJson(data) {
  ensure(Buffer.byteLength(data) <= maxData, 'JSON exceeds size limit');
  const text = Buffer.isBuffer(data) ? data.toString('utf8') : data;
  const value = JSON.parse(text);
  const stack = [];
  const tokens = text.match(/"(?:\\.|[^"\\])*"|[{}\[\]:,]|[^\s{}\[\]:,]+/g);

  for (const token of tokens ?? []) {
    const object = stack.at(-1);

    if (token === '{') {
      stack.push({ keys: new Set(), key: true });
    } else if (token === '[') {
      stack.push(null);
    } else if (token === '}' || token === ']') {
      stack.pop();
    } else if (token === ',' && object) {
      object.key = true;
    } else if (token.startsWith('"') && object?.key) {
      const key = JSON.parse(token);
      ensure(!object.keys.has(key), 'Duplicate JSON key');
      ensure(
        !['__proto__', 'constructor', 'prototype'].includes(key),
        'Unsafe JSON key',
      );
      object.keys.add(key);
      object.key = false;
    }

    ensure(stack.length <= 64, 'JSON nesting exceeds limit');
  }

  return value;
}

export function readJson(file) {
  ensure(fs.statSync(file).size <= maxData, 'JSON file exceeds limit');
  return parseJson(fs.readFileSync(file));
}

export function writeJson(file, value) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const temporary = file + '.' + randomUUID() + '.tmp';
  fs.writeFileSync(temporary, bytes(value), { mode: 0o600 });
  fs.renameSync(temporary, file);
}

export function command(program, args, options = {}) {
  const result = spawnSync(program, args, {
    encoding: 'utf8',
    maxBuffer: maxData,
    ...options,
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0) {
    const error = new Error(program + ' exited with ' + result.status);
    error.details = result.stderr ?? '';
    throw error;
  }

  return result.stdout?.trim() ?? '';
}

export function evaluate(root, mode, selection = [], build = false) {
  const expression =
    'import (builtins.toPath (builtins.getEnv "FONT_CI_EVALUATOR")) ' +
    '(builtins.fromJSON (builtins.getEnv "FONT_CI_ARGUMENTS"))';
  const args = [build ? 'build' : 'eval', '--impure', '--json'];

  if (build) {
    args.push('--no-link', '--print-build-logs');
  }

  args.push('--expr', expression, ...nixFlags);

  if (process.env.FONT_CI_CACHE_PATH) {
    const cache = path.resolve(process.env.FONT_CI_CACHE_PATH);
    const substituters = ['https://cache.bingshan.org'];

    // Opening a missing file cache lets the daemon create root-owned paths
    // that the runner cannot remove when exporting the audited closure.
    if (fs.existsSync(path.join(cache, 'nix-cache-info'))) {
      substituters.push(pathToFileURL(cache).href + '?trusted=1');
    }

    args.push('--option', 'extra-substituters', substituters.join(' '));
  }

  return parseJson(
    command('nix', args, {
      env: {
        ...process.env,
        FONT_CI_EVALUATOR: evaluator,
        FONT_CI_ARGUMENTS: JSON.stringify({
          root: path.resolve(root),
          mode,
          selection,
        }),
      },
    }),
  );
}

export function storePath(value) {
  ensure(typeof value === 'string', 'Invalid store path type');
  const result = value.startsWith('/nix/store/')
    ? value
    : '/nix/store/' + value;
  ensure(storePattern.test(result), 'Invalid store path');
  return result;
}

export function normalizeGraph(document) {
  const result = {};

  for (const [name, drv] of Object.entries(document.derivations ?? document)) {
    const inputs = drv.inputs ?? {};
    const dependencies = inputs.drvs ?? drv.inputDrvs ?? {};

    for (const dependency of Object.values(dependencies)) {
      ensure(
        !dependency.dynamicOutputs ||
          Object.keys(dependency.dynamicOutputs).length === 0,
        'Dynamic derivation inputs require an explicit policy',
      );
    }

    const outputs = Object.entries(drv.outputs).map(([key, value]) => {
      const output = value.path ?? drv.env?.[key];
      ensure(output, 'Cannot audit unresolved derivation outputs');
      return storePath(output);
    });

    result[storePath(name)] = {
      drvs: new Set(Object.keys(dependencies).map(storePath)),
      paths: new Set([
        ...outputs,
        ...(inputs.srcs ?? drv.inputSrcs ?? []).map(storePath),
      ]),
    };
  }

  return result;
}

export function derivationGraph(packages) {
  const roots = [
    ...new Set(Object.values(packages).map((item) => item.drvPath)),
  ].sort();

  if (!roots.length) {
    return {};
  }

  return normalizeGraph(
    parseJson(command('nix', ['derivation', 'show', '--recursive', ...roots])),
  );
}

export function closure(root, graph) {
  const drvs = new Set();
  const paths = new Set();
  const pending = [root];

  while (pending.length) {
    const current = pending.pop();

    if (drvs.has(current)) {
      continue;
    }

    ensure(graph[current], 'Incomplete derivation graph: ' + current);
    drvs.add(current);

    for (const entry of graph[current].paths) {
      paths.add(entry);
    }

    pending.push(...graph[current].drvs);
  }

  return { drvs, paths };
}

function forbidden(packages, predicate) {
  const drvs = new Set();
  const paths = new Set();

  for (const item of Object.values(packages).filter(predicate)) {
    drvs.add(item.drvPath);

    for (const output of Object.values(item.outputs)) {
      paths.add(output);
    }

    for (const source of item.sources) {
      paths.add(source.path);

      if (source.drvPath) {
        drvs.add(source.drvPath);
      }
    }
  }

  return { drvs, paths };
}

function intersections(current, restrictions) {
  return [
    ...[...current.drvs].filter((item) => restrictions.drvs.has(item)),
    ...[...current.paths].filter((item) => restrictions.paths.has(item)),
  ].sort();
}

export function applyPolicy(inventory, graph) {
  ensure(
    inventory.schema === schema && inventory.system === system,
    'Unsupported inventory schema or platform',
  );
  const denied = forbidden(
    inventory.packages,
    (item) => item.redistributable !== true,
  );
  const windows = forbidden(inventory.packages, (item) => item.windows);
  const packages = {};

  for (const name of Object.keys(inventory.packages).sort()) {
    ensure(identifier.test(name), 'Unsafe font package identifier');
    const item = inventory.packages[name];
    const dependencies = closure(item.drvPath, graph);
    const windowsPackage = intersections(dependencies, windows).length > 0;
    const restrictions = intersections(dependencies, denied);
    const cacheable =
      item.redistributable === true &&
      !windowsPackage &&
      restrictions.length === 0;

    packages[name] = {
      ...item,
      windows: windowsPackage,
      cacheable,
      deniedDependencies: restrictions,
      buildKey: digest({
        policy,
        package: name,
        drvPath: item.drvPath,
        outputs: item.outputs,
        windows: windowsPackage,
        redistributable: item.redistributable === true,
        cacheable,
      }),
    };
  }

  return {
    ...inventory,
    policy,
    packages,
    forbiddenPaths: [...new Set([...denied.paths, ...windows.paths])].sort(),
  };
}

export function previewKeys(inventory, configuration) {
  for (const [name, item] of Object.entries(inventory.packages)) {
    item.sampleKey = configuration.samples[item.vendor]?.[item.pname];
    item.previewKey = digest({
      buildKey: item.buildKey,
      sample: item.sampleKey ?? null,
      renderer: configuration.rendererDrvPath,
      request: configuration.requests?.[name] ?? null,
      schema,
    });
  }

  return inventory;
}

export function inventory(root, withPreviews = true) {
  const raw = evaluate(root, 'inventory');
  const audited = applyPolicy(raw, derivationGraph(raw.packages));
  return withPreviews
    ? previewKeys(audited, evaluate(root, 'preview-config'))
    : audited;
}

export function cacheRestrictions(current, baseline) {
  const allowed = new Set();

  for (const item of Object.values(current.packages)) {
    if (item.cacheable) {
      Object.values(item.outputs).forEach((value) => allowed.add(value));
      item.sources.forEach((value) => allowed.add(value.path));
    }
  }

  return [
    ...new Set([
      ...current.forbiddenPaths,
      ...baseline.forbiddenPaths.filter((value) => !allowed.has(value)),
    ]),
  ].sort();
}

export function plan(base, current, receipts = {}, options = {}) {
  ensure(
    base.policy === policy &&
      current.policy === policy &&
      base.system === current.system,
    'A matching evaluated baseline is required',
  );
  const requested = new Set(options.previewRequests ?? []);
  const pending = new Set(options.pending ?? []);
  const tasks = [];
  const skipped = [];

  for (const name of requested) {
    ensure(current.packages[name], 'Unknown preview repair package');
  }

  for (const name of Object.keys(current.packages).sort()) {
    const item = current.packages[name];
    const before = base.packages[name];
    const changed = before?.buildKey !== item.buildKey || pending.has(name);
    const needsPreview = !options.main && (!before || requested.has(name));

    if (!changed && !needsPreview) {
      continue;
    }

    if (item.windows || (options.main && !item.cacheable)) {
      skipped.push({
        package: name,
        reason: item.windows ? 'windows' : 'not-redistributable',
      });
      continue;
    }

    const receipt = receipts[name] ?? {};
    const built =
      receipt.policy === policy &&
      receipt.buildKey === item.buildKey &&
      receipt.buildSucceeded === true;
    const shown =
      built &&
      receipt.previewKey === item.previewKey &&
      receipt.previewPublished === true;
    const render = needsPreview && !shown;
    const build = (changed && !built) || render;

    if (!build && !render) {
      continue;
    }

    ensure(!render || item.sampleKey, 'Missing preview sample: ' + name);
    tasks.push({
      package: name,
      buildKey: item.buildKey,
      cacheable: item.cacheable,
      build,
      preview: render,
      previewKey: item.previewKey,
    });
  }

  const shards = [];

  for (const cacheable of [true, false]) {
    const selected = tasks.filter((item) => item.cacheable === cacheable);
    const size = Math.max(1, Math.ceil(selected.length / 128));

    for (let index = 0; index < selected.length; index += size) {
      shards.push({
        id: shards.length,
        cacheable,
        tasks: selected.slice(index, index + size),
      });
    }
  }

  return {
    schema,
    policy,
    tasks,
    shards,
    skipped,
    deleted: Object.keys(base.packages)
      .filter((name) => !current.packages[name])
      .sort(),
  };
}

export function pathInfo(outputs, store) {
  const args = ['path-info', '--recursive', '--json', '--json-format', '1'];

  if (store) {
    args.push('--store', store);
  }

  return parseJson(command('nix', [...args, ...outputs]));
}

export function auditClosure(outputs, denied) {
  ensure(
    outputs.length > 0 && outputs.every((value) => storePattern.test(value)),
    'Invalid cache roots',
  );
  const source = pathInfo(outputs);
  const forbiddenPaths = new Set(denied);
  ensure(
    Object.keys(source).every((value) => !forbiddenPaths.has(value)),
    'Restricted font or source in cache closure',
  );
  return source;
}

export async function bounded(response, limit = maxData) {
  const parts = [];
  let size = 0;

  for await (const part of response.body ?? []) {
    size += part.length;
    ensure(size <= limit, 'HTTP response exceeds size limit');
    parts.push(part);
  }

  return Buffer.concat(parts);
}

export class ApiError extends Error {
  constructor(status, method, url) {
    super(method + ' ' + new URL(url).origin + ' returned HTTP ' + status);
    this.status = status;
  }
}

export async function fetchResponse(url, options = {}) {
  const target = new URL(url);
  const { method = 'GET', timeout = 30000, retryPut, ...rest } = options;
  const guardedPut = method === 'PUT' && typeof retryPut === 'function';
  const retryable = ['GET', 'HEAD'].includes(method) || guardedPut;

  for (let attempt = 1; ; attempt += 1) {
    if (attempt > 1 && guardedPut) {
      await retryPut();
    }

    let response;

    try {
      response = await fetch(target, {
        ...rest,
        method,
        signal: AbortSignal.timeout(timeout),
      });
    } catch (error) {
      const code = error.cause?.code ?? error.name;
      const transient = [
        'ECONNRESET',
        'ETIMEDOUT',
        'EAI_AGAIN',
        'UND_ERR_CONNECT_TIMEOUT',
        'UND_ERR_SOCKET',
        'TimeoutError',
      ].includes(code);
      const context = method + ' ' + target.origin + ' failed (' + code + ')';

      // Only state PUTs opt in to replaying a write, with a freshness guard.
      if (!retryable || !transient || attempt >= 3) {
        throw new Error(context, { cause: error });
      }

      console.error(context + '; retry ' + attempt + '/2');
      await delay(1000 * attempt);
      continue;
    }

    if (
      !retryable ||
      ![502, 503, 504].includes(response.status) ||
      attempt >= 3
    ) {
      return response;
    }

    await response.body?.cancel();
    const context = method + ' ' + target.origin + ' returned HTTP ';
    console.error(context + response.status + '; retry ' + attempt + '/2');
    await delay(1000 * attempt);
  }
}

export async function request(url, token, options = {}) {
  const { method = 'GET', body, missing = false } = options;
  const target = new URL(url);
  ensure(
    target.protocol === 'https:' && !target.username && !target.password,
    'Invalid API URL',
  );
  const response = await fetchResponse(target, {
    method,
    retryPut: options.retryPut,
    headers: {
      accept: 'application/vnd.github+json',
      'user-agent': 'chinese-fonts-overlay-ci',
      ...(token ? { authorization: 'Bearer ' + token } : {}),
      ...(body === undefined
        ? {}
        : {
            'content-type': options.contentType ?? 'application/json',
          }),
      ...options.headers,
    },
    body: body === undefined ? undefined : JSON.stringify(body),
    redirect: 'manual',
  });

  if (missing && response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new ApiError(response.status, method, target);
  }

  const data = await bounded(response, options.limit);
  return data.length ? parseJson(data) : null;
}
