{
  pkgs,
  ...
}:
let
  common = pkgs.writeText "font-ci-common.mjs" (
    import ./common.nix {
      evaluator = "${./.}/default.nix";
    }
  );

  previews = pkgs.writeText "font-ci-previews.mjs" (
    import ./previews.nix {
      inherit common;
    }
  );

  github = pkgs.writeText "font-ci-github.mjs" (
    import ./github.nix {
      inherit common previews;
    }
  );

  main = pkgs.writeText "font-ci-main.mjs" (
    import ./main.nix {
      inherit common github previews;
    }
  );

  actions = pkgs.writeText "font-ci-actions.mjs" (
    import ./actions.nix {
      inherit common github previews;
    }
  );

  tests = pkgs.writeText "font-ci-tests.mjs" ''
    import assert from 'node:assert/strict';
    import fs from 'node:fs';
    import os from 'node:os';
    import path from 'node:path';
    import childProcess from 'node:child_process';
    import { syncBuiltinESMExports } from 'node:module';
    import { test } from 'node:test';
    import { deflateRawSync, deflateSync } from 'node:zlib';
    import * as ci from '${common}';
    import * as preview from '${previews}';
    import * as github from '${github}';
    import * as main from '${main}';
    import * as actions from '${actions}';

    function store(name) {
      return '/nix/store/' + '0'.repeat(32) + '-' + name;
    }

    function font(name, options = {}) {
      const source = options.source ?? name;
      return {
        vendor: 'vendor',
        pname: name,
        attrPath: ['vendorPackages', name],
        drvPath: store(name + '.drv'),
        outputs: { out: store(name) },
        sources: [{
          drvPath: store(source + '-source.drv'),
          path: store(source + '.zip'),
        }],
        windows: options.windows ?? false,
        redistributable: options.redistributable ?? true,
        ...options,
      };
    }

    function evaluated(...fonts) {
      const packages = {};
      const graph = {};

      for (const item of fonts) {
        packages['vendor.' + item.pname] = item;
        const dependencies = new Set([item.sources[0].drvPath]);

        if (item.dependency) {
          dependencies.add(store(item.dependency + '.drv'));
        }

        graph[item.drvPath] = {
          drvs: dependencies,
          paths: new Set(Object.values(item.outputs)),
        };
        graph[item.sources[0].drvPath] = {
          drvs: new Set(),
          paths: new Set([item.sources[0].path]),
        };
      }

      return ci.previewKeys(ci.applyPolicy({
        schema: ci.schema, system: ci.system, packages,
      }, graph), {
        rendererDrvPath: store('renderer.drv'),
        samples: {
          vendor: Object.fromEntries(fonts.map(item => [
            item.pname, 'english',
          ])),
        },
      });
    }

    function receipt(item, overrides = {}) {
      return {
        policy: ci.policy,
        buildKey: item.buildKey,
        previewKey: item.previewKey,
        buildSucceeded: true,
        previewPublished: true,
        ...overrides,
      };
    }

    test('JSON rejects ambiguous keys and excessive depth', () => {
      for (const value of [
        '{"a":1,"a":2}',
        '{"a":[{"b":1,"b":2}]}',
        '{"a":1,"\\u0061":2}',
        '{"__proto__":{}}',
        '{"constructor":1}',
        '['.repeat(65) + '0' + ']'.repeat(65),
      ]) {
        assert.throws(() => ci.parseJson(value));
      }

      assert.deepEqual(ci.parseJson('{"a":[{"b":1},{"b":2}]}'), {
        a: [{ b: 1 }, { b: 2 }],
      });
    });

    test('unfree can be published when redistribution is permitted', () => {
      const current = evaluated(font('unfree', { free: false }));
      assert.equal(current.packages['vendor.unfree'].cacheable, true);
      const selected = ci.plan(evaluated(), current, {}, { main: true });
      assert.equal(selected.tasks.length, 1);
    });

    test('missing and false redistribution metadata forbid caching', () => {
      const unknown = font('unknown');
      delete unknown.redistributable;
      const current = evaluated(
        unknown, font('restricted', { redistributable: false }),
      );
      assert.equal(ci.plan(evaluated(), current).tasks.length, 2);
      const selected = ci.plan(evaluated(), current, {}, { main: true });
      assert.equal(selected.tasks.length, 0);
      assert.ok(Object.values(current.packages)
        .every(item => !item.cacheable));
    });

    test('Windows exclusion follows multiple dependency levels', () => {
      const current = evaluated(
        font('windows', { windows: true }),
        font('bridge', { dependency: 'windows' }),
        font('indirect', { dependency: 'bridge' }),
      );
      assert.ok(Object.values(current.packages)
        .every(item => item.windows));
      assert.equal(ci.plan(evaluated(), current).tasks.length, 0);
    });

    test('shared restricted sources and aggregates cannot be cached', () => {
      const current = evaluated(
        font('restricted', { redistributable: false, source: 'shared' }),
        font('alias', { source: 'shared' }),
        font('aggregate', { dependency: 'restricted' }),
      );
      assert.ok(Object.values(current.packages)
        .every(item => !item.cacheable));
      assert.equal(ci.plan(evaluated(), current).tasks.length, 3);
    });

    test('removed restrictions persist unless explicitly reclassified', () => {
      const before = evaluated(
        font('a', { redistributable: false }),
        font('deleted', { redistributable: false }),
      );
      const denied = ci.cacheRestrictions(evaluated(font('a')), before);
      assert.ok(!denied.includes(store('a')));
      assert.ok(!denied.includes(store('a.zip')));
      assert.ok(denied.includes(store('deleted')));
      assert.ok(denied.includes(store('deleted.zip')));
    });

    test('missing derivation dependencies fail closed', () => {
      assert.throws(() => evaluated(font('a', { dependency: 'missing' })),
        /Incomplete derivation graph/);
    });

    test('Nix JSON versions retain fixed outputs and reject ambiguity', () => {
      const root = store('font.drv');
      const output = store('font');
      const legacy = ci.normalizeGraph({
        [root]: {
          inputDrvs: {}, inputSrcs: [], outputs: { out: { path: output } },
        },
      });
      const current = ci.normalizeGraph({
        version: 4,
        derivations: {
          [root.slice('/nix/store/'.length)]: {
            inputs: { drvs: {}, srcs: [] },
            outputs: { out: {} },
            env: { out: output },
          },
        },
      });
      assert.deepEqual(current, legacy);
      assert.throws(() => ci.normalizeGraph({
        [root]: { outputs: { out: {} } },
      }), /unresolved/);
      assert.throws(() => ci.normalizeGraph({
        [root]: {
          inputs: { drvs: { [root]: { dynamicOutputs: { x: {} } } } },
          outputs: { out: { path: output } },
        },
      }), /Dynamic/);
    });

    test('unchanged inputs skip and successful inputs reuse', () => {
      const before = evaluated(font('old'));
      assert.deepEqual(ci.plan(before, before).tasks, []);
      const current = evaluated(font('old'), font('new'));
      const item = current.packages['vendor.new'];
      assert.deepEqual(ci.plan(before, current, {
        'vendor.new': receipt(item),
      }).tasks, []);
      for (const overrides of [{ buildSucceeded: false }, { policy: 0 }]) {
        assert.equal(ci.plan(before, current, {
          'vendor.new': receipt(item, overrides),
        }).tasks.length, 1);
      }
    });

    test('restricted PR previews retry when changed or unpublished', () => {
      const current = evaluated(font('new', { redistributable: false }));
      const item = current.packages['vendor.new'];
      const records = { 'vendor.new': receipt(item) };
      item.previewKey = 'f'.repeat(64);
      const selected = ci.plan(evaluated(), current, records).tasks;
      assert.equal(selected.length, 1);
      assert.equal(selected[0].cacheable, false);
      assert.equal(selected[0].preview, true);
      assert.equal(ci.plan(evaluated(), current, {
        'vendor.new': receipt(item, { previewPublished: false }),
      }).tasks.length, 1);
    });

    test('repair requests are selective and never enable Windows', () => {
      const current = evaluated(
        font('a', { redistributable: false }), font('b'),
        font('windows', { windows: true }),
      );
      const selected = ci.plan(current, current, {}, {
        previewRequests: ['vendor.a', 'vendor.windows'],
      });
      assert.deepEqual(selected.tasks.map(item => item.package), ['vendor.a']);
      assert.throws(() => ci.plan(current, current, {}, {
        previewRequests: ['vendor.missing'],
      }), /Unknown preview/);
      current.packages['vendor.a'].sampleKey = null;
      assert.throws(() => ci.plan(current, current, {}, {
        previewRequests: ['vendor.a'],
      }), /Missing preview sample/);
    });

    test('large matrices keep cache policies separate within 256 jobs', () => {
      const current = evaluated(...Array.from({ length: 600 }, (_, index) =>
        font('font-' + index, { redistributable: index % 2 === 0 })));
      const selected = ci.plan(evaluated(), current);
      assert.ok(selected.shards.length <= 256);
      assert.equal(selected.tasks.length, 600);

      for (const shard of selected.shards) {
        assert.ok(shard.tasks.every(item =>
          item.cacheable === shard.cacheable));
      }
    });

    function chunk(kind, content) {
      const result = Buffer.alloc(content.length + 12);
      result.writeUInt32BE(content.length, 0);
      result.write(kind, 4);
      content.copy(result, 8);
      result.writeUInt32BE(preview.crc32(result.subarray(4, -4)),
        result.length - 4);
      return result;
    }

    function png(options = {}) {
      const { width = 20, height = 4, blank = false, filter = 0 } = options;
      const header = Buffer.alloc(13);
      header.writeUInt32BE(width, 0);
      header.writeUInt32BE(height, 4);
      header[8] = 8;
      header[9] = 2;
      const stride = width * 3;
      const raw = Buffer.alloc((stride + 1) * height);
      let previous = Buffer.alloc(stride);

      for (let row = 0; row < height; row += 1) {
        const pixels = Buffer.alloc(stride, 255);

        if (!blank && row === 0) {
          pixels.fill(0, 0, 3);
        }

        raw[row * (stride + 1)] = filter;

        for (let column = 0; column < stride; column += 1) {
          const left = column >= 3 ? pixels[column - 3] : 0;
          const up = previous[column];
          const diagonal = column >= 3 ? previous[column - 3] : 0;
          const prediction = left + up - diagonal;
          const distances = [left, up, diagonal]
            .map(value => Math.abs(prediction - value));
          const predictors = [
            0, left, up, Math.floor((left + up) / 2),
            [left, up, diagonal][distances.indexOf(Math.min(...distances))],
          ];
          raw[row * (stride + 1) + column + 1] =
            (pixels[column] - predictors[filter]) & 255;
        }

        previous = pixels;
      }

      return Buffer.concat([
        Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
        chunk('IHDR', header), chunk('IDAT', deflateSync(raw)),
        chunk('IEND', Buffer.alloc(0)),
      ]);
    }

    test('PNG accepts all five scanline filters and verifies CRC', () => {
      assert.equal(preview.crc32(Buffer.from('123456789')), 0xcbf43926);

      for (let filter = 0; filter <= 4; filter += 1) {
        const result = preview.pngInfo(png({ filter }));
        assert.equal(result.width, 20);
        assert.equal(result.height, 4);
      }

      const corrupted = png();
      corrupted[40] ^= 1;
      assert.throws(() => preview.pngInfo(corrupted), /checksum/);
    });

    test('PNG rejects blank, vertical, oversized and trailing data', () => {
      for (const data of [
        png({ blank: true }), png({ width: 3, height: 4 }),
        png({ width: 4097 }), png().subarray(0, -1),
        Buffer.concat([png(), Buffer.from('font bytes')]),
      ]) {
        assert.throws(() => preview.pngInfo(data));
      }
    });

    function archive(entries, method = 8) {
      const content = [];
      const directory = [];
      let offset = 0;

      for (const [name, data, mode = 0o100644] of entries) {
        const nameBytes = Buffer.from(name);
        const compressed = method === 8 ? deflateRawSync(data) : data;
        const header = Buffer.alloc(30);
        header.writeUInt32LE(0x04034b50, 0);
        header.writeUInt16LE(20, 4);
        header.writeUInt16LE(0x800, 6);
        header.writeUInt16LE(method, 8);
        header.writeUInt32LE(preview.crc32(data), 14);
        header.writeUInt32LE(compressed.length, 18);
        header.writeUInt32LE(data.length, 22);
        header.writeUInt16LE(nameBytes.length, 26);
        const record = Buffer.alloc(46);
        record.writeUInt32LE(0x02014b50, 0);
        record.writeUInt16LE(0x0314, 4);
        header.copy(record, 6, 4, 30);
        record.writeUInt32LE((mode << 16) >>> 0, 38);
        record.writeUInt32LE(offset, 42);
        content.push(header, nameBytes, compressed);
        directory.push(record, nameBytes);
        offset += header.length + nameBytes.length + compressed.length;
      }

      const records = Buffer.concat(directory);
      const end = Buffer.alloc(22);
      end.writeUInt32LE(0x06054b50, 0);
      end.writeUInt16LE(entries.length, 8);
      end.writeUInt16LE(entries.length, 10);
      end.writeUInt32LE(records.length, 12);
      end.writeUInt32LE(offset, 16);
      return Buffer.concat([...content, records, end]);
    }

    test('ZIP accepts stored and deflated UTF-8 without extracting', () => {
      for (const method of [0, 8]) {
        const file = 'vendor/font+字體.png';
        const files = preview.unzip(archive([[file, png()]], method));
        assert.deepEqual(files[file], png());
      }
    });

    test('ZIP rejects traversal, duplicates, symlinks and corruption', () => {
      for (const entries of [
        [['../font', png()]], [['/font', png()]], [['a//font', png()]],
        [['a/./font', png()]], [['a\\font', png()]],
        [['font', png(), 0o120777]],
        [['font', png()], ['font', png()]],
      ]) {
        assert.throws(() => preview.unzip(archive(entries)));
      }

      const corrupted = archive([['font.png', png()]], 0);
      corrupted[40] ^= 1;
      assert.throws(() => preview.unzip(corrupted));
      assert.throws(() => preview.unzip(Buffer.concat([
        archive([]), Buffer.from('hidden content'),
      ])));
    });

    test('ZIP enforces uncompressed limits before accepting data', () => {
      const oversized = Buffer.alloc(preview.maxImage + 1);
      assert.throws(() => preview.unzip(archive([
        ['font.png', oversized],
      ])), /expansion/);
    });

    test('preview provenance separates PR evidence from main rendering', () => {
      const files = { 'vendor/font+Regular.png': png() };
      const manifest = {
        schema: ci.schema,
        package: 'vendor.font', vendor: 'vendor', pname: 'font',
        buildKey: 'a'.repeat(64), previewKey: 'b'.repeat(64),
        source: { kind: 'main', rev: 'c'.repeat(40) },
        images: Object.entries(files).map(([file, data]) => ({
          path: file, ...preview.pngInfo(data),
        })),
      };
      preview.validateManifest(manifest, files, { source: manifest.source });
      assert.throws(() => preview.validateManifest(manifest, files, {
        source: {
          kind: 'pr', headSha: 'c'.repeat(40), mergeSha: 'd'.repeat(40),
          runId: 1, runAttempt: 1,
        },
      }), /context mismatch/);
      assert.throws(() => preview.validateManifest({
        ...manifest, pname: null,
      }, files));
      assert.throws(() => preview.validateManifest(manifest, {
        ...files, 'font.ttf': Buffer.from('restricted font'),
      }));
    });
    function publicationFixture(cacheable = true) {
      const context = {
        headSha: 'c'.repeat(40), mergeSha: 'd'.repeat(40),
        runId: 12, runAttempt: 2,
      };
      const metadata = {
        vendor: 'vendor', pname: 'font',
        buildKey: 'a'.repeat(64), previewKey: 'b'.repeat(64),
        preview: true, affected: true, cacheable,
      };
      const files = { 'vendor/font+Regular.png': png() };
      const manifest = {
        schema: ci.schema,
        ...preview.expectedPreview('vendor.font', metadata),
        source: { kind: 'pr', ...context },
        images: Object.entries(files).map(([file, data]) => ({
          path: file, ...preview.pngInfo(data),
        })),
      };
      const plan = preview.validatePlan({
        schema: ci.schema, policy: ci.policy, repository: ci.repository,
        pr: 9, headRepository: 'contributor/fonts', context,
        controller: 'e'.repeat(64),
        packages: { 'vendor.font': metadata },
        tasks: ['vendor.font'], reused: [],
        shards: [{ id: 0, cacheable, tasks: ['vendor.font'] }],
      });
      const run = {
        id: context.runId, run_attempt: context.runAttempt,
        head_sha: context.headSha,
        repository: { full_name: ci.repository },
        head_repository: { full_name: plan.headRepository },
        event: 'pull_request', workflow_id: 7,
        path: preview.workflowPath, pull_requests: [{ number: 9 }],
        status: 'completed', conclusion: 'success',
      };
      const pull = {
        number: 9, state: 'open', merged: false,
        head: {
          sha: run.head_sha, repo: { full_name: plan.headRepository },
        },
        base: { ref: 'main', repo: { full_name: ci.repository } },
      };
      const records = {
        'vendor.font': {
          buildKey: metadata.buildKey, previewKey: metadata.previewKey,
          buildSucceeded: true, previewGenerated: true,
        },
      };
      const bundles = { 'vendor.font': { manifest, files } };
      return { context, metadata, files, manifest, plan, run, pull,
        records, bundles };
    }

    class MemoryGitHub extends github.GitHub {
      constructor(fixture) {
        super('test-token', true);
        Object.assign(this, fixture);
        this.entries = {};
        this.blobs = new Map();
        this.calls = [];
        this.revision = 'f'.repeat(40);
      }

      async request(path, options = {}) {
        this.calls.push([path, options]);

        if (path === '/actions/runs/' + this.run.id) {
          return structuredClone(this.run);
        }

        if (path === '/pulls/' + this.pull.number) {
          return structuredClone(this.pull);
        }

        if (path === '/actions/workflows/build.yml') {
          return { id: 7, path: preview.workflowPath };
        }

        if (path.startsWith('/git/blobs/')) {
          const data = this.blobs.get(path.split('/').at(-1));
          return {
            encoding: 'base64', size: data.length,
            content: data.toString('base64'),
          };
        }

        throw new Error('Unexpected API call: ' + path);
      }

      async branch() {
        return { parent: this.revision, tree: '1'.repeat(40),
          entries: this.entries };
      }

      async updateImages(branch, message, prepare, guard) {
        assert.equal(branch, preview.temporaryBranch);
        await guard();
        const changes = await prepare(this.entries);

        for (const [file, data] of Object.entries(changes)) {
          assert.notEqual(data, null, 'PR images must remain accessible');
          const sha = github.blobSha(data);
          this.blobs.set(sha, data);
          this.entries[file] = {
            path: file, sha, mode: '100644', type: 'blob', size: data.length,
          };
        }

        await guard();
        return this.revision;
      }
    }

    test('publisher authenticates workflow, fork and PR head', async () => {
      const fixture = publicationFixture();
      const api = new MemoryGitHub(fixture);
      const event = { workflow_run: structuredClone(fixture.run) };
      assert.equal((await github.resolveRun(api, event)).pull.number, 9);
      api.run.workflow_id = 99;
      await assert.rejects(github.resolveRun(api, event), /workflow/);
      api.run.workflow_id = 7;
      api.pull.head.sha = '0'.repeat(40);
      await assert.rejects(github.resolveRun(api, event), github.Superseded);
      api.pull.head.sha = api.run.head_sha;
      api.run.run_attempt += 1;
      await assert.rejects(github.resolveRun(api, event), github.Superseded);
    });

    test('merged PR images remain publishable with no promotion cleanup',
      async () => {
        const api = new MemoryGitHub(publicationFixture());
        api.pull.merged = true;
        api.pull.state = 'closed';
        await github.currentGuard(api, api.run, api.pull);
        assert.equal(api.calls.length, 2);
        api.pull.merged = false;
        await assert.rejects(
          github.currentGuard(api, api.run, api.pull), github.Superseded,
        );
      });

    test('publication binds receipts to blobs and reuses verified images',
      async () => {
        const fixture = publicationFixture(false);
        const api = new MemoryGitHub(fixture);
        const { run, pull, plan, records, bundles } = fixture;
        const first = await github.publish(api, run, pull, plan,
          records, bundles);
        assert.equal(first.selected['vendor.font'].cacheable, false);
        const original = structuredClone(api.entries);
        const second = await github.publish(api, run, pull, plan, {}, {});
        assert.deepEqual(second, first);
        assert.deepEqual(api.entries, original);

        const state = await github.readState(api, 9, plan.headRepository,
          plan.controller);
        assert.equal(state.receipts['vendor.font'].previewPublished, true);
        const image = Object.keys(api.entries).find(file =>
          file.endsWith('.png'));
        api.entries[image].sha = '0'.repeat(40);
        const damaged = await github.readState(api, 9, plan.headRepository,
          plan.controller);
        assert.equal(damaged.receipts['vendor.font'].previewPublished, false);
        const retry = ci.plan(evaluated(), evaluated(font('font')), {
          'vendor.font': damaged.receipts['vendor.font'],
        });
        assert.equal(retry.tasks.length, 1);
      });

    test('stale publishers cannot overwrite newer PR state', async () => {
      const fixture = publicationFixture();
      const api = new MemoryGitHub(fixture);
      const { run, pull, plan, records, bundles } = fixture;
      await github.publish(api, run, pull, plan, records, bundles);
      const stale = { ...run, id: run.id - 1 };
      api.run = stale;
      await assert.rejects(github.publish(api, stale, pull, plan,
        records, bundles), github.Superseded);
    });

    test('comments use immutable PR images and explicit formal eligibility',
      async () => {
        for (const cacheable of [true, false]) {
          const fixture = publicationFixture(cacheable);
          const api = new MemoryGitHub(fixture);
          const { run, pull, plan, records, bundles } = fixture;
          const { revision, selected } = await github.publish(api, run,
            pull, plan, records, bundles);
          const body = github.comment(run, pull, '已验证', revision, selected);
          assert.ok(body.includes('/' + revision + '/prs/9/'));
          assert.equal(body.includes('预计正式路径'), cacheable);
          assert.equal(body.includes('仅 PR 预览'), !cacheable);
          assert.ok(!body.includes('/font-preview-prs/'));
        }
      });

    test('branch updates retry races without force or losing other files',
      async () => {
        const api = new github.GitHub('test-token', true);
        const data = Buffer.from('image');
        const calls = [];
        let reads = 0;
        let guards = 0;
        api.branch = async () => {
          reads += 1;
          return { parent: String(reads).repeat(40),
            tree: String(reads + 2).repeat(40),
            entries: { 'other/image.png': { sha: '0'.repeat(40) } } };
        };
        api.request = async (path, options) => {
          calls.push([path, options.body]);

          if (path === '/git/blobs') {
            return { sha: github.blobSha(data) };
          }

          if (path.startsWith('/git/refs/')) {
            assert.equal(options.body.force, false);

            if (reads === 1) {
              throw new ci.ApiError(422);
            }
          }

          return { sha: '9'.repeat(40) };
        };
        await api.updateImages(preview.formalBranch, 'Render preview',
          entries => {
            assert.ok(entries['other/image.png']);
            return { 'vendor/font.png': data };
          }, async () => { guards += 1; });
        assert.equal(reads, 2);
        assert.equal(guards, 4);
        const trees = calls.filter(([path]) => path === '/git/trees');
        assert.deepEqual(trees.map(([, body]) => body.base_tree), [
          '3'.repeat(40), '4'.repeat(40),
        ]);
        assert.ok(trees.every(([, body]) =>
          body.tree.length === 1 && body.tree[0].path === 'vendor/font.png'));
      });

    test('GitHub read-only client and branch whitelist reject writes',
      async () => {
        const api = new github.GitHub('test-token');
        await assert.rejects(api.request('/git/refs', {
          method: 'POST', body: {},
        }), /Read-only/);
        await assert.rejects(api.branch('main'), /image branch/);
        await assert.rejects(api.request('//other.invalid/path'), /path/);
        await assert.rejects(api.updateImages(preview.formalBranch,
          'message', () => ({})), /disabled/);
      });

    test('artifact redirects never forward the API token', async t => {
      const calls = [];
      t.mock.method(globalThis, 'fetch', async (url, options) => {
        calls.push([String(url), options]);

        if (calls.length === 1) {
          return new Response(null, {
            status: 302, headers: { location: 'https://storage.test/blob' },
          });
        }

        return new Response(Buffer.from('bounded artifact'));
      });
      const api = new github.GitHub('private-token');
      assert.equal((await api.artifact(123)).toString(), 'bounded artifact');
      assert.equal(calls[0][1].headers.authorization, 'Bearer private-token');
      assert.equal(calls[1][1].headers.authorization, undefined);
      assert.equal(calls[0][1].redirect, 'manual');
      assert.equal(calls[1][1].redirect, 'manual');
      t.mock.restoreAll();
      t.mock.method(globalThis, 'fetch', async () => new Response(null, {
        status: 302, headers: { location: 'http://storage.test/blob' },
      }));
      await assert.rejects(api.artifact(123), /HTTPS/);
    });

    test('artifact metadata rejects ambiguity, expiry and false digest',
      async () => {
        const item = { id: 1, name: 'plan', expired: false,
          size_in_bytes: 10 };
        const api = { artifact: async () => archive([]) };
        await assert.rejects(github.artifactFiles(api, [item, item], 'plan'));
        await assert.rejects(github.artifactFiles(api,
          [{ ...item, expired: true }], 'plan'));
        await assert.rejects(github.artifactFiles(api,
          [{ ...item, digest: 'sha256:' + '0'.repeat(64) }], 'plan'));
        assert.deepEqual(await github.artifactFiles(api, [], 'plan', true), {});
      });
    class MemoryState {
      constructor() {
        this.values = new Map();
      }

      async get(name) {
        return structuredClone(this.values.get(name) ?? null);
      }

      async put(name, value) {
        this.values.set(name, structuredClone(value));
      }
    }

    function mainFixture() {
      const fixture = publicationFixture();
      const api = new MemoryGitHub(fixture);
      const state = new MemoryState();
      const current = evaluated(font('font'));
      const metadata = {
        rev: 'c'.repeat(40), bootstrapRev: 'b'.repeat(40),
        cache: { url: 'https://cache.test', publicKey: 'key' },
        previewRequests: {},
      };
      const requests = [];
      api.request = async (path, options = {}) => {
        requests.push([path, options]);

        if (path === '/git/ref/heads/main') {
          return { object: { sha: metadata.rev } };
        }

        if (path.startsWith('/compare/')) {
          return { status: 'ahead' };
        }

        if (path.startsWith('/git/ref/tags/')) {
          return null;
        }

        if (path === '/git/refs') {
          const planned = await state.get('main-plan');
          assert.ok(Object.values(planned.requests)
            .some(item => options.body.ref === 'refs/tags/' + item.tag));
          return {};
        }

        throw new Error('Unexpected main API call: ' + path);
      };
      return { api, state, current, metadata, requests };
    }

    test('main bootstrap and unrelated commits schedule no full rebuild',
      async () => {
        const { api, state, current, metadata, requests } = mainFixture();
        const first = await main.schedule(api, state, metadata,
          current, current);
        assert.deepEqual(first.pending, { cache: [], preview: [] });
        const second = await main.schedule(api, state, metadata,
          current, evaluated());
        assert.deepEqual(second.requests, {});
        assert.ok(!requests.some(([path]) => path === '/git/refs'));
      });

    test('main retains separate pending work and dispatches only eligible',
      async () => {
        const fixture = mainFixture();
        const { api, state, metadata } = fixture;
        const current = evaluated(
          font('font'), font('private', { redistributable: false }),
          font('windows', { windows: true }),
          font('indirect', { dependency: 'windows' }),
        );
        const first = await main.schedule(api, state, metadata, current,
          evaluated());
        assert.deepEqual(first.pending, {
          cache: ['vendor.font'], preview: ['vendor.font'],
        });
        assert.equal(Object.keys(first.requests).length, 2);
        const second = await main.schedule(api, state, metadata,
          current, evaluated());
        assert.deepEqual(second.pending, first.pending);
        assert.notEqual(second.requests['cache:vendor.font'].tag,
          first.requests['cache:vendor.font'].tag);
      });

    test('main cache success cannot mask a missing formal preview', async t => {
      const { api, state, current, metadata } = mainFixture();
      await main.schedule(api, state, metadata, current, evaluated());
      await state.put(main.publicationKey('cache', 'vendor.font'), {
        schema: ci.schema, policy: ci.policy, package: 'vendor.font',
        buildKey: current.packages['vendor.font'].buildKey,
        cache: metadata.cache,
      });
      t.mock.method(globalThis, 'fetch', async (url, options) => {
        assert.equal(options.method, 'HEAD');
        return new Response(null, { status: 200 });
      });
      const retry = await main.schedule(api, state, metadata,
        current, evaluated());
      assert.deepEqual(retry.pending, { cache: [], preview: ['vendor.font'] });
      assert.deepEqual(Object.keys(retry.requests), ['preview:vendor.font']);
    });

    test('repair requests select images without rebuilding unrelated fonts',
      async () => {
        const { api, state, current, metadata } = mainFixture();
        metadata.previewRequests = { 'vendor.font': 'repair-1' };
        const result = await main.schedule(api, state, metadata,
          current, current);
        assert.deepEqual(result.pending, {
          cache: [], preview: ['vendor.font'],
        });
        assert.equal(result.requests['preview:vendor.font'].repair, 'repair-1');
      });

    test('main drops deleted and newly restricted pending work', async () => {
      const { api, state, current, metadata } = mainFixture();
      await main.schedule(api, state, metadata, current, evaluated());
      const restricted = evaluated(font('font', { redistributable: false }));
      const result = await main.schedule(api, state, metadata,
        restricted, evaluated());
      assert.deepEqual(result.pending, { cache: [], preview: [] });
      assert.deepEqual(result.previewTargets, []);
      assert.deepEqual((await main.schedule(api, state, metadata,
        evaluated(), evaluated())).requests, {});
    });

    test('main verifies request identity before publication', async () => {
      const { api, state, current, metadata } = mainFixture();
      const observed = await main.schedule(api, state, metadata,
        current, evaluated());
      const selected = observed.requests['preview:vendor.font'];
      const task = { ...metadata, name: selected.name, mode: selected.kind,
        tag: selected.tag };
      assert.equal((await main.verifyRequest(api, state, task, current))
        .item.pname, 'font');
      await assert.rejects(main.verifyRequest(api, state,
        { ...task, tag: task.tag + '0' }, current), github.Superseded);
      assert.deepEqual(main.triggerInfo(selected.tag), {
        kind: 'preview', name: 'vendor.font', rev: metadata.rev,
      });
      assert.throws(() => main.triggerInfo('refs/heads/main'));
    });

    test('formal publication uses main renders and scoped ownership only',
      async () => {
        const fixture = publicationFixture();
        const { manifest, files } = fixture;
        manifest.source = { kind: 'main', rev: 'd'.repeat(40) };
        const old = { ...manifest, images: [{
          path: 'vendor/font+Old.png', ...preview.pngInfo(png()),
        }] };
        const api = new MemoryGitHub(fixture);
        const owned = ci.bytes(old);
        const digest = github.blobSha(owned);
        api.blobs.set(digest, owned);
        api.entries = {
          [main.manifestPath('vendor.font')]: {
            sha: digest, mode: '100644', type: 'blob', size: owned.length,
          },
          'vendor/font+Old.png': {},
          'vendor/font+Legacy.png': {},
          'other/untouched.png': {},
        };
        let changes;
        api.updateImages = async (branch, message, prepare, guard) => {
          assert.equal(branch, preview.formalBranch);
          await guard();
          changes = await prepare(api.entries);
          return 'f'.repeat(40);
        };
        await main.writeFormal(api, { 'vendor.font': { manifest, files } },
          [], async () => {});
        assert.equal(changes['vendor/font+Old.png'], null);
        assert.equal(changes['vendor/font+Legacy.png'], undefined);
        assert.equal(changes['other/untouched.png'], undefined);
        assert.deepEqual(changes['vendor/font+Regular.png'], png());
        manifest.source = { kind: 'pr', ...fixture.context };
        await assert.rejects(main.writeFormal(api,
          { 'vendor.font': { manifest, files } }, [], async () => {}),
        /main/);
      });

    test('main rejects moved triggers and stale heads without deleting refs',
      async () => {
        const { api, metadata } = mainFixture();
        const tag = 'ci/package/cache/vendor.font/' + metadata.rev + '/' +
          '0'.repeat(36);
        api.request = async path => {
          assert.ok(!path.startsWith('/git/refs/'));
          return { object: { sha: '0'.repeat(40) } };
        };
        await assert.rejects(main.deleteTrigger(api, tag, metadata.rev),
          /moved/);
        await assert.rejects(main.current(api, metadata.rev),
          github.Superseded);
      });

    test('embedded JavaScript and entry points remain bounded and parseable',
      () => {
        for (const file of fs.readdirSync('${./.}')) {
          if (!file.endsWith('.nix')) {
            continue;
          }

          const lines = fs.readFileSync('${./.}/' + file, 'utf8').split('\n');
          let embedded = false;

          for (const [index, line] of lines.entries()) {
            if (line.trim().startsWith('import ') &&
                (line.includes("from '") || line.includes('node:'))) {
              embedded = true;
            }

            if (line.trim() === String.fromCharCode(39, 39) + ';') {
              embedded = false;
            }

            if (embedded) {
              assert.ok([...line].length <= 80,
                file + ':' + (index + 1) + ' exceeds 80 columns');
            }
          }
        }
      });

    test('contracts reject mixed policies and unrelated receipt contexts',
      () => {
        const { plan, records } = publicationFixture();
        const mixed = structuredClone(plan);
        mixed.shards[0].cacheable = false;
        assert.throws(() => preview.validatePlan(mixed));
        const omitted = structuredClone(plan);
        omitted.tasks = [];
        assert.throws(() => preview.validatePlan(omitted));
        const value = {
          schema: ci.schema, context: plan.context,
          controller: plan.controller, shard: 0, packages: records,
        };
        preview.validateReceipts(value, plan, plan.shards[0]);
        assert.throws(() => preview.validateReceipts({
          ...value, context: { ...plan.context, runAttempt: 99 },
        }, plan, plan.shards[0]));
        assert.throws(() => preview.validateReceipts({
          ...value, packages: { ...records, 'vendor.unplanned':
            records['vendor.font'] },
        }, plan, plan.shards[0]));
      });

    test('publisher consumes only bounded verified artifacts for this run',
      async () => {
        const fixture = publicationFixture();
        const { plan, records, manifest, files, run, pull } = fixture;
        const api = new MemoryGitHub(fixture);
        const archives = [
          archive([['plan.json', ci.bytes(plan)]]),
          archive([['receipts.json', ci.bytes({
            schema: ci.schema, context: plan.context,
            controller: plan.controller, shard: 0, packages: records,
          })]]),
          archive([
            ['vendor.font/manifest.json', ci.bytes(manifest)],
            ...Object.entries(files).map(([file, data]) => [
              'vendor.font/' + file, data,
            ]),
          ]),
        ];
        api.pages = async (path, field) => {
          if (field === 'jobs') {
            return [{ name: 'Build fonts / 0', status: 'completed' }];
          }

          return ['font-plan-2', 'font-receipts-2-0', 'font-previews-2-0']
            .map((name, index) => ({
              name, id: index + 1, expired: false,
              size_in_bytes: archives[index].length,
            }));
        };
        api.artifact = async id => archives[id - 1];
        api.request = async path => {
          assert.equal(path, '/git/commits/' + plan.context.mergeSha);
          return { parents: [{ sha: 'b'.repeat(40) }, { sha: run.head_sha }] };
        };
        const valid = await github.consume(api, run, pull);
        assert.deepEqual(valid.records, records);
        assert.deepEqual(valid.bundles, fixture.bundles);
        assert.deepEqual(valid.errors, []);
        archives[2] = archive([['hidden.ttf', Buffer.from('font bytes')]]);
        const bad = await github.consume(api, run, pull);
        assert.equal(bad.errors.length, 1);
        assert.deepEqual(bad.records, {});
        assert.deepEqual(bad.bundles, {});
        await assert.rejects(github.consume(api,
          { ...run, head_sha: '1'.repeat(40) }, pull), /context/);
      });

    test('preview check completes only after the comment succeeds', async t => {
      const fixture = publicationFixture();
      const previous = process.cwd();
      const environment = { ...process.env };
      const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'finalize-'));
      process.chdir(directory);
      process.env.GITHUB_EVENT_NAME = 'workflow_run';
      process.env.GITHUB_REPOSITORY = ci.repository;
      process.env.GITHUB_EVENT_PATH = path.join(directory, 'event.json');
      process.env.GITHUB_TOKEN = 'test-token';
      ci.writeJson('event.json', { workflow_run: fixture.run });
      ci.writeJson('.ci-work/report.json', {
        runId: fixture.run.id, runAttempt: fixture.run.run_attempt,
        headSha: fixture.run.head_sha, pr: fixture.pull.number,
        failed: false, summary: 'Previews verified.',
      });
      const checks = [];
      const api = new MemoryGitHub(fixture);
      t.mock.method(globalThis, 'fetch', async (url, options) => {
        const requestPath = String(url).split(ci.repository)[1];

        if (requestPath === '/check-runs') {
          checks.push(JSON.parse(options.body));
          return Response.json({ id: 1 });
        }

        return Response.json(await api.request(requestPath));
      });

      try {
        process.env.COMMENT_RESULT = 'failure';
        await github.publishCommand('finalize');
        assert.equal(checks.at(-1).conclusion, 'failure');
        assert.equal(process.exitCode, 1);
        process.env.COMMENT_RESULT = 'success';
        await github.publishCommand('finalize');
        assert.equal(checks.at(-1).conclusion, 'success');
        assert.equal(process.exitCode, 0);
      } finally {
        process.exitCode = 0;
        process.chdir(previous);
        process.env = environment;
        fs.rmSync(directory, { recursive: true, force: true });
      }
    });

    test('failed dispatch preserves pending and retries with a fresh tag',
      async () => {
        const { api, state, current, metadata } = mainFixture();
        const request = api.request;
        api.request = async (path, options) => {
          if (path === '/git/refs') {
            throw new ci.ApiError(503);
          }

          return request(path, options);
        };
        await assert.rejects(main.schedule(api, state, metadata,
          current, evaluated()), ci.ApiError);
        const failed = await state.get('main-plan');
        assert.deepEqual(failed.pending, {
          cache: ['vendor.font'], preview: ['vendor.font'],
        });
        api.request = request;
        const retried = await main.schedule(api, state, metadata,
          current, evaluated());
        assert.notEqual(retried.requests['cache:vendor.font'].tag,
          failed.requests['cache:vendor.font'].tag);
      });

    function fakeCommands(t, handler) {
      t.mock.method(childProcess, 'spawnSync', (program, args, options) => ({
        status: 0, stdout: handler(program, args, options), stderr: "",
      }));
      syncBuiltinESMExports();
      t.after(() => {
        t.mock.restoreAll();
        syncBuiltinESMExports();
      });
    }

    function graphDocument(current) {
      const graph = {};

      for (const item of Object.values(current.packages)) {
        const source = item.sources[0];
        graph[item.drvPath] = {
          outputs: { out: { path: item.outputs.out } },
          inputDrvs: { [source.drvPath]: ['out'] },
        };
        graph[source.drvPath] = {
          outputs: { out: { path: source.path } }, inputDrvs: {},
        };
      }

      return JSON.stringify(graph);
    }

    function shardFixture(t, cacheable) {
      const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'shard-'));
      const environment = { ...process.env };
      const fixture = publicationFixture(cacheable);
      const current = evaluated(font('font', { redistributable: cacheable }));
      const root = '${../.}';
      const item = current.packages['vendor.font'];
      Object.assign(fixture.plan.packages['vendor.font'], {
        buildKey: item.buildKey, previewKey: item.previewKey, preview: false,
      });
      fixture.plan.controller = actions.controllerDigest(root);
      process.env.GITHUB_EVENT_NAME = 'pull_request';
      process.env.GITHUB_REPOSITORY = ci.repository;
      process.env.GITHUB_SHA = fixture.context.mergeSha;
      process.env.GITHUB_RUN_ID = String(fixture.context.runId);
      process.env.GITHUB_RUN_ATTEMPT = String(fixture.context.runAttempt);
      const event = { pull_request: {
        ...fixture.pull, base: { ...fixture.pull.base, sha: 'a'.repeat(40) },
      } };
      const copied = [];
      const selected = [];
      let corrupt = false;
      fakeCommands(t, (program, args, options) => {
        if (program === 'git') {
          if (args.includes('rev-parse')) {
            return fixture.context.mergeSha;
          }

          if (args.includes('show')) {
            return event.pull_request.base.sha + ' ' + fixture.context.headSha;
          }

          return "";
        }

        assert.equal(program, 'nix');

        if (args[0] === 'derivation') {
          return graphDocument(current);
        }

        if (args[0] === 'eval' || args[0] === 'build') {
          const evaluation = JSON.parse(options.env.FONT_CI_ARGUMENTS);

          if (evaluation.mode === 'inventory') {
            return JSON.stringify(current);
          }

          if (evaluation.mode === 'preview-requests') {
            return '{}';
          }

          if (evaluation.mode === 'preview-config') {
            return JSON.stringify({ rendererDrvPath: store('renderer.drv'),
              samples: { vendor: { font: 'english' } } });
          }

          assert.equal(evaluation.mode, 'outputs');
          selected.push(...evaluation.selection);
          return JSON.stringify([{ outputs: { out: corrupt
            ? store('wrong-output') : item.outputs.out } }]);
        }

        assert.ok(cacheable, 'Restricted shard must never export a cache');

        if (args[0] === 'copy') {
          copied.push(args);
          return "";
        }

        assert.equal(args[0], 'path-info');
        return args.includes('--all') ? item.outputs.out :
          JSON.stringify({ [item.outputs.out]: {} });
      });
      t.after(() => {
        process.env = environment;
        fs.rmSync(directory, { recursive: true, force: true });
      });
      return { ...fixture, root, current, directory, event, copied, selected,
        corrupt: () => { corrupt = true; } };
    }

    test('restricted shards build without cache exports', t => {
      const fixture = shardFixture(t, false);
      const { root, plan, directory, event, copied, selected } = fixture;
      assert.equal(actions.buildShard(root, plan, 0, directory, event), true);
      assert.deepEqual(selected, ['vendor.font']);
      assert.deepEqual(copied, []);
      const receipts = ci.readJson(path.join(directory,
        'artifacts/receipts.json'));
      assert.equal(receipts.packages['vendor.font'].buildSucceeded, true);
    });

    test('public shard exports exactly audited realized outputs', t => {
      const fixture = shardFixture(t, true);
      const { root, plan, directory, event, copied, current } = fixture;
      assert.equal(actions.buildShard(root, plan, 0, directory, event), true);
      assert.equal(copied.length, 1);
      assert.deepEqual(copied[0].slice(3), [
        current.packages['vendor.font'].outputs.out,
      ]);
    });

    test('unexpected outputs cannot produce a successful receipt or cache',
      t => {
        const fixture = shardFixture(t, true);
        const { root, plan, directory, event, copied } = fixture;
        fixture.corrupt();
        const result = actions.buildShard(root, plan, 0, directory, event);
        assert.equal(result, false);
        assert.deepEqual(copied, []);
        const receipt = ci.readJson(path.join(directory,
          'artifacts/receipts.json')).packages['vendor.font'];
        assert.equal(receipt.buildSucceeded, false);
        assert.equal(receipt.previewGenerated, false);
      });

    test('public upload audits closure and verifies after copying', async t => {
      const root = store('font');
      const source = { [root]: {
        narHash: 'sha256-test', narSize: 100, references: [],
      } };
      const cache = { url: 'https://cache.test', publicKey: 'key' };
      let copied = false;
      let credential;
      const verified = [];
      let guards = 0;
      fakeCommands(t, (program, args) => {
        assert.equal(program, 'nix');

        if (args[0] === 'path-info') {
          if (args.includes('--store') && !copied) {
            throw new Error('Cache miss');
          }

          return JSON.stringify(source);
        }

        if (args[0] === 'copy') {
          assert.equal(args[2], cache.url + '?compression=zstd');
          credential = args[5];
          assert.equal(fs.statSync(credential).mode & 0o777, 0o600);
          assert.equal(fs.readFileSync(credential, 'utf8'), 'test-netrc');
          copied = true;
        } else {
          assert.ok(copied);
          assert.equal(args[0], 'store');
          assert.equal(args[1], 'verify');
          verified.push(args);
        }

        return "";
      });
      await assert.rejects(main.publishCache([root], [root], cache,
        'test-netrc', async () => {}), /Restricted/);
      assert.equal(copied, false);
      await main.publishCache([root], [], cache, 'test-netrc',
        async () => { guards += 1; });
      assert.equal(guards, 3);
      assert.equal(verified.length, 2);
      assert.ok(verified[0].includes('--recursive'));
      assert.ok(verified[0].includes('--no-contents'));
      assert.ok(!verified[1].includes('--no-contents'));
      assert.equal(fs.existsSync(credential), false);
    });

    test('failed cache verification never records publication success',
      async t => {
        const { api, state, current, metadata } = mainFixture();
        const observed = await main.schedule(api, state, metadata,
          current, evaluated());
        const selected = observed.requests['cache:vendor.font'];
        const root = current.packages['vendor.font'].outputs.out;
        let copies = 0;
        fakeCommands(t, (program, args) => {
          if (args[0] === 'copy') {
            copies += 1;
            return "";
          }

          if (args.includes('--store')) {
            throw new Error('Public cache verification failed');
          }

          return JSON.stringify({ [root]: {
            narHash: 'sha256-test', narSize: 100, references: [],
          } });
        });
        await assert.rejects(main.publishPackage(api, state, {
          ...metadata, mode: 'cache', name: selected.name, tag: selected.tag,
        }, current, { 'public-cache': { data: { netrc: 'test-netrc' } } }),
        /verification failed/);
        assert.equal(copies, 1);
        assert.equal(await state.get(main.publicationKey('cache',
          'vendor.font')), null);
      });
    test('a new repair token invalidates a successful PR preview', () => {
      const current = evaluated(font('font'));
      const configuration = {
        rendererDrvPath: store('renderer.drv'),
        samples: { vendor: { font: 'english' } },
        requests: { 'vendor.font': 'repair-1' },
      };
      ci.previewKeys(current, configuration);
      const before = receipt(current.packages['vendor.font']);
      configuration.requests['vendor.font'] = 'repair-2';
      ci.previewKeys(current, configuration);
      assert.notEqual(current.packages['vendor.font'].previewKey,
        before.previewKey);
      const selected = ci.plan(current, current, { 'vendor.font': before }, {
        previewRequests: ['vendor.font'],
      });
      assert.equal(selected.tasks.length, 1);
      assert.equal(selected.tasks[0].preview, true);
    });

    test('formal images recover state without hiding unfinished cache work',
      async () => {
        const { api, state, current, metadata } = mainFixture();
        await main.schedule(api, state, metadata, current, evaluated());
        const { manifest, files } = publicationFixture();
        Object.assign(manifest, preview.expectedPreview('vendor.font',
          current.packages['vendor.font']));
        manifest.source = { kind: 'main', rev: metadata.rev };
        const payload = {
          [main.manifestPath('vendor.font')]: ci.bytes(manifest), ...files,
        };

        for (const [file, data] of Object.entries(payload)) {
          const digest = github.blobSha(data);
          api.blobs.set(digest, data);
          api.entries[file] = {
            sha: digest, type: 'blob', mode: '100644', size: data.length,
          };
        }

        api.blob = async entry => api.blobs.get(entry.sha);
        const next = await main.schedule(api, state, metadata,
          current, evaluated());
        assert.deepEqual(next.pending, { cache: ['vendor.font'], preview: [] });
        assert.equal((await state.get(main.publicationKey('preview',
          'vendor.font'))).previewKey, manifest.previewKey);
        delete api.entries['vendor/font+Regular.png'];
        const damaged = await main.schedule(api, state, metadata,
          current, evaluated());
        assert.deepEqual(damaged.pending.preview, ['vendor.font']);
      });

    test('PR baselines work before CI preview configuration exists', t => {
      const current = evaluated(font('font'));
      fakeCommands(t, (program, args, options) => {
        if (args[0] === 'derivation') {
          return graphDocument(current);
        }

        const request = JSON.parse(options.env.FONT_CI_ARGUMENTS);
        assert.equal(request.mode, 'inventory');
        return JSON.stringify(current);
      });
      assert.equal(ci.inventory('/baseline-without-ci', false)
        .packages['vendor.font'].cacheable, true);
    });
  '';
in
{
  font-ci =
    pkgs.runCommand "font-ci-tests"
      {
        nativeBuildInputs = with pkgs; [
          nodejs
        ];
      }
      ''
        node --test ${tests}
        touch "$out"
      '';
}
