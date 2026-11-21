import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { command, digest, evaluate, nixFlags } from './common.mjs';
import { runContext } from './builds.mjs';

export function checkLanguages(root, directory, event) {
  runContext(root, event);
  root = path.resolve(root);
  directory = path.resolve(directory);
  fs.mkdirSync(directory, { recursive: true });
  const base = fs.mkdtempSync(path.join(directory, 'languages-base-'));
  let previous;
  let added = false;
  try {
    command('git', [
      '-C',
      root,
      'worktree',
      'add',
      '--detach',
      base,
      event.pull_request.base.sha,
    ]);
    added = true;
    previous = evaluate(base, 'languages');
  } finally {
    if (added) {
      command('git', ['-C', root, 'worktree', 'remove', '--force', base]);
    } else {
      fs.rmdirSync(base);
    }
  }

  const current = evaluate(root, 'languages');
  const scannerChanged = previous.scanner !== current.scanner;
  const selected = [];
  const skipped = [];
  for (const [attribute, item] of Object.entries(current.packages)) {
    if (
      !scannerChanged &&
      digest(item) === digest(previous.packages[attribute] ?? null)
    ) {
      continue;
    }
    (item.windows ? skipped : selected).push(attribute);
  }

  console.log('Language coverage checks: ' + selected.length + ' package(s).');
  if (skipped.length) {
    console.log(
      'Not scanned automatically (requires local Windows sources): ' +
        skipped.join(', '),
    );
  }
  if (process.env.GITHUB_STEP_SUMMARY) {
    fs.appendFileSync(
      process.env.GITHUB_STEP_SUMMARY,
      'Language coverage: ' +
        selected.length +
        ' package(s) selected.\n\n' +
        (skipped.length
          ? 'Not scanned; requires local Windows sources:\n\n' +
            skipped.map((name) => '- `' + name + '`').join('\n') +
            '\n'
          : ''),
    );
  }
  if (selected.length) {
    command(
      'nix',
      [
        'run',
        ...nixFlags,
        'git+' + pathToFileURL(root).href + '#update-font-languages',
        '--',
        '--source-root',
        root,
        '--check',
        '--output',
        path.join(directory, 'languages.json'),
        ...selected,
      ],
      { stdio: ['ignore', 'inherit', 'inherit'] },
    );
  }
}
