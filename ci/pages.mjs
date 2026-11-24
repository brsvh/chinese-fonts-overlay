import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { command, ensure, readJson, repository, sha } from './common.mjs';
import { GitHub, output } from './github.mjs';
import { GarageBucket } from './garage.mjs';
import { PagesArtifactStore } from './pages-artifacts.mjs';

const repositoryId = 772409384;
const herculesId = 47349067;
const stateDirectory = '/pages-state';
const workflowPath = '.github/workflows/deploy.yml';
const root = fileURLToPath(new URL('..', import.meta.url));

function environment(name) {
  ensure(process.env[name], 'Missing environment variable: ' + name);
  return process.env[name];
}

function archiveCommand(...args) {
  return command('guile', [
    '--no-auto-compile',
    '-L',
    path.join(root, 'pages/module'),
    path.join(root, 'pages/build-aux/archive.scm'),
    ...args,
  ]);
}

function readArtifactManifest(file) {
  const base = archiveCommand('validate', file);
  ensure(
    /^pages-[0-9a-f]{40}-[0-9a-f]{64}$/.test(base),
    'Invalid archive validator output',
  );
  return { manifest: readJson(file), base };
}

async function mainRevision(api) {
  const ref = await api.request('/git/ref/heads/main');
  ensure(
    ref.object.type === 'commit' && sha.test(ref.object.sha),
    'Invalid main reference',
  );
  return ref.object.sha;
}

function remoteMain() {
  const ref = command('git', [
    'ls-remote',
    '--exit-code',
    'https://github.com/' + repository + '.git',
    'refs/heads/main',
  ]);
  const parts = ref.split(/\s+/);
  ensure(
    parts.length === 2 && sha.test(parts[0]) && parts[1] === 'refs/heads/main',
    'Invalid remote main reference',
  );
  return parts[0];
}

function actionsApi() {
  ensure(
    environment('GITHUB_REPOSITORY') === repository &&
      environment('GITHUB_REF') === 'refs/heads/main' &&
      environment('GITHUB_WORKFLOW_REF') ===
        repository + '/' + workflowPath + '@refs/heads/main',
    'Unexpected publication workflow context',
  );
  return new GitHub(environment('GITHUB_TOKEN'));
}

export async function buildPages(source) {
  ensure(sha.test(source), 'Invalid site source revision');
  ensure(
    environment('HERCULES_CI_PROJECT_PATH') === 'github/' + repository,
    'Unexpected Hercules project',
  );

  // Public Git reads avoid expiring tokens and anonymous API rate limits.
  if (source !== remoteMain()) return;

  const secrets = readJson(environment('HERCULES_CI_SECRETS_JSON'));

  const store = new PagesArtifactStore(secrets.pagesArtifacts.data);

  try {
    const existing = store.manifest(source);
    if (existing) {
      const { manifest, base } = readArtifactManifest(existing.file);
      ensure(manifest.source === source, 'Stored source differs');
      const archive = store
        .objects()
        .find((item) => item.Key === source + '/' + base + '.tar.gz');
      ensure(archive?.Size === manifest.size, 'Stored archive is incomplete');
      return;
    }

    const inputs = new GarageBucket(
      'chinese-fonts-overlay-webfonts',
      secrets.webfonts.data,
    );
    try {
      const library = path.join(inputs.directory, 'library');
      downloadWebfonts(inputs, library);
      buildArchive(source, library);
    } finally {
      inputs.close();
    }

    if (source !== remoteMain()) return;

    const directory = path.join(stateDirectory, 'releases', source);
    const names = fs
      .readdirSync(directory)
      .filter((name) => name.endsWith('.json'));
    ensure(names.length === 1, 'Missing completed site archive');

    const file = path.join(directory, names[0]);
    const { manifest, base } = readArtifactManifest(file);
    ensure(manifest.source === source, 'Staged source differs');

    const archive = path.join(directory, base + '.tar.gz');
    const verified = path.join(directory, '.verified');

    try {
      archiveCommand('unpack', archive, file, verified);
    } finally {
      fs.rmSync(verified, { recursive: true, force: true });
    }

    const limit = secrets.pagesArtifacts.data.maxVersions ?? 2;
    store.reserve(source, base, limit);
    await store.upload(source + '/' + base + '.tar.gz', archive);

    // This atomic marker is written only after the validated archive arrives.
    await store.upload(source + '/manifest.json', file);
    ensure(
      store.objects().filter((item) => item.Key.endsWith('/manifest.json'))
        .length <= limit,
      'Site retention limit exceeded',
    );
  } finally {
    store.close();
  }
}

