import fs from 'node:fs';
import { createHash } from 'node:crypto';
import {
  ensure,
  matches,
  maxData,
  positiveInteger,
  repository,
  sha,
} from './common.mjs';
import { ApiError, bounded, fetchResponse, request } from './http.mjs';

export class Superseded extends Error {}

const apiRoot = 'https://api.github.com/repos/' + repository;
const maxJson = 16 * 1024 * 1024;

export function blobSha(data) {
  return createHash('sha1')
    .update('blob ' + data.length + '\0')
    .update(data)
    .digest('hex');
}

function hasDotSegment(rawPath) {
  const pathname = rawPath.split('?')[0];

  for (const part of pathname.split('/')) {
    try {
      const decoded = decodeURIComponent(part);

      if (decoded === '.' || decoded === '..' || decoded.includes('/')) {
        return true;
      }
    } catch {
      return true;
    }
  }

  return false;
}

export class GitHub {
  constructor(token, writable = false) {
    this.token = token;
    this.writable = writable;
  }

  async request(path, options = {}) {
    ensure(
      typeof path === 'string' &&
        path.startsWith('/') &&
        !path.startsWith('//') &&
        !/[#\\\x00-\x20]/.test(path) &&
        !hasDotSegment(path),
      'Invalid GitHub API path',
    );

    const target = new URL(apiRoot + path);
    ensure(
      target.origin === 'https://api.github.com' &&
        target.pathname.startsWith('/repos/' + repository + '/'),
      'GitHub API path escaped repository scope',
    );
    ensure(
      this.writable || !options.method || options.method === 'GET',
      'Read-only GitHub client',
    );

    return request(target.href, this.token, {
      ...options,
      limit: maxJson,
      headers: { 'x-github-api-version': '2022-11-28' },
    });
  }

  async pages(path, field) {
    const values = [];
    const separator = path.includes('?') ? '&' : '?';

    for (let page = 1; page <= 100; page += 1) {
      const result = await this.request(
        path + separator + 'per_page=100&page=' + page,
      );
      const items = field ? result[field] : result;
      ensure(Array.isArray(items), 'Invalid paginated API response');
      values.push(...items);

      if (items.length < 100) {
        return values;
      }
    }

    throw new Error('API pagination limit exceeded');
  }

  async artifact(id, limit = maxData) {
    ensure(positiveInteger(id), 'Invalid artifact ID');
    let target = apiRoot + '/actions/artifacts/' + id + '/zip';

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const url = new URL(target);
      ensure(
        url.protocol === 'https:' && !url.username && !url.password,
        'Artifact redirects must use HTTPS without credentials',
      );

      const response = await fetchResponse(url, {
        headers: attempt === 0 ? { authorization: 'Bearer ' + this.token } : {},
        redirect: 'manual',
        timeout: 60000,
      });

      if ([301, 302, 303, 307, 308].includes(response.status)) {
        await response.body?.cancel();

        const location = response.headers.get('location');
        ensure(location, 'Artifact redirect has no location');
        target = new URL(location, url).href;
        continue;
      }

      if (!response.ok) {
        await response.body?.cancel();
        throw new ApiError(response.status, 'GET', url);
      }

      return bounded(response, limit);
    }

    throw new Error('Too many artifact redirects');
  }

  async blob(entry, limit = maxJson) {
    ensure(
      entry.mode === '100644' &&
        entry.type === 'blob' &&
        matches(sha, entry.sha) &&
        (entry.size ?? 0) <= limit,
      'Invalid record branch entry',
    );

    const response = await this.request('/git/blobs/' + entry.sha);
    ensure(
      response.encoding === 'base64' && response.size <= limit,
      'Invalid record branch blob',
    );

    const data = Buffer.from(response.content, 'base64');
    ensure(
      data.length <= limit &&
        data.length === response.size &&
        blobSha(data) === entry.sha,
      'Record branch blob integrity error',
    );
    return data;
  }
}

export function output(values) {
  const lines = Object.entries(values).map(([key, value]) => {
    ensure(!/[\r\n]/.test(String(value)), 'Multiline workflow output');
    return key + '=' + value;
  });
  fs.appendFileSync(process.env.GITHUB_OUTPUT, lines.join('\n') + '\n');
}
