import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { ensure, matches, sha } from './common.mjs';
import { GarageBucket } from './garage.mjs';

const objectKey =
  /^[0-9a-f]{40}\/(manifest\.json|pages-[0-9a-f]{40}-[0-9a-f]{64}\.tar\.gz)$/;

export class PagesArtifactStore extends GarageBucket {
  constructor(credentials) {
    super('chinese-fonts-overlay-pages', credentials);
  }

  objects() {
    const response = this.call('list-objects-v2');
    ensure(!response.IsTruncated, 'Site bucket object listing is truncated');

    const objects = response.Contents ?? [];
    ensure(
      objects.every((item) => matches(objectKey, item.Key)),
      'Unexpected object in site bucket; refusing cleanup',
    );
    return objects;
  }

  download(key, file, size) {
    ensure(
      matches(objectKey, key) && size > 0 && size < 1000000000,
      'Invalid site download',
    );

    this.call('get-object', '--key', key, file);
    ensure(fs.statSync(file).size === size, 'Downloaded size differs');
  }

  manifest(source) {
    ensure(matches(sha, source), 'Invalid source revision');

    const object = this.objects().find(
      (item) => item.Key === source + '/manifest.json',
    );
    if (!object) return null;

    ensure(object.Size <= 65536, 'Manifest too large');

    const file = path.join(this.directory, 'manifest.json');
    this.download(object.Key, file, object.Size);
    return { file };
  }

  remove(key) {
    ensure(matches(objectKey, key), 'Invalid cleanup key');
    this.call('delete-object', '--key', key);
  }

  reserve(source, base, limit) {
    // The Hercules mount lock serializes every writer, including retries.
    ensure(limit === 1 || limit === 2, 'Invalid Pages retention limit');

    const objects = this.objects();
    const complete = objects
      .filter((item) => item.Key.endsWith('/manifest.json'))
      .sort((a, b) => Date.parse(b.LastModified) - Date.parse(a.LastModified));
    const keep = complete
      .filter((item) => !item.Key.startsWith(source + '/'))
      .slice(0, limit - 1)
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

    const multipart = this.call('list-multipart-uploads');
    ensure(
      !multipart.IsTruncated,
      'Site bucket multipart upload listing is truncated',
    );

    const uploads = multipart.Uploads ?? [];

    for (const upload of uploads) {
      ensure(matches(objectKey, upload.Key), 'Unexpected multipart upload');

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
    ensure(matches(objectKey, key), 'Invalid upload key');

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
