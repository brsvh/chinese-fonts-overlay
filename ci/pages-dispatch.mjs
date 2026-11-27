import { sign } from 'node:crypto';
import { setTimeout as delay } from 'node:timers/promises';
import { ensure, positiveInteger } from './common.mjs';
import { GitHub } from './github.mjs';
import { ApiError, request } from './http.mjs';

export const pagesRepositoryId = 772409384;
export const deployWorkflow = '.github/workflows/deploy.yml';

const deployTitlePattern = /^Deploy Pages ([0-9a-f]{40})$/;

async function installationClient(
  { clientId, installationId, privateKey },
  permissions = { actions: 'read', contents: 'write' },
  writable = true,
) {
  ensure(
    typeof clientId === 'string' &&
      clientId.length > 0 &&
      positiveInteger(installationId) &&
      typeof privateKey === 'string',
    'Invalid Pages dispatch App credentials',
  );

  const now = Math.floor(Date.now() / 1000);
  const encode = (value) =>
    Buffer.from(JSON.stringify(value)).toString('base64url');
  const message =
    encode({ alg: 'RS256', typ: 'JWT' }) +
    '.' +
    encode({ iat: now - 60, exp: now + 300, iss: clientId });
  const signature = sign('RSA-SHA256', Buffer.from(message), privateKey);

  const installation = await request(
    'https://api.github.com/app/installations/' +
      installationId +
      '/access_tokens',
    message + '.' + signature.toString('base64url'),
    {
      method: 'POST',
      body: {
        repository_ids: [pagesRepositoryId],
        permissions,
      },
      limit: 65536,
    },
  );

  ensure(
    typeof installation?.token === 'string' && installation.token.length > 0,
    'Missing Pages dispatch installation token',
  );

  return new GitHub(installation.token, writable);
}

function deployedRevisionFromRun(run, botId) {
  if (
    run.head_branch !== 'main' ||
    run.path !== deployWorkflow ||
    run.status !== 'completed' ||
    run.conclusion !== 'success'
  ) {
    return null;
  }

  const isBotDispatch =
    run.event === 'repository_dispatch' &&
    run.actor?.id === botId &&
    run.actor.type === 'Bot';

  if (!isBotDispatch && run.event !== 'workflow_dispatch') {
    return null;
  }

  const match =
    typeof run.display_title === 'string'
      ? run.display_title.match(deployTitlePattern)
      : null;

  if (!match || run.head_sha !== match[1]) {
    return null;
  }

  return match[1];
}

async function runCompletedPagesDeploy(api, runId) {
  ensure(positiveInteger(runId), 'Invalid workflow run ID');

  const response = await api.request(
    '/actions/runs/' + runId + '/jobs?filter=latest&per_page=100',
  );
  ensure(Array.isArray(response?.jobs), 'Invalid workflow jobs response');

  const deployJob = response.jobs.find(
    (job) => job.name === 'Deploy to GitHub Pages',
  );

  if (
    !deployJob ||
    deployJob.status !== 'completed' ||
    deployJob.conclusion !== 'success' ||
    !Array.isArray(deployJob.steps)
  ) {
    return false;
  }

  // Coupled to the unnamed actions/deploy-pages step in deploy.yml.
  return deployJob.steps.some(
    (step) =>
      typeof step.name === 'string' &&
      step.name.startsWith('Run actions/deploy-pages@') &&
      step.status === 'completed' &&
      step.conclusion === 'success',
  );
}

export async function latestDeployedPages(credentials) {
  const { botId } = credentials;
  ensure(positiveInteger(botId), 'Invalid Pages dispatch bot ID');

  const api = await installationClient(credentials, { actions: 'read' }, false);
  const query = new URLSearchParams({
    branch: 'main',
    status: 'success',
    per_page: '100',
  });
  const response = await api.request(
    '/actions/workflows/deploy.yml/runs?' + query,
  );
  ensure(
    Array.isArray(response?.workflow_runs),
    'Invalid workflow runs response',
  );

  const runs = [...response.workflow_runs].sort(
    (a, b) =>
      (Date.parse(b.updated_at ?? b.created_at) || 0) -
      (Date.parse(a.updated_at ?? a.created_at) || 0),
  );

  for (const run of runs) {
    const revision = deployedRevisionFromRun(run, botId);

    if (!revision) {
      continue;
    }

    if (await runCompletedPagesDeploy(api, run.id)) {
      return revision;
    }
  }

  return null;
}

async function findDeployment(api, source, botId) {
  const query = new URLSearchParams({
    event: 'repository_dispatch',
    head_sha: source,
    branch: 'main',
  });

  const runs = await api.pages(
    '/actions/workflows/deploy.yml/runs?' + query,
    'workflow_runs',
  );

  return runs.find(
    (run) =>
      run.event === 'repository_dispatch' &&
      run.head_branch === 'main' &&
      run.path === deployWorkflow &&
      run.head_sha === source &&
      run.display_title === 'Deploy Pages ' + source &&
      run.actor?.id === botId &&
      run.actor.type === 'Bot',
  );
}

export async function notifyPages(source, credentials, currentMain) {
  const { botId } = credentials;
  ensure(positiveInteger(botId), 'Invalid Pages dispatch bot ID');

  const api = await installationClient(credentials);
  if (await findDeployment(api, source, botId)) return;
  if (source !== currentMain()) return;

  try {
    await api.request('/dispatches', {
      method: 'POST',
      body: { event_type: 'pages-ready', client_payload: { source } },
    });
  } catch (error) {
    if (
      error instanceof ApiError &&
      error.status >= 400 &&
      error.status < 500 &&
      error.status !== 408
    ) {
      throw error;
    }

    // GitHub may have accepted the event before the response was lost.
    console.error('Pages dispatch response unconfirmed:', error.message);
  }

  for (let attempt = 0; attempt < 12; attempt += 1) {
    if (await findDeployment(api, source, botId)) return;
    if (attempt < 11) await delay(5000);
  }

  if (source !== currentMain()) return;
  throw new Error(
    'Archive is ready but Pages dispatch is unconfirmed; retry buildPages',
  );
}
