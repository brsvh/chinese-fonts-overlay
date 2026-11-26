import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { command, ensure, parseJson } from './common.mjs';

const endpoint = 'https://s3.bingshan.org';

export class GarageBucket {
  constructor(bucket, { accessKeyId, secretAccessKey }) {
    ensure(accessKeyId && secretAccessKey, 'Missing Garage credentials');

    this.bucket = bucket;
    this.directory = fs.mkdtempSync(path.join(os.tmpdir(), 'garage-'));
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
        this.bucket,
        ...args,
        '--output',
        'json',
      ],
      { env: this.env },
    );

    return result ? parseJson(result) : {};
  }
}
