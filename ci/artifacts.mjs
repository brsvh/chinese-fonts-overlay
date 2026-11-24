import { crc32, inflateRawSync } from 'node:zlib';
import { ensure, maxData } from './common.mjs';
import { safePath } from './records.mjs';

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

    const limit = 8 * 1024 * 1024;
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
