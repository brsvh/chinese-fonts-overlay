import fs from 'node:fs';
import path from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import { spawnSync } from 'node:child_process';

export const schema = 1;
export const policy = 2;
export const repository = 'brsvh/chinese-fonts-overlay';
export const identifier = /^[a-z0-9][a-z0-9_-]*\.[a-z0-9][a-z0-9_+-]*$/;
export const storePattern = /^\/nix\/store\/[0-9a-df-np-sv-z]{32}-[^/\s]+$/;
export const sha = /^[0-9a-f]{40}$/;
export const fingerprint = /^[0-9a-f]{64}$/;
export const maxData = 128 * 1024 * 1024;

export function ensure(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

export function positiveInteger(value) {
  return Number.isSafeInteger(value) && value > 0;
}

export function matches(pattern, value) {
  return typeof value === 'string' && pattern.test(value);
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
  const data = bytes(value);
  const temporary = file + '.' + randomUUID() + '.tmp';
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const fd = fs.openSync(temporary, 'wx', 0o600);

  try {
    try {
      fs.writeFileSync(fd, data);
    } finally {
      fs.closeSync(fd);
    }

    fs.renameSync(temporary, file);
  } catch (error) {
    try {
      fs.unlinkSync(temporary);
    } catch (cleanupError) {
      throw new AggregateError([error, cleanupError], error.message);
    }

    throw error;
  }
}

const allowedEnv = [
  'CURL_CA_BUNDLE',
  'GIT_SSL_CAINFO',
  'GUILE_EXTENSIONS_PATH',
  'GUILE_LOAD_COMPILED_PATH',
  'GUILE_LOAD_PATH',
  'HOME',
  'HTTP_PROXY',
  'HTTPS_PROXY',
  'LANG',
  'LC_ALL',
  'LC_CTYPE',
  'LOCALE_ARCHIVE',
  'LOGNAME',
  'NIX_CONFIG',
  'NIX_CONF_DIR',
  'NIX_DAEMON_SOCKET_PATH',
  'NIX_LOG_DIR',
  'NIX_PATH',
  'NIX_PROFILES',
  'NIX_REMOTE',
  'NIX_SSL_CERT_FILE',
  'NIX_STATE_DIR',
  'NIX_STORE',
  'NIX_USER_CONF_FILES',
  'NO_PROXY',
  'PATH',
  'SSL_CERT_FILE',
  'TERM',
  'TMPDIR',
  'TZ',
  'USER',
  'XDG_CACHE_HOME',
  'XDG_CONFIG_HOME',
  'XDG_DATA_HOME',
  'XDG_RUNTIME_DIR',
  'http_proxy',
  'https_proxy',
  'no_proxy',
];

export function sanitizedEnv(extra = {}) {
  const env = {};

  for (const key of allowedEnv) {
    if (Object.hasOwn(process.env, key)) {
      env[key] = process.env[key];
    }
  }

  return { ...env, ...extra };
}

export function command(program, args, options = {}) {
  const { env, ...rest } = options;
  const result = spawnSync(program, args, {
    encoding: 'utf8',
    maxBuffer: maxData,
    ...rest,
    env: env ?? sanitizedEnv(),
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0) {
    const reason = result.signal
      ? ' terminated by ' + result.signal
      : ' exited with ' + result.status;
    const error = new Error(program + reason);
    error.details = result.stderr ?? '';
    throw error;
  }

  return result.stdout?.trim() ?? '';
}
