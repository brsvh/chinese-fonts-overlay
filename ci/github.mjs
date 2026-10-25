import fs from 'node:fs';
import { createHash } from 'node:crypto';
import {
  ApiError,
  bounded,
  bytes,
  ensure,
  fetchResponse,
  fingerprint,
  identifier,
  maxData,
  parseJson,
  policy,
  readJson,
  repository,
  request,
  schema,
  sha,
  writeJson,
} from './common.mjs';
import {
  expectedPreview,
  formalBranch,
  imagePath,
  maxBundle,
  maxImage,
  maxImages,
  packageName,
  positive,
  safePath,
  same,
  temporaryBranch,
  unzip,
  validateContext,
  validateManifest,
  validatePlan,
  validatePreviews,
  validateReceipts,
  workflowPath,
} from './previews.mjs';

const apiRoot = 'https://api.github.com/repos/' + repository;
const maxJson = 16 * 1024 * 1024;
const imageBranches = [temporaryBranch, formalBranch];

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
    ensure(imageBranches.includes(name), 'Not an image branch');
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
    ensure(!tree.truncated, 'Image tree is truncated');
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
      'Invalid image branch entry',
    );
    const response = await this.request('/git/blobs/' + entry.sha);
    ensure(
      response.encoding === 'base64' && response.size <= limit,
      'Invalid image branch blob',
    );
    const data = Buffer.from(response.content, 'base64');
    ensure(
      data.length <= limit &&
        data.length === response.size &&
        blobSha(data) === entry.sha,
      'Image branch blob integrity error',
    );
    return data;
  }

  async updateImages(name, message, prepare, guard = async () => {}) {
    ensure(
      this.writable && imageBranches.includes(name),
      'Image branch writes are disabled',
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

    throw new Error('Concurrent image updates; retry publication');
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
  entries ??= (await api.branch(temporaryBranch)).entries;
  const entry = entries[statePath(number)];

  if (!entry) {
    return {
      schema,
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
  ensure(
    state.schema === schema &&
      state.repository === repository &&
      state.pr === number &&
      state.headRepository === headRepository &&
      positive(state.runId) &&
      positive(state.runAttempt),
    'PR state identity mismatch',
  );
  state.controller = controller;
  state.receipts = Object.fromEntries(
    Object.entries(state.receipts).filter(([, item]) => item.policy === policy),
  );

  for (const [name, item] of Object.entries(state.receipts)) {
    ensure(
      identifier.test(name) &&
        item.buildSucceeded === true &&
        typeof item.pname === 'string' &&
        packageName.test(item.pname) &&
        fingerprint.test(item.buildKey) &&
        fingerprint.test(item.previewKey) &&
        typeof item.previewPublished === 'boolean',
      'Invalid successful receipt',
    );
    validateContext({
      headSha: item.headSha,
      mergeSha: item.mergeSha,
      runId: item.runId,
      runAttempt: item.runAttempt,
    });

    if (!item.previewPublished) {
      continue;
    }

    const prefix = 'prs/' + number + '/' + name + '/' + item.previewKey;
    ensure(item.previewPath === prefix, 'Invalid preview receipt path');
    const files = item.previewFiles ?? {};
    const count = Object.keys(files).length;

    if (!files['manifest.json'] || count < 2 || count > maxImages + 1) {
      item.previewPublished = false;
      continue;
    }

    for (const [file, digest] of Object.entries(files)) {
      if (file !== 'manifest.json') {
        imagePath(file, name.split('.')[0], item.pname);
      }

      ensure(sha.test(digest), 'Invalid receipt blob digest');
      const actual = entries[prefix + '/' + file];

      if (
        actual?.sha !== digest ||
        actual.mode !== '100644' ||
        actual.type !== 'blob'
      ) {
        item.previewPublished = false;
      }
    }
  }

  return state;
}

export async function bundle(api, entries, prefix, expected) {
  const entry = entries[prefix + '/manifest.json'];
  ensure(entry, 'Published preview manifest is missing');
  const manifest = parseJson(await api.blob(entry, 1024 * 1024));
  ensure(
    Array.isArray(manifest.images) &&
      manifest.images.length > 0 &&
      manifest.images.length <= maxImages,
    'Invalid published image count',
  );
  const files = {};
  let total = 0;

  for (const image of manifest.images) {
    const file = imagePath(image.path, manifest.vendor, manifest.pname);
    const imageEntry = entries[prefix + '/' + file];
    ensure(imageEntry, 'Published preview image is missing');
    const data = await api.blob(imageEntry, maxImage);
    total += data.length;
    ensure(total <= maxBundle, 'Published preview bundle is too large');
    files[file] = data;
  }

  validateManifest(manifest, files, expected);
  return { manifest, files };
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

export async function check(api, run, summary, conclusion) {
  return api.request('/check-runs', {
    method: 'POST',
    body: {
      name: 'Font previews',
      head_sha: run.head_sha,
      details_url:
        'https://github.com/' + repository + '/actions/runs/' + run.id,
      external_id: 'font-preview-' + run.id + '-' + run.run_attempt,
      status: conclusion ? 'completed' : 'in_progress',
      ...(conclusion ? { conclusion } : {}),
      output: { title: 'Font previews', summary },
    },
  });
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
    'Preview merge commit does not contain the PR head',
  );
  const jobs = await api.pages(
    '/actions/runs/' + run.id + '/attempts/' + attempt + '/jobs',
    'jobs',
  );
  const records = {};
  const bundles = {};
  const errors = [];

  for (const shard of plan.shards) {
    try {
      const label =
        shard.tasks.length === 1
          ? plan.packages[shard.tasks[0]].pname
          : String(shard.id);
      const matching = jobs.filter(
        (job) =>
          job.name === 'Build fonts / ' + shard.id ||
          job.name === 'Build fonts / ' + label,
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
      const files = await artifactFiles(
        api,
        artifacts,
        'font-previews-' + attempt + '-' + shard.id,
        true,
      );
      const validated = validatePreviews(files, plan, value.packages);
      Object.assign(records, value.packages);
      Object.assign(bundles, validated);
    } catch (error) {
      errors.push('Shard ' + shard.id + ': ' + error.message);
    }
  }

  return { plan, records, bundles, errors };
}

export async function publish(api, run, pull, plan, records, bundles) {
  const selected = {};
  const guard = () => currentGuard(api, run, pull);

  async function prepare(entries) {
    const state = await readState(
      api,
      pull.number,
      plan.headRepository,
      plan.controller,
      entries,
    );

    if (
      state.runId > run.id ||
      (state.runId === run.id && state.runAttempt > run.run_attempt)
    ) {
      throw new Superseded('Newer PR state is already published');
    }

    const changes = {};

    for (const [name, receipt] of Object.entries(records)) {
      if (!receipt.buildSucceeded) {
        continue;
      }

      const saved = {
        policy,
        pname: plan.packages[name].pname,
        buildKey: receipt.buildKey,
        previewKey: receipt.previewKey,
        buildSucceeded: true,
        previewPublished: false,
        ...plan.context,
      };

      if (bundles[name]) {
        const { manifest, files } = bundles[name];
        const prefix =
          'prs/' + pull.number + '/' + name + '/' + manifest.previewKey;
        const payload = { 'manifest.json': bytes(manifest), ...files };
        saved.previewPublished = true;
        saved.previewPath = prefix;
        saved.previewFiles = {};

        for (const [file, data] of Object.entries(payload)) {
          saved.previewFiles[file] = blobSha(data);
          changes[prefix + '/' + file] = data;
        }
      }

      state.receipts[name] = saved;
    }

    for (const name of Object.keys(selected)) {
      delete selected[name];
    }

    for (const [name, item] of Object.entries(plan.packages)) {
      const receipt = state.receipts[name];

      if (receipt?.buildKey !== item.buildKey || !receipt.buildSucceeded) {
        continue;
      }

      if (!item.preview) {
        selected[name] = null;
        continue;
      }

      if (!receipt.previewPublished || receipt.previewKey !== item.previewKey) {
        continue;
      }

      let result = bundles[name];

      if (!result) {
        result = await bundle(api, entries, receipt.previewPath, {
          ...expectedPreview(name, item),
          source: {
            kind: 'pr',
            headSha: receipt.headSha,
            mergeSha: receipt.mergeSha,
            runId: receipt.runId,
            runAttempt: receipt.runAttempt,
          },
        });
      }

      selected[name] = {
        prefix: receipt.previewPath,
        manifest: result.manifest,
        cacheable: item.cacheable,
      };
    }

    state.runId = run.id;
    state.runAttempt = run.run_attempt;
    state.headSha = run.head_sha;
    changes[statePath(pull.number)] = bytes(state);
    return changes;
  }

  const revision = await api.updateImages(
    temporaryBranch,
    'Update previews for PR #' + pull.number,
    prepare,
    guard,
  );
  await guard();
  return { revision, selected };
}

function urlPath(value) {
  return value.split('/').map(encodeURIComponent).join('/');
}

export function comment(run, pull, status, revision, selected = {}) {
  const runUrl = 'https://github.com/' + repository + '/actions/runs/' + run.id;
  let body =
    '提交 `' +
    run.head_sha +
    '` 的字体预览：' +
    status +
    '。\n\n' +
    '[构建记录](' +
    runUrl +
    ')\n\n';
  const total = Object.values(selected).reduce(
    (count, value) => count + (value?.manifest.images.length ?? 0),
    0,
  );
  let displayed = 0;

  for (const name of Object.keys(selected).sort()) {
    const item = selected[name];

    if (!item) {
      continue;
    }

    let heading = '### `' + name + '`\n\n';

    for (const image of item.manifest.images) {
      const url =
        'https://raw.githubusercontent.com/' +
        repository +
        '/' +
        revision +
        '/' +
        urlPath(item.prefix + '/' + image.path);
      const target = item.cacheable
        ? '预计正式路径：`' + formalBranch + '/' + image.path + '`。'
        : '仅 PR 预览；不可再分发字体不生成 main 正式图片。';
      const block = heading + '![字体预览](' + url + ')\n\n' + target + '\n\n';

      if (Buffer.byteLength(body + block) > 50000) {
        break;
      }

      body += block;
      heading = '';
      displayed += 1;
    }
  }

  if (total) {
    body +=
      '显示 ' +
      displayed +
      '/' +
      total +
      ' 张图片。' +
      '[全部图片](https://github.com/' +
      repository +
      '/tree/' +
      revision +
      '/prs/' +
      pull.number +
      ')\n';
  }

  return body;
}

export function output(values) {
  const lines = Object.entries(values).map(([key, value]) => {
    ensure(!/[\r\n]/.test(String(value)), 'Multiline workflow output');
    return key + '=' + value;
  });
  fs.appendFileSync(process.env.GITHUB_OUTPUT, lines.join('\n') + '\n');
}

export async function publishCommand(mode) {
  ensure(
    process.env.GITHUB_EVENT_NAME === 'workflow_run' &&
      process.env.GITHUB_REPOSITORY === repository,
    'Publisher requires an upstream workflow_run context',
  );
  const event = readJson(process.env.GITHUB_EVENT_PATH);
  const api = new GitHub(process.env.GITHUB_TOKEN, mode !== 'identify');
  let resolved;

  try {
    resolved = await resolveRun(api, event);
    await currentGuard(api, resolved.run, resolved.pull);
  } catch (error) {
    if (!(error instanceof Superseded)) {
      throw error;
    }

    console.log(error.message);
    return;
  }

  const { run, pull } = resolved;

  if (mode === 'identify') {
    output({ pr: pull.number });
    return;
  }

  if (mode === 'finalize') {
    const report = readJson('.ci-work/report.json');
    ensure(
      report.runId === run.id &&
        report.runAttempt === run.run_attempt &&
        report.headSha === run.head_sha &&
        report.pr === pull.number,
      'Final preview report identity mismatch',
    );
    const commentFailed = process.env.COMMENT_RESULT !== 'success';
    const failed = report.failed || commentFailed;
    const summary =
      report.summary +
      (commentFailed
        ? '\nThe preview comment could not be updated. Retry publication.'
        : '');
    await check(
      api,
      run,
      summary.slice(0, 60000),
      failed ? 'failure' : 'success',
    );
    process.exitCode = failed ? 1 : 0;
    return;
  }

  let failed = false;
  let summary = 'Waiting for the current font build and preview results.';
  let body = comment(run, pull, '正在生成；旧提交图片已隐藏');
  const completed = run.status === 'completed';
  await check(api, run, summary);

  if (completed) {
    try {
      const result = await consume(api, run, pull);
      const { plan, records, bundles, errors } = result;
      const { revision, selected } = await publish(
        api,
        run,
        pull,
        plan,
        records,
        bundles,
      );
      const missing = Object.keys(plan.packages).filter(
        (name) => !Object.hasOwn(selected, name),
      );
      failed = !!(
        errors.length ||
        missing.length ||
        run.conclusion !== 'success'
      );
      summary = [...errors, 'Unverified packages: ' + missing.join(', ')].join(
        '\n',
      );

      if (!failed) {
        summary = Object.values(plan.packages).some((item) => item.preview)
          ? 'All current previews are validated and published.'
          : 'No new-font previews required.';
      }

      await currentGuard(api, run, pull);
      body = comment(
        run,
        pull,
        failed ? '部分失败，请查看构建记录' : '已验证',
        revision,
        selected,
      );
    } catch (error) {
      if (error instanceof Superseded) {
        return;
      }

      await currentGuard(api, run, pull);
      console.error('Preview publication failed:', error.message);
      summary = 'Preview publication failed; resolve the error and retry.';
      body = comment(run, pull, '发布失败；旧提交图片已隐藏，请查看任务日志');
      failed = true;
    }

    writeJson('.ci-work/report.json', {
      runId: run.id,
      runAttempt: run.run_attempt,
      headSha: run.head_sha,
      pr: pull.number,
      failed,
      summary,
    });
  }

  fs.mkdirSync('.ci-work', { recursive: true });
  fs.writeFileSync('.ci-work/comment.md', body);
  output({ pr: pull.number, failed, completed });
}