function downloadWebfonts(bucket, library) {
  const { prefix, faces } = readJson(
    path.join(root, 'pages/etc/webfonts.json'),
  );
  for (const face of faces) {
    const name = path.basename(face.path);
    const file = path.join(library, face.path);
    fs.mkdirSync(path.dirname(file), { recursive: true });
    bucket.call('get-object', '--key', prefix + '/' + face.path, file);

    const actual = createHash('sha256')
      .update(fs.readFileSync(file))
      .digest('hex');
    ensure(actual === face.sha256, 'Webfont digest differs: ' + name);
  }
}

function buildArchive(source, library) {
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
    sourceRoot + '#pages',
    '-c',
    'env',
    'NIX_ENFORCE_PURITY=0',
    'make',
    '-C',
    path.join(sourceRoot, 'pages'),
    '-j2',
    'BUILD_DIR=' + build,
    'CACHE_DIR=' + path.join(stateDirectory, 'cache'),
    'SOURCE_REVISION=' + source,
  ];

  command('nix', [...args, 'check'], { stdio: 'inherit' });
  args.push('WEBFONTS_DIR=' + library);
  command('nix', [...args, 'all'], { stdio: 'inherit' });

  const releases = path.join(stateDirectory, 'releases');
  fs.mkdirSync(releases, { recursive: true });
  for (const name of fs.readdirSync(releases)) {
    if (/^\.staging-[A-Za-z0-9]+$/.test(name)) {
      fs.rmSync(path.join(releases, name), { recursive: true, force: true });
    }
  }

  const previous = fs
    .readdirSync(releases)
    .filter((name) => sha.test(name))
    .sort(
      (a, b) =>
        fs.statSync(path.join(releases, b)).mtimeMs -
        fs.statSync(path.join(releases, a)).mtimeMs,
    );
  for (const name of previous.slice(1)) {
    fs.rmSync(path.join(releases, name), { recursive: true, force: true });
  }

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

export async function receivePagesArtifact(destination) {
  const api = actionsApi();
  const event = readJson(environment('GITHUB_EVENT_PATH'));
  const current = await mainRevision(api);

  let source;
  if (environment('GITHUB_EVENT_NAME') === 'status') {
    ensure(
      event.repository?.id === repositoryId &&
        event.sender?.id === herculesId &&
        event.sender?.login === 'hercules-ci[bot]' &&
        event.context === 'ci/hercules/onPush/buildPages' &&
        event.state === 'success' &&
        sha.test(event.sha),
      'Invalid Hercules build status',
    );
    source = event.sha;
  } else {
    ensure(
      process.env.GITHUB_EVENT_NAME === 'workflow_dispatch',
      'Unexpected deployment event',
    );
    source = current;
  }

  if (source !== current) return output({ ready: false });

  const store = new PagesArtifactStore({
    accessKeyId: environment('PAGES_S3_ACCESS_KEY_ID'),
    secretAccessKey: environment('PAGES_S3_SECRET_ACCESS_KEY'),
  });

  try {
    const metadata = store.manifest(source);
    ensure(
      metadata,
      'No completed artifact for current main; retry buildPages',
    );
    const { manifest, base } = readArtifactManifest(metadata.file);
    ensure(manifest.source === source, 'Manifest source differs');

    const key = source + '/' + base + '.tar.gz';
    const object = store.objects().find((item) => item.Key === key);
    ensure(object?.Size === manifest.size, 'Archive size differs');

    const archive = path.join(store.directory, 'pages.tar.gz');
    store.download(key, archive, manifest.size);
    archiveCommand('unpack', archive, metadata.file, destination);
    output({ ready: true, source });
  } finally {
    store.close();
  }
}

export async function checkDeploymentRevision(source) {
  ensure(sha.test(source), 'Invalid deployment source');
  output({ ready: source === (await mainRevision(actionsApi())) });
}

if (
  process.argv[1] &&
  import.meta.url === pathToFileURL(process.argv[1]).href
) {
  try {
    const [action, ...args] = process.argv.slice(2);
    ensure(args.length === 1, 'Expected one argument');

    if (action === 'buildPages') await buildPages(args[0]);
    else if (action === 'receivePagesArtifact')
      await receivePagesArtifact(args[0]);
    else if (action === 'checkDeploymentRevision')
      await checkDeploymentRevision(args[0]);
    else
      throw new Error(
        'Expected buildPages, receivePagesArtifact or checkDeploymentRevision',
      );
  } catch (error) {
    console.error(error.message, error.details ?? '');
    process.exitCode = 1;
  }
}
