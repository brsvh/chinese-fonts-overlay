import fs from 'node:fs';
import { createHash } from 'node:crypto';
import {
  ApiError,
  bounded,
  ensure,
  fetchResponse,
  fingerprint,
  identifier,
  maxData,
  parseJson,
  policy,
  repository,
  request,
  sha,
} from './common.mjs';
import {
  fields,
  packageName,
  positive,
  recordSchema,
  safePath,
  same,
  validateContext,
  validatePlan,
  validateReceipts,
  workflowPath,
} from './records.mjs';
import { unzip } from './artifacts.mjs';

const apiRoot = 'https://api.github.com/repos/' + repository;
const maxJson = 16 * 1024 * 1024;
export const buildStateBranch = 'font-build-state';

export function blobSha(data) {
  return createHash('sha1')
    .update('blob ' + data.length + '\0')
    .update(data)
    .digest('hex');
}

export class GitHub {
  constructor(token, writable = false) {
    this.token = token;
    this.writable = writable;
  }

  async request(path, options = {}) {
    ensure(
      path.startsWith('/') &&
        !path.startsWith('//') &&
        !/[#\\\x00-\x20]/.test(path),
      'Invalid GitHub API path',
    );
    ensure(
      this.writable || !options.method || options.method === 'GET',
      'Read-only GitHub client',
    );
    return request(apiRoot + path, this.token, {
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
    ensure(positive(id), 'Invalid artifact ID');
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
        target = new URL(response.headers.get('location'), url).href;
        await response.body?.cancel();
        continue;
      }

      if (!response.ok) {
        throw new ApiError(response.status, 'GET', url);
      }

      return bounded(response, limit);
    }

    throw new Error('Too many artifact redirects');
  }

  async branch(name) {
    ensure(name === buildStateBranch, 'Not a build record branch');
    const ref = await this.request('/git/ref/heads/' + name, {
      missing: true,
    });

    if (!ref) {
      return { parent: null, tree: null, entries: {} };
    }

    ensure(sha.test(ref.object.sha), 'Invalid branch revision');
    const commit = await this.request('/git/commits/' + ref.object.sha);
    const tree = await this.request(
      '/git/trees/' + commit.tree.sha + '?recursive=1',
    );
    ensure(!tree.truncated, 'Record tree is truncated');
    return {
      parent: ref.object.sha,
      tree: commit.tree.sha,
      entries: Object.fromEntries(
        tree.tree
          .filter((entry) => entry.type !== 'tree')
          .map((entry) => [entry.path, entry]),
      ),
    };
  }

  async blob(entry, limit = maxJson) {
    ensure(
      entry.mode === '100644' &&
        entry.type === 'blob' &&
        sha.test(entry.sha) &&
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

  async updateRecords(name, message, prepare, guard = async () => {}) {
    ensure(
      this.writable && name === buildStateBranch,
      'Record branch writes are disabled',
    );

    for (let attempt = 0; attempt < 5; attempt += 1) {
      await guard();
      const { parent, tree, entries } = await this.branch(name);
      const changes = await prepare(entries);
      const edits = [];

      for (const file of Object.keys(changes).sort()) {
        safePath(file);
        const data = changes[file];

        if (data === null) {
          if (entries[file]) {
            edits.push({
              path: file,
              mode: '100644',
              type: 'blob',
              sha: null,
            });
          }

          continue;
        }

        const digest = blobSha(data);

        if (entries[file]?.sha === digest) {
          continue;
        }

        const blob = await this.request('/git/blobs', {
          method: 'POST',
          body: { encoding: 'base64', content: data.toString('base64') },
        });
        ensure(blob.sha === digest, 'Uploaded blob integrity error');
        edits.push({
          path: file,
          mode: '100644',
          type: 'blob',
          sha: digest,
        });
      }

      if (!edits.length) {
        return parent;
      }

      const created = await this.request('/git/trees', {
        method: 'POST',
        body: { ...(tree ? { base_tree: tree } : {}), tree: edits },
      });
      const commit = await this.request('/git/commits', {
        method: 'POST',
        body: {
          message,
          tree: created.sha,
          parents: parent ? [parent] : [],
        },
      });
      await guard();

      try {
        if (parent) {
          await this.request('/git/refs/heads/' + name, {
            method: 'PATCH',
            body: { sha: commit.sha, force: false },
          });
        } else {
          await this.request('/git/refs', {
            method: 'POST',
            body: { ref: 'refs/heads/' + name, sha: commit.sha },
          });
        }

        return commit.sha;
      } catch (error) {
        if (
          !(error instanceof ApiError) ||
          ![409, 422].includes(error.status)
        ) {
          throw error;
        }
      }
    }

    throw new Error('Concurrent record updates; retry publication');
  }
}

export function statePath(number) {
  ensure(positive(number), 'Invalid PR number');
  return 'prs/' + number + '/state.json';
}

export async function readState(
  api,
  number,
  headRepository,
  controller,
  entries,
) {
  entries ??= (await api.branch(buildStateBranch)).entries;
  const entry = entries[statePath(number)];

  if (!entry) {
    return {
      schema: recordSchema,
      repository,
      pr: number,
      headRepository,
      controller,
      runId: 0,
      runAttempt: 0,
      receipts: {},
    };
  }

  const state = parseJson(await api.blob(entry));
  fields(state, [
    'schema',
    'repository',
    'pr',
    'headRepository',
    'controller',
    'runId',
    'runAttempt',
    'receipts',
  ]);
  ensure(
    state.schema === recordSchema &&
      state.repository === repository &&
      state.pr === number &&
      state.headRepository === headRepository &&
      positive(state.runId) &&
      positive(state.runAttempt) &&
      fingerprint.test(state.controller) &&
      state.receipts !== null &&
      typeof state.receipts === 'object' &&
      !Array.isArray(state.receipts),
    'PR state identity mismatch',
  );
  state.controller = controller;
  for (const [name, item] of Object.entries(state.receipts)) {
    fields(item, [
      'policy',
      'pname',
      'buildKey',
      'buildSucceeded',
      'headSha',
      'mergeSha',
      'runId',
      'runAttempt',
    ]);
    ensure(
      identifier.test(name) &&
        item.policy === policy &&
        item.buildSucceeded === true &&
        typeof item.pname === 'string' &&
        packageName.test(item.pname) &&
        fingerprint.test(item.buildKey),
      'Invalid successful receipt',
    );
    validateContext({
      headSha: item.headSha,
      mergeSha: item.mergeSha,
      runId: item.runId,
      runAttempt: item.runAttempt,
    });
  }

  return state;
}

export class Superseded extends Error {}

export async function resolveRun(api, event) {
  const source = event.workflow_run;
  ensure(positive(source.id), 'Invalid workflow run ID');
  const run = await api.request('/actions/runs/' + source.id);
  const workflow = await api.request('/actions/workflows/build.yml');
  ensure(
    run.repository.full_name === repository &&
      run.event === 'pull_request' &&
      run.workflow_id === workflow.id &&
      workflow.path === workflowPath &&
      run.path === workflowPath,
    'Unexpected producer workflow',
  );

  if (
    run.run_attempt !== source.run_attempt ||
    run.head_sha !== source.head_sha
  ) {
    throw new Superseded('A newer workflow attempt exists');
  }

  let pulls = run.pull_requests;

  if (!pulls.length) {
    pulls = await api.pages('/commits/' + run.head_sha + '/pulls');
  }

  const candidates = [];

  for (const number of new Set(pulls.map((pull) => pull.number))) {
    ensure(positive(number), 'Invalid PR number');
    const pull = await api.request('/pulls/' + number);

    if (
      pull.base.repo.full_name === repository &&
      pull.base.ref === 'main' &&
      pull.head.sha === run.head_sha &&
      pull.head.repo?.full_name === run.head_repository.full_name &&
      (pull.state === 'open' || pull.merged)
    ) {
      candidates.push(pull);
    }
  }

  if (candidates.length !== 1) {
    throw new Superseded('No unique current PR matches this run');
  }

  return { run, pull: candidates[0] };
}

export async function currentGuard(api, run, pull) {
  const latest = await api.request('/pulls/' + pull.number);
  const attempt = await api.request('/actions/runs/' + run.id);

  if (
    latest.head.sha !== run.head_sha ||
    !(latest.state === 'open' || latest.merged) ||
    attempt.run_attempt !== run.run_attempt
  ) {
    throw new Superseded('The PR or workflow attempt has changed');
  }
}

export async function artifactFiles(api, artifacts, name, optional = false) {
  const matches = artifacts.filter((item) => item.name === name);

  if (!matches.length && optional) {
    return {};
  }

  ensure(
    matches.length === 1 &&
      !matches[0].expired &&
      matches[0].size_in_bytes <= maxData,
    'Missing, ambiguous, expired or oversized artifact: ' + name,
  );
  const artifact = matches[0];
  const data = await api.artifact(artifact.id);

  if (artifact.digest) {
    const digest = createHash('sha256').update(data).digest('hex');
    ensure(
      artifact.digest === 'sha256:' + digest,
      'Artifact digest differs from the GitHub API',
    );
  }

  return unzip(data);
}

export async function consume(api, run, pull) {
  const artifacts = await api.pages(
    '/actions/runs/' + run.id + '/artifacts',
    'artifacts',
  );
  const attempt = run.run_attempt;
  const planFiles = await artifactFiles(api, artifacts, 'font-plan-' + attempt);
  ensure(same(Object.keys(planFiles), ['plan.json']), 'Invalid plan files');
  const plan = validatePlan(parseJson(planFiles['plan.json']));
  ensure(
    plan.pr === pull.number &&
      plan.headRepository === pull.head.repo.full_name &&
      plan.context.headSha === run.head_sha &&
      plan.context.runId === run.id &&
      plan.context.runAttempt === attempt,
    'Plan context differs from authenticated workflow run',
  );
  const merge = await api.request('/git/commits/' + plan.context.mergeSha);
  ensure(
    merge.parents.length === 2 && merge.parents[1].sha === run.head_sha,
    'Build merge commit does not contain the PR head',
  );
  const jobs = await api.pages(
    '/actions/runs/' + run.id + '/attempts/' + attempt + '/jobs',
    'jobs',
  );
  const records = {};
  const errors = [];

  for (const shard of plan.shards) {
    try {
      const label =
        shard.tasks.length === 1
          ? plan.packages[shard.tasks[0]].pname
          : String(shard.id);
      const matching = jobs.filter(
        (job) => job.name === 'Build fonts / ' + label,
      );
      ensure(
        matching.length === 1 && matching[0].status === 'completed',
        'Build job is missing or incomplete',
      );
      const receipts = await artifactFiles(
        api,
        artifacts,
        'font-receipts-' + attempt + '-' + shard.id,
      );
      ensure(
        same(Object.keys(receipts), ['receipts.json']),
        'Unexpected receipt files',
      );
      const value = validateReceipts(
        parseJson(receipts['receipts.json']),
        plan,
        shard,
      );
      Object.assign(records, value.packages);
    } catch (error) {
      errors.push('Shard ' + shard.id + ': ' + error.message);
    }
  }

  return { plan, records, errors };
}

export function output(values) {
  const lines = Object.entries(values).map(([key, value]) => {
    ensure(!/[\r\n]/.test(String(value)), 'Multiline workflow output');
    return key + '=' + value;
  });
  fs.appendFileSync(process.env.GITHUB_OUTPUT, lines.join('\n') + '\n');
}
