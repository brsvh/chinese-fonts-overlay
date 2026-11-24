import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { command, ensure, readJson, sha } from './common.mjs';

const endpoint = 'https://s3.bingshan.org';
const bucket = 'chinese-fonts-overlay-pages';
const objectKey =
  /^[0-9a-f]{40}\/(manifest\.json|pages-[0-9a-f]{40}-[0-9a-f]{64}\.tar\.gz)$/;

export class PagesArtifactStore {
  constructor({ accessKeyId, secretAccessKey }) {
    ensure(accessKeyId && secretAccessKey, 'Missing site storage credentials');

    this.directory = fs.mkdtempSync(path.join(os.tmpdir(), 'pages-artifacts-'));
    const config = path.join(this.directory, 'config');
    fs.writeFileSync(config, '[default]\ns3 =\n    addressing_style = path\n');

    this.env = {
      ...process.env,
      AWS_ACCESS_KEY_ID: accessKeyId,
      AWS_SECRET_ACCESS_KEY: secretAccessKey,
      AWS_CONFIG_FILE: config,
      AWS_SHARED_CREDENTIALS_FILE: '/dev/null',
      AWS_EC2_METADATA_DISABLED: 'true',
      AWS_MAX_ATTEMPTS: '5',
      AWS_RETRY_MODE: 'standard',
      AWS_REQUEST_CHECKSUM_CALCULATION: 'WHEN_REQUIRED',
      AWS_RESPONSE_CHECKSUM_VALIDATION: 'WHEN_REQUIRED',
    };

    delete this.env.AWS_SESSION_TOKEN;
    delete this.env.AWS_PROFILE;
  }

  close() {
    fs.rmSync(this.directory, { recursive: true, force: true });
  }

  call(operation, ...args) {
    const result = command(
      'aws',
      [
        '--endpoint-url',
        endpoint,
        '--region',
        'garage',
        '--no-cli-pager',
        '--cli-connect-timeout',
        '30',
        '--cli-read-timeout',
        '300',
        's3api',
        operation,
        '--bucket',
        bucket,
        ...args,
        '--output',
        'json',
      ],
      { env: this.env },
    );

    return result ? JSON.parse(result) : {};
  }

  objects() {
    const objects = this.call('list-objects-v2').Contents ?? [];
    ensure(
      objects.every((item) => objectKey.test(item.Key)),
      'Unexpected object in site bucket; refusing cleanup',
    );
    return objects;
  }

  download(key, file, size) {
    ensure(
      objectKey.test(key) && size > 0 && size < 1000000000,
      'Invalid site download',
    );

    this.call('get-object', '--key', key, file);
    ensure(fs.statSync(file).size === size, 'Downloaded size differs');
  }

  manifest(source) {
    ensure(sha.test(source), 'Invalid source revision');

    const object = this.objects().find(
      (item) => item.Key === source + '/manifest.json',
    );
    if (!object) return null;

    ensure(object.Size <= 65536, 'Manifest too large');

    const file = path.join(this.directory, 'manifest.json');
    this.download(object.Key, file, object.Size);
    return { file, data: readJson(file) };
  }

  remove(key) {
    ensure(objectKey.test(key), 'Invalid cleanup key');
    this.call('delete-object', '--key', key);
  }

  reserve(source, base) {
    // The Hercules mount lock serializes every writer, including retries.
    const objects = this.objects();
    const complete = objects
      .filter((item) => item.Key.endsWith('/manifest.json'))
      .sort((a, b) => b.LastModified.localeCompare(a.LastModified));
    const keep = complete
      .filter((item) => !item.Key.startsWith(source + '/'))
      .slice(0, 1)
      .map((item) => item.Key.split('/')[0]);

    // Remove completion markers first; a failed deletion never invites upload.
    for (const item of complete) {
      if (!keep.includes(item.Key.split('/')[0])) this.remove(item.Key);
    }

    for (const item of objects.filter((item) => item.Key.endsWith('.tar.gz'))) {
      if (
        !keep.includes(item.Key.split('/')[0]) &&
        item.Key !== source + '/' + base + '.tar.gz'
      )
        this.remove(item.Key);
    }

    const uploads = this.call('list-multipart-uploads').Uploads ?? [];
    for (const upload of uploads) {
      ensure(objectKey.test(upload.Key), 'Unexpected multipart upload');
      if (Date.parse(upload.Initiated) < Date.now() - 86400000) {
        this.call(
          'abort-multipart-upload',
          '--key',
          upload.Key,
          '--upload-id',
          upload.UploadId,
        );
      }
    }
  }

  async upload(key, file) {
    ensure(objectKey.test(key), 'Invalid upload key');

    const md5 = createHash('md5');
    const sha256 = createHash('sha256');
    for await (const chunk of fs.createReadStream(file)) {
      md5.update(chunk);
      sha256.update(chunk);
    }

    const checksum = sha256.digest('hex');
    if (this.objects().some((item) => item.Key === key)) {
      const existing = this.call('head-object', '--key', key);
      ensure(
        existing.ContentLength === fs.statSync(file).size &&
          existing.Metadata?.sha256 === checksum,
        'Existing site object differs; refusing replacement',
      );
      return;
    }

    // Archives are below 1 GB. A single atomic PUT avoids abandoned parts.
    this.call(
      'put-object',
      '--key',
      key,
      '--body',
      file,
      '--content-md5',
      md5.digest('base64'),
      '--metadata',
      'sha256=' + checksum,
    );
  }
}
