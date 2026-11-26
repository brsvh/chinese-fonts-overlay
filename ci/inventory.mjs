import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import {
  command,
  digest,
  ensure,
  identifier,
  parseJson,
  policy,
  schema,
  storePattern,
} from './common.mjs';

const system = 'x86_64-linux';

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

export function withBaseWorktree(root, directory, baseSha, callback) {
  const base = fs.mkdtempSync(path.join(path.resolve(directory), 'base-'));
  let added = false;

  try {
    command('git', [
      '-C',
      path.resolve(root),
      'worktree',
      'add',
      '--detach',
      base,
      baseSha,
    ]);
    added = true;

    const result = callback(base);

    command('git', [
      '-C',
      path.resolve(root),
      'worktree',
      'remove',
      '--force',
      base,
    ]);
    added = false;

    return result;
  } catch (error) {
    try {
      if (added) {
        command('git', [
          '-C',
          path.resolve(root),
          'worktree',
          'remove',
          '--force',
          base,
        ]);
      } else {
        fs.rmSync(base, { recursive: true, force: true });
      }
    } catch (cleanupError) {
      throw new AggregateError([error, cleanupError], error.message);
    }

    throw error;
  }
}

export function evaluate(
  root,
  mode,
  selection = [],
  build = false,
  cachePath = null,
) {
  const expression =
    'import (builtins.toPath (builtins.getEnv "FONT_CI_EVALUATOR")) ' +
    '(builtins.fromJSON (builtins.getEnv "FONT_CI_ARGUMENTS"))';
  const args = [build ? 'build' : 'eval', '--impure', '--json'];

  if (build) {
    args.push('--no-link', '--print-build-logs');
  }

  args.push('--expr', expression, ...nixFlags);

  if (cachePath) {
    const cache = path.resolve(cachePath);
    const substituters = ['https://cache.brsvh.org'];

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
        // A language report uses the catalog layout of the revision it describes.
        FONT_CI_EVALUATOR:
          mode === 'languages'
            ? path.resolve(root, 'ci/default.nix')
            : evaluator,
        FONT_CI_ARGUMENTS: JSON.stringify({
          flakeUrl: 'git+' + pathToFileURL(path.resolve(root)).href,
          root: path.resolve(root),
          mode,
          selection,
        }),
      },
    }),
  );
}

function storePath(value) {
  ensure(typeof value === 'string', 'Invalid store path type');
  const result = value.startsWith('/nix/store/')
    ? value
    : '/nix/store/' + value;
  ensure(storePattern.test(result), 'Invalid store path');
  return result;
}

function normalizeGraph(document) {
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

function closure(root, graph) {
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

export function inventory(root) {
  const raw = evaluate(root, 'inventory');
  return applyPolicy(raw, derivationGraph(raw.packages));
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
