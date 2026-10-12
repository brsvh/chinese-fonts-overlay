import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { inflateRawSync, inflateSync } from 'node:zlib';
import {
  bytes,
  canonical,
  command,
  ensure,
  fingerprint,
  identifier,
  maxData,
  parseJson,
  policy,
  repository,
  schema,
  sha,
  storePattern,
} from './common.mjs';

export const maxImage = 4 * 1024 * 1024;
export const maxImages = 1024;
export const maxBundle = 64 * 1024 * 1024;
export const packageName = /^[a-z0-9][a-z0-9_+-]*$/;
export const workflowPath = '.github/workflows/build.yml';
export const workflowName = 'Font builds';
export const temporaryBranch = 'font-preview-prs';
export const formalBranch = 'font-preview-images';

export function same(left, right) {
  return JSON.stringify(canonical(left)) === JSON.stringify(canonical(right));
}

export function fields(value, expected) {
  ensure(
    value !== null &&
      typeof value === 'object' &&
      !Array.isArray(value) &&
      same(Object.keys(value).sort(), [...expected].sort()),
    'Unexpected data fields',
  );
}

export function positive(value) {
  return Number.isSafeInteger(value) && value > 0;
}

export function safePath(value) {
  ensure(
    typeof value === 'string' &&
      value.length > 0 &&
      !value.startsWith('/') &&
      !value.includes('\\') &&
      !/[\x00-\x1f\x7f]/.test(value) &&
      !value.split('/').some((part) => ['', '.', '..'].includes(part)) &&
      Buffer.byteLength(value) <= 1024,
    'Unsafe relative path',
  );
  return value;
}

export function imagePath(value, vendor, pname) {
  const parts = safePath(value).split('/');
  ensure(
    parts.length === 2 &&
      parts[0] === vendor &&
      parts[1].startsWith(pname + '+') &&
      parts[1].endsWith('.png'),
    'Unexpected preview path',
  );
  return value;
}

export function crc32(data) {
  let crc = 0xffffffff;

  for (const byte of data) {
    crc ^= byte;

    for (let bit = 0; bit < 8; bit += 1) {
      crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
    }
  }

  return (crc ^ 0xffffffff) >>> 0;
}

function paeth(left, up, diagonal) {
  const prediction = left + up - diagonal;
  const values = [left, up, diagonal];
  const distances = values.map((value) => Math.abs(prediction - value));
  return values[distances.indexOf(Math.min(...distances))];
}

