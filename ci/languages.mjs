import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { command, digest } from './common.mjs';
import { evaluate, nixFlags, withBaseWorktree } from './inventory.mjs';
import { runContext } from './builds.mjs';

export function checkLanguages(root, directory, event) {
  runContext(root, event);

  root = path.resolve(root);
  directory = path.resolve(directory);
  fs.mkdirSync(directory, { recursive: true });

  const previous = withBaseWorktree(
    root,
    directory,
    event.pull_request.base.sha,
    (base) => evaluate(base, 'languages'),
  );
  const current = evaluate(root, 'languages');
  const scannerChanged = previous.scanner !== current.scanner;
  const selected = [];
  const skipped = [];

  for (const [attribute, item] of Object.entries(current.packages)) {
    const prior = Object.hasOwn(previous.packages, attribute)
      ? previous.packages[attribute]
      : null;

    if (!scannerChanged && digest(item) === digest(prior)) {
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
        '--',
        ...selected,
      ],
      { stdio: ['ignore', 'inherit', 'inherit'] },
    );
  }
}
