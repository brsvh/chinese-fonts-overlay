import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import { fileURLToPath, pathToFileURL } from 'node:url';
import {
  command,
  ensure,
  readJson,
  repository,
  sha,
  writeJson,
} from './common.mjs';
import { GitHub, output } from './github.mjs';
import { fields, positive } from './records.mjs';

const repositoryId = 772409384;
const herculesId = 47349067;
const actionsId = 41898282;
const stateDirectory = '/site-state';
const workflowPath = '.github/workflows/site-deploy.yml';
const root = fileURLToPath(new URL('..', import.meta.url));
const releasePattern = /^site-[0-9a-f]{40}-[0-9a-f]{64}$/;

function environment(name) {
  ensure(process.env[name], 'Missing environment variable: ' + name);
  return process.env[name];
}

function archiveCommand(...args) {
  return command('guile', [
    '--no-auto-compile',
    '-L',
    path.join(root, 'site/module'),
    path.join(root, 'site/scripts/archive.scm'),
    ...args,
  ]);
}

function siteManifest(file) {
  const base = archiveCommand('validate', file);
  ensure(releasePattern.test(base), 'Invalid archive validator output');
  return { manifest: readJson(file), base };
}

async function digest(file) {
  const hash = createHash('sha256');
  for await (const chunk of fs.createReadStream(file)) hash.update(chunk);
  return 'sha256:' + hash.digest('hex');
}

async function mainRevision(api) {
  const ref = await api.request('/git/ref/heads/main');
  ensure(
    ref.object.type === 'commit' && sha.test(ref.object.sha),
    'Invalid main reference',
  );
  return ref.object.sha;
}

async function artifactRelease(api) {
  const release = await api.request('/releases/tags/site-artifacts');
  ensure(
    positive(release.id) &&
      release.tag_name === 'site-artifacts' &&
      release.draft === false &&
      release.prerelease === true,
    'Invalid site artifact release',
  );
  return release;
}

function validateAsset(asset, name, owner) {
  ensure(
    positive(asset?.id) &&
      asset.name === name &&
      asset.state === 'uploaded' &&
      asset.uploader?.id === owner &&
      positive(asset.size) &&
      asset.size < 1000000000 &&
      /^sha256:[0-9a-f]{64}$/.test(asset.digest),
    'Invalid site asset identity or publisher',
  );
  return asset;
}

function validateNotification(event) {
  ensure(
    event.action === 'site-ready' &&
      event.repository?.id === repositoryId &&
      event.sender?.id === herculesId,
    'Invalid site-ready notification',
  );
  const payload = event.client_payload;
  fields(payload, ['archive', 'manifest', 'release', 'source']);
  ensure(
    sha.test(payload.source) &&
      ['archive', 'manifest', 'release'].every((key) => positive(payload[key])),
    'Invalid site-ready payload',
  );
  return payload;
}

function herculesApi() {
  ensure(
    environment('HERCULES_CI_PROJECT_PATH') === 'github/' + repository,
    'Unexpected Hercules project',
  );
  const secrets = readJson(environment('HERCULES_CI_SECRETS_JSON'));
  return new GitHub(secrets.git.data.token, true);
}

function actionsApi(writable = false) {
  ensure(
    environment('GITHUB_REPOSITORY') === repository &&
      environment('GITHUB_REF') === 'refs/heads/main' &&
      environment('GITHUB_WORKFLOW_REF') ===
        repository + '/' + workflowPath + '@refs/heads/main',
    'Unexpected publication workflow context',
  );
  return new GitHub(environment('GITHUB_TOKEN'), writable);
}

async function releaseAssets(api, release) {
  return api.pages('/releases/' + release.id + '/assets');
}

async function ensureAsset(api, release, file, contentType, owner) {
  const name = path.basename(file);
  let asset = (await releaseAssets(api, release)).find(
    (item) => item.name === name,
  );
  if (!asset) {
    try {
      asset = await api.uploadAsset(release.id, file, contentType);
    } catch (error) {
      // A response can be lost after GitHub has accepted the complete upload.
      asset = (await releaseAssets(api, release)).find(
        (item) => item.name === name,
      );
      if (!asset) throw error;
    }
  }
  validateAsset(asset, name, owner);
  ensure(
    asset.size === fs.statSync(file).size &&
      asset.digest === (await digest(file)),
    'Existing release asset differs; refusing replacement',
  );
  return asset;
}

