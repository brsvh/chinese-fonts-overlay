import { setTimeout as delay } from 'node:timers/promises';
import { ensure, maxData, parseJson } from './common.mjs';

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

  if (!response.ok) {
    await response.body?.cancel();
    if (missing && response.status === 404) return null;

    throw new ApiError(response.status, method, target);
  }

  const data = await bounded(response, options.limit);
  return data.length ? parseJson(data) : null;
}