export function pngInfo(data) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  ensure(
    data.length >= 33 &&
      data.length <= maxImage &&
      data.subarray(0, 8).equals(signature),
    'Invalid PNG signature or size',
  );
  const compressed = [];
  let offset = 8;
  let previousKind = null;
  let width = 0;
  let height = 0;

  while (offset < data.length) {
    ensure(offset + 12 <= data.length, 'Truncated PNG chunk');
    const length = data.readUInt32BE(offset);
    const end = offset + length + 12;
    ensure(end <= data.length, 'Truncated PNG payload');
    const kind = data.toString('ascii', offset + 4, offset + 8);
    const payload = data.subarray(offset + 8, end - 4);
    ensure(
      crc32(data.subarray(offset + 4, end - 4)) === data.readUInt32BE(end - 4),
      'PNG checksum mismatch',
    );

    if (kind === 'IHDR' && !previousKind && length === 13) {
      width = payload.readUInt32BE(0);
      height = payload.readUInt32BE(4);
      ensure(
        height > 0 && height < width && width <= 4096 && height <= 1024,
        'Preview must be bounded and horizontal',
      );
      ensure(
        payload.subarray(8).equals(Buffer.from([8, 2, 0, 0, 0])),
        'Preview must be non-interlaced RGB8',
      );
    } else if (kind === 'IDAT' && ['IHDR', 'IDAT'].includes(previousKind)) {
      compressed.push(payload);
    } else if (kind === 'IEND' && previousKind === 'IDAT' && length === 0) {
      ensure(end === data.length, 'Trailing PNG content');
    } else {
      throw new Error('Unexpected PNG chunk or order');
    }

    previousKind = kind;
    offset = end;
  }

  ensure(previousKind === 'IEND', 'Incomplete PNG');
  const stride = width * 3;
  const expected = (stride + 1) * height;
  const input = Buffer.concat(compressed);
  const inflated = inflateSync(input, {
    maxOutputLength: expected + 1,
    info: true,
  });
  ensure(
    inflated.buffer.length === expected &&
      inflated.engine.bytesWritten === input.length,
    'Invalid PNG decompressed size or trailing stream',
  );
  let previous = Buffer.alloc(stride);
  let firstPixel;
  let nonblank = false;

  for (let row = 0; row < height; row += 1) {
    const start = row * (stride + 1);
    const filter = inflated.buffer[start];
    ensure(filter <= 4, 'Unknown PNG filter');
    const decoded = Buffer.from(
      inflated.buffer.subarray(start + 1, start + stride + 1),
    );

    for (let column = 0; column < stride; column += 1) {
      const left = column >= 3 ? decoded[column - 3] : 0;
      const up = previous[column];
      const diagonal = column >= 3 ? previous[column - 3] : 0;
      const predictors = [
        0,
        left,
        up,
        Math.floor((left + up) / 2),
        paeth(left, up, diagonal),
      ];
      decoded[column] = (decoded[column] + predictors[filter]) & 255;
    }

    for (let column = 0; column < stride; column += 3) {
      const pixel = decoded.readUIntBE(column, 3);
      firstPixel ??= pixel;
      nonblank ||= pixel !== firstPixel;
    }

    previous = decoded;
  }

  ensure(nonblank, 'Blank preview');
  return {
    width,
    height,
    sha256: createHash('sha256').update(data).digest('hex'),
  };
}

export function validateContext(value) {
  fields(value, ['headSha', 'mergeSha', 'runId', 'runAttempt']);
  ensure(
    sha.test(value.headSha) &&
      sha.test(value.mergeSha) &&
      positive(value.runId) &&
      positive(value.runAttempt),
    'Invalid run context',
  );
  return value;
}

function validateSource(value) {
  if (value?.kind === 'main') {
    fields(value, ['kind', 'rev']);
    ensure(sha.test(value.rev), 'Invalid main preview revision');
  } else {
    ensure(value?.kind === 'pr', 'Invalid preview provenance');
    const { kind, ...context } = value;
    validateContext(context);
  }
}

export function validateManifest(manifest, files, expected = {}) {
  fields(manifest, [
    'schema',
    'package',
    'vendor',
    'pname',
    'buildKey',
    'previewKey',
    'source',
    'images',
  ]);
  ensure(
    manifest.schema === schema &&
      identifier.test(manifest.package) &&
      manifest.vendor === manifest.package.split('.')[0] &&
      typeof manifest.pname === 'string' &&
      packageName.test(manifest.pname) &&
      fingerprint.test(manifest.buildKey) &&
      fingerprint.test(manifest.previewKey),
    'Invalid preview identity or fingerprint',
  );
  validateSource(manifest.source);

  for (const [key, value] of Object.entries(expected)) {
    ensure(same(manifest[key], value), 'Preview context mismatch: ' + key);
  }

  const images = manifest.images;
  ensure(
    Array.isArray(images) && images.length > 0 && images.length <= maxImages,
    'Invalid preview count',
  );
  ensure(
    Object.keys(files).length === images.length &&
      Object.values(files).reduce((sum, data) => sum + data.length, 0) <=
        maxBundle,
    'Unexpected preview files or bundle size',
  );
  const seen = new Set();

  for (const image of images) {
    fields(image, ['path', 'width', 'height', 'sha256']);
    const name = imagePath(image.path, manifest.vendor, manifest.pname);
    ensure(!seen.has(name) && files[name], 'Duplicate or missing preview');
    seen.add(name);
    const { path: ignored, ...claimed } = image;
    ensure(same(pngInfo(files[name]), claimed), 'Preview content mismatch');
  }

  return manifest;
}