export async function buildSite(source) {
  ensure(sha.test(source), 'Invalid site source revision');
  const api = herculesApi();
  if (source !== (await mainRevision(api))) return;
  // Queue a later job so upload receives a fresh credential after rendering.
  const tag = 'ci/site/' + source + '/' + randomUUID();
  await api.request('/git/refs', {
    method: 'POST',
    body: { ref: 'refs/tags/' + tag, sha: source },
  });
  command(
    'git',
    [
      '-c',
      'http.version=HTTP/1.1',
      'clone',
      '--no-checkout',
      '--filter=blob:none',
      '--single-branch',
      '--branch',
      'main',
      'https://github.com/' + repository + '.git',
      'source',
    ],
    { stdio: 'inherit' },
  );
  command('git', ['-C', 'source', 'checkout', '--detach', source], {
    stdio: 'inherit',
  });
  ensure(
    command('git', ['-C', 'source', 'rev-parse', 'HEAD']) === source,
    'Unexpected source checkout',
  );
  const sourceRoot = fs.realpathSync('source');
  const build = path.join(stateDirectory, 'build');
  fs.mkdirSync(build, { recursive: true });
  const args = [
    'develop',
    '--no-write-lock-file',
    '--no-update-lock-file',
    sourceRoot + '#site',
    '-c',
    'env',
    'NIX_ENFORCE_PURITY=0',
    'make',
    '-C',
    path.join(sourceRoot, 'site'),
    '-j2',
    'BUILD_DIR=' + build,
    'CACHE_DIR=' + path.join(stateDirectory, 'cache'),
    'SOURCE_REVISION=' + source,
  ];
  for (const target of ['check', 'all'])
    command('nix', [...args, target], { stdio: 'inherit' });
  const releases = path.join(stateDirectory, 'releases');
  fs.mkdirSync(releases, { recursive: true });
  const temporary = fs.mkdtempSync(path.join(releases, '.staging-'));
  try {
    const packed = path.join(temporary, 'release');
    command('nix', [...args, 'release', 'RELEASE_DIR=' + packed], {
      stdio: 'inherit',
    });
    const destination = path.join(releases, source);
    fs.rmSync(destination, { recursive: true, force: true });
    fs.renameSync(packed, destination);
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
}

export async function deploySite(source) {
  ensure(sha.test(source), 'Invalid site source revision');
  const api = herculesApi();
  if (source !== (await mainRevision(api))) return;
  const directory = path.join(stateDirectory, 'releases', source);
  const files = fs
    .readdirSync(directory)
    .filter((name) => name.endsWith('.json'));
  ensure(files.length === 1, 'Missing completed site release');
  const { manifest, base } = siteManifest(path.join(directory, files[0]));
  ensure(manifest.source === source, 'Wrong staged revision');
  const release = await artifactRelease(api);
  const archive = await ensureAsset(
    api,
    release,
    path.join(directory, base + '.tar.gz'),
    'application/gzip',
    herculesId,
  );
  const metadata = await ensureAsset(
    api,
    release,
    path.join(directory, base + '.json'),
    'application/json',
    herculesId,
  );
  ensure(
    archive.digest === 'sha256:' + manifest.sha256 &&
      archive.size === manifest.size,
    'Staged archive differs from its manifest',
  );
  if (source !== (await mainRevision(api))) return;
  await api.request('/dispatches', {
    method: 'POST',
    body: {
      event_type: 'site-ready',
      client_payload: {
        release: release.id,
        archive: archive.id,
        manifest: metadata.id,
        source,
      },
    },
  });
  fs.writeFileSync(path.join(directory, '.uploaded'), '');
  pruneStagedReleases();
}

function pruneStagedReleases() {
  const releases = path.join(stateDirectory, 'releases');
  const uploaded = fs
    .readdirSync(releases)
    .filter(
      (name) =>
        sha.test(name) && fs.existsSync(path.join(releases, name, '.uploaded')),
    );
  uploaded.sort(
    (a, b) =>
      fs.statSync(path.join(releases, b, '.uploaded')).mtimeMs -
      fs.statSync(path.join(releases, a, '.uploaded')).mtimeMs,
  );
  for (const name of uploaded.slice(3))
    fs.rmSync(path.join(releases, name), { recursive: true });
}

async function readAssetJson(api, asset) {
  ensure(asset.size <= 65536, 'JSON asset too large');
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'site-json-'));
  try {
    const file = path.join(temporary, 'data.json');
    await api.downloadAsset(asset, file);
    return readJson(file);
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
}

async function deploymentReceipts(api, assets) {
  const candidates = assets
    .filter(
      (asset) =>
        /^site-deployed-[0-9]+-[0-9]+\.json$/.test(asset.name) &&
        asset.uploader?.id === actionsId,
    )
    .sort((a, b) => b.created_at.localeCompare(a.created_at));
  const records = [];
  for (const asset of candidates) {
    validateAsset(asset, asset.name, actionsId);
    const record = await readAssetJson(api, asset);
    ensure(
      record.schema === 1 &&
        releasePattern.test(record.base) &&
        ['run', 'attempt', 'archive', 'manifest'].every((key) =>
          positive(record[key]),
        ),
      'Invalid deployment receipt',
    );
    const runPath =
      '/actions/runs/' + record.run + '/attempts/' + record.attempt;
    const run = await api.request(runPath);
    const jobs = await api.pages(runPath + '/jobs', 'jobs');
    if (
      run.path === workflowPath &&
      run.head_branch === 'main' &&
      ['repository_dispatch', 'workflow_dispatch'].includes(run.event) &&
      jobs.some(
        (job) => job.name === 'Deploy website' && job.conclusion === 'success',
      )
    )
      records.push(record);
  }
  return records;
}