export function expectedPreview(name, item) {
  return {
    package: name,
    vendor: item.vendor,
    pname: item.pname,
    buildKey: item.buildKey,
    previewKey: item.previewKey,
  };
}

export function makeBundle(directory, name, item, source) {
  const files = {};
  let total = 0;

  function visit(relative) {
    for (const entry of fs.readdirSync(path.join(directory, relative))) {
      const local = path.join(relative, entry);
      const file = path.join(directory, local);
      const info = fs.lstatSync(file);
      ensure(!info.isSymbolicLink(), 'Symlink in preview output');

      if (info.isDirectory()) {
        ensure(!relative, 'Unexpected preview directory depth');
        visit(local);
        continue;
      }

      ensure(info.isFile() && info.size <= maxImage, 'Invalid preview file');
      imagePath(local, item.vendor, item.pname);
      total += info.size;
      ensure(total <= maxBundle, 'Preview bundle too large');
      files[local] = fs.readFileSync(file);
      ensure(Object.keys(files).length <= maxImages, 'Too many previews');
    }
  }

  visit('');
  const manifest = {
    schema,
    ...expectedPreview(name, item),
    source,
    images: Object.keys(files)
      .sort()
      .map((file) => ({
        path: file,
        ...pngInfo(files[file]),
      })),
  };
  validateManifest(manifest, files);
  return { manifest, files };
}

export function render(renderer, directory, name, item, source) {
  ensure(
    storePattern.test(renderer) &&
      identifier.test(name) &&
      item.vendor === name.split('.')[0] &&
      typeof item.pname === 'string' &&
      packageName.test(item.pname) &&
      /^[a-z][a-z-]*$/.test(item.sampleKey ?? ''),
    'Invalid rendering inputs',
  );
  const rows = [];

  for (const output of Object.values(item.outputs)) {
    ensure(storePattern.test(output), 'Invalid font output');

    if (fs.existsSync(path.join(output, 'share/fonts'))) {
      rows.push([item.vendor, item.pname, item.sampleKey, output].join('\t'));
    }
  }

  ensure(rows.length > 0, 'Selected package contains no font directory');
  fs.mkdirSync(directory, { recursive: true });
  const manifest = path.join(directory, 'fonts.tsv');
  const images = path.join(directory, 'images');
  fs.writeFileSync(manifest, rows.join('\n') + '\n', { mode: 0o600 });
  command(renderer + '/bin/generate-font-preview-images', [
    '--manifest',
    manifest,
    '--output-dir',
    images,
  ]);
  return makeBundle(images, name, item, source);
}

export function unzip(data) {
  ensure(data.length >= 22 && data.length <= maxData, 'Invalid ZIP size');
  let end = data.length - 22;

  while (end >= Math.max(0, data.length - 65557)) {
    if (data.readUInt32LE(end) === 0x06054b50) {
      break;
    }

    end -= 1;
  }

  ensure(
    end >= 0 && data.readUInt32LE(end) === 0x06054b50,
    'Missing ZIP directory',
  );
  const count = data.readUInt16LE(end + 10);
  const directorySize = data.readUInt32LE(end + 12);
  let cursor = data.readUInt32LE(end + 16);
  ensure(
    data.readUInt16LE(end + 4) === 0 &&
      data.readUInt16LE(end + 6) === 0 &&
      data.readUInt16LE(end + 8) === count &&
      count <= 10000 &&
      end + 22 + data.readUInt16LE(end + 20) === data.length &&
      cursor + directorySize === end,
    'Unsupported or inconsistent ZIP directory',
  );
  const files = {};
  const seen = new Set();
  const spans = [];
  let total = 0;

  for (let index = 0; index < count; index += 1) {
    ensure(
      cursor + 46 <= end && data.readUInt32LE(cursor) === 0x02014b50,
      'Invalid ZIP directory entry',
    );
    const flags = data.readUInt16LE(cursor + 8);
    const method = data.readUInt16LE(cursor + 10);
    const checksum = data.readUInt32LE(cursor + 16);
    const compressedSize = data.readUInt32LE(cursor + 20);
    const size = data.readUInt32LE(cursor + 24);
    const nameSize = data.readUInt16LE(cursor + 28);
    const extraSize = data.readUInt16LE(cursor + 30);
    const commentSize = data.readUInt16LE(cursor + 32);
    const mode = data.readUInt32LE(cursor + 38) >>> 16;
    const offset = data.readUInt32LE(cursor + 42);
    const next = cursor + 46 + nameSize + extraSize + commentSize;
    ensure(next <= end, 'Truncated ZIP directory entry');
    const nameBytes = data.subarray(cursor + 46, cursor + 46 + nameSize);
    const name = new TextDecoder('utf-8', { fatal: true }).decode(nameBytes);
    const directory = name.endsWith('/');
    safePath(directory ? name.slice(0, -1) : name);
    ensure(
      !seen.has(name) &&
        !(flags & 1) &&
        [0, 8].includes(method) &&
        [0, 0o100000, 0o040000].includes(mode & 0o170000) &&
        (flags & 0x800 || nameBytes.every((byte) => byte < 128)) &&
        data.readUInt16LE(cursor + 34) === 0,
      'Unsafe or unsupported ZIP entry',
    );
    seen.add(name);
    const limit = name.endsWith('.png') ? maxImage : 8 * 1024 * 1024;
    total += size;
    ensure(size <= limit && total <= maxData, 'ZIP expansion exceeds limit');
    ensure(
      offset + 30 <= cursor &&
        data.readUInt32LE(offset) === 0x04034b50 &&
        data.readUInt16LE(offset + 6) === flags &&
        data.readUInt16LE(offset + 8) === method,
      'Invalid ZIP local header',
    );
    const localName = data.readUInt16LE(offset + 26);
    const start = offset + 30 + localName + data.readUInt16LE(offset + 28);
    ensure(
      start + compressedSize <= end - directorySize &&
        nameBytes.equals(data.subarray(offset + 30, offset + 30 + localName)),
      'ZIP filename or content bounds differ',
    );
    ensure(
      spans.every(
        ([first, last]) => offset >= last || start + compressedSize <= first,
      ),
      'Overlapping ZIP entries',
    );
    spans.push([offset, start + compressedSize]);
    const payload = data.subarray(start, start + compressedSize);
    let decoded = payload;

    if (method === 8) {
      const inflated = inflateRawSync(payload, {
        maxOutputLength: size + 1,
        info: true,
      });
      ensure(
        inflated.engine.bytesWritten === payload.length,
        'Trailing ZIP compression stream',
      );
      decoded = inflated.buffer;
    }

    ensure(
      decoded.length === size && crc32(decoded) === checksum,
      'ZIP size or checksum mismatch',
    );

    if (directory) {
      ensure(size === 0, 'Nonempty ZIP directory');
    } else {
      files[name] = decoded;
    }

    cursor = next;
  }

  ensure(cursor === end, 'Unexpected ZIP directory data');
  return files;
}