export async function receiveSite(destination) {
  const api = actionsApi();
  const event = readJson(environment('GITHUB_EVENT_PATH'));
  const automatic = environment('GITHUB_EVENT_NAME') === 'repository_dispatch';
  const release = await artifactRelease(api);
  const assets = await releaseAssets(api, release);
  let request;
  if (automatic) request = validateNotification(event);
  else {
    ensure(
      process.env.GITHUB_EVENT_NAME === 'workflow_dispatch',
      'Unexpected deployment event',
    );
    const base = event.inputs?.release;
    ensure(releasePattern.test(base), 'Invalid rollback release');
    const receipt = (await deploymentReceipts(api, assets)).find(
      (record) => record.base === base,
    );
    ensure(receipt, 'Rollback requires a previously successful deployment');
    request = {
      source: base.slice(5, 45),
      release: release.id,
      archive: receipt.archive,
      manifest: receipt.manifest,
    };
  }
  ensure(
    request.release === release.id,
    'Notification names a different release',
  );
  if (automatic && request.source !== (await mainRevision(api)))
    return output({ ready: false });
  const metadata = assets.find((asset) => asset.id === request.manifest);
  const archive = assets.find((asset) => asset.id === request.archive);
  ensure(metadata && archive, 'Release assets are missing');
  validateAsset(metadata, metadata.name, herculesId);
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'site-receive-'));
  try {
    ensure(metadata.size <= 65536, 'Manifest asset too large');
    const manifestFile = path.join(temporary, 'manifest.json');
    await api.downloadAsset(metadata, manifestFile);
    const { manifest, base } = siteManifest(manifestFile);
    ensure(
      manifest.source === request.source && metadata.name === base + '.json',
      'Manifest identity differs from notification',
    );
    validateAsset(archive, base + '.tar.gz', herculesId);
    ensure(
      archive.size === manifest.size &&
        archive.digest === 'sha256:' + manifest.sha256,
      'Archive metadata differs from manifest',
    );
    const file = path.join(temporary, 'site.tar.gz');
    await api.downloadAsset(archive, file);
    archiveCommand('unpack', file, manifestFile, destination);
    output({
      ready: true,
      source: manifest.source,
      base,
      archive: archive.id,
      manifest: metadata.id,
    });
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
}

export async function checkSite(source) {
  const api = actionsApi();
  ensure(sha.test(source), 'Invalid deployment source');
  output({
    ready:
      process.env.GITHUB_EVENT_NAME === 'workflow_dispatch' ||
      source === (await mainRevision(api)),
  });
}

export async function recordSite(base, archiveId, manifestId) {
  const api = actionsApi(true);
  ensure(
    releasePattern.test(base) && positive(archiveId) && positive(manifestId),
    'Invalid deployed artifact identity',
  );
  const run = Number(environment('GITHUB_RUN_ID'));
  const attempt = Number(environment('GITHUB_RUN_ATTEMPT'));
  ensure(positive(run) && positive(attempt), 'Invalid deployment run');
  const release = await artifactRelease(api);
  const assets = await releaseAssets(api, release);
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'site-record-'));
  try {
    const file = path.join(
      temporary,
      'site-deployed-' + run + '-' + attempt + '.json',
    );
    writeJson(file, {
      schema: 1,
      base,
      run,
      attempt,
      archive: archiveId,
      manifest: manifestId,
    });
    await ensureAsset(api, release, file, 'application/json', actionsId);
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
  const receipts = await deploymentReceipts(
    api,
    await releaseAssets(api, release),
  );
  const retained = [...new Set(receipts.map((record) => record.archive))].slice(
    0,
    3,
  );
  const obsolete = receipts.filter(
    (record) => !retained.includes(record.archive),
  );
  // Artifacts without a verified successful deployment remain pending.
  for (const id of new Set(
    obsolete.flatMap((record) => [record.archive, record.manifest]),
  )) {
    const asset = assets.find((item) => item.id === id);
    if (!asset) continue;
    validateAsset(asset, asset.name, herculesId);
    await api.request('/releases/assets/' + id, { method: 'DELETE' });
  }
}

if (
  process.argv[1] &&
  import.meta.url === pathToFileURL(process.argv[1]).href
) {
  try {
    const [action, ...args] = process.argv.slice(2);
    if (action === 'buildSite' && args.length === 1) await buildSite(args[0]);
    else if (action === 'deploySite' && args.length === 1)
      await deploySite(args[0]);
    else if (action === 'receiveSite' && args.length === 1)
      await receiveSite(args[0]);
    else if (action === 'checkSite' && args.length === 1)
      await checkSite(args[0]);
    else if (action === 'recordSite' && args.length === 3)
      await recordSite(args[0], Number(args[1]), Number(args[2]));
    else
      throw new Error(
        'Expected buildSite, deploySite, receiveSite, checkSite or recordSite arguments',
      );
  } catch (error) {
    console.error(error.message, error.details ?? '');
    process.exitCode = 1;
  }
}