export function validatePlan(value) {
  fields(value, [
    'schema',
    'policy',
    'repository',
    'pr',
    'headRepository',
    'context',
    'controller',
    'packages',
    'tasks',
    'shards',
    'reused',
  ]);
  ensure(
    value.schema === schema &&
      value.policy === policy &&
      value.repository === repository &&
      positive(value.pr) &&
      /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(value.headRepository) &&
      fingerprint.test(value.controller),
    'Invalid plan identity',
  );
  validateContext(value.context);
  ensure(
    value.packages &&
      typeof value.packages === 'object' &&
      !Array.isArray(value.packages) &&
      Object.keys(value.packages).length <= 5000,
    'Invalid package plan',
  );

  for (const [name, item] of Object.entries(value.packages)) {
    fields(item, [
      'vendor',
      'pname',
      'buildKey',
      'previewKey',
      'cacheable',
      'preview',
      'affected',
    ]);
    ensure(
      identifier.test(name) &&
        item.vendor === name.split('.')[0] &&
        typeof item.pname === 'string' &&
        packageName.test(item.pname) &&
        fingerprint.test(item.buildKey) &&
        fingerprint.test(item.previewKey) &&
        ['cacheable', 'preview', 'affected'].every(
          (key) => typeof item[key] === 'boolean',
        ),
      'Invalid package metadata',
    );
  }

  const tasks = value.tasks;
  ensure(
    Array.isArray(tasks) &&
      new Set(tasks).size === tasks.length &&
      tasks.every((name) => Object.hasOwn(value.packages, name)),
    'Invalid task selection',
  );
  ensure(
    Array.isArray(value.shards) && value.shards.length <= 256,
    'Invalid build matrix',
  );
  const scheduled = [];

  for (const [index, shard] of value.shards.entries()) {
    fields(shard, ['id', 'cacheable', 'tasks']);
    ensure(
      shard.id === index &&
        typeof shard.cacheable === 'boolean' &&
        Array.isArray(shard.tasks) &&
        shard.tasks.length > 0,
      'Invalid shard',
    );

    for (const name of shard.tasks) {
      ensure(
        tasks.includes(name) &&
          shard.cacheable === value.packages[name].cacheable,
        'Mixed cache policy in shard',
      );
      scheduled.push(name);
    }
  }

  ensure(same(scheduled.sort(), [...tasks].sort()), 'Shard task mismatch');
  const reused = value.reused;
  ensure(
    Array.isArray(reused) &&
      new Set(reused).size === reused.length &&
      reused.every((name) => !tasks.includes(name)) &&
      same([...tasks, ...reused].sort(), Object.keys(value.packages).sort()),
    'Missing or duplicate package evidence',
  );
  return value;
}

export function validateReceipts(value, plan, shard) {
  fields(value, ['schema', 'context', 'controller', 'shard', 'packages']);
  ensure(
    value.schema === schema &&
      same(value.context, plan.context) &&
      value.controller === plan.controller &&
      value.shard === shard.id,
    'Receipt run mismatch',
  );

  for (const [name, item] of Object.entries(value.packages)) {
    fields(item, [
      'buildKey',
      'previewKey',
      'buildSucceeded',
      'previewGenerated',
    ]);
    ensure(
      shard.tasks.includes(name) &&
        ['buildKey', 'previewKey'].every(
          (key) => item[key] === plan.packages[name][key],
        ) &&
        typeof item.buildSucceeded === 'boolean' &&
        typeof item.previewGenerated === 'boolean' &&
        (!item.previewGenerated || item.buildSucceeded),
      'Invalid package receipt',
    );
  }

  return value;
}

export function validatePreviews(files, plan, receipts) {
  const bundles = {};
  const expectedFiles = new Set();

  for (const [name, receipt] of Object.entries(receipts)) {
    if (!receipt.previewGenerated) {
      continue;
    }

    const prefix = name + '/';
    const manifestPath = prefix + 'manifest.json';
    ensure(files[manifestPath], 'Missing preview manifest');
    const manifest = parseJson(files[manifestPath]);
    const images = Object.fromEntries(
      Object.entries(files)
        .filter(([file]) => file.startsWith(prefix) && file !== manifestPath)
        .map(([file, data]) => [file.slice(prefix.length), data]),
    );
    const item = plan.packages[name];
    ensure(item.preview, 'Unexpected preview generation');
    validateManifest(manifest, images, {
      ...expectedPreview(name, item),
      source: { kind: 'pr', ...plan.context },
    });
    bundles[name] = { manifest, files: images };
    expectedFiles.add(manifestPath);
    Object.keys(images).forEach((file) => expectedFiles.add(prefix + file));
  }

  ensure(
    same([...expectedFiles].sort(), Object.keys(files).sort()),
    'Unexpected files in preview artifact',
  );
  return bundles;
}
