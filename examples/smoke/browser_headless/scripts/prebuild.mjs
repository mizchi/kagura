// Combined native link configuration for Kagura and the V8 host adapter.
import {execFileSync} from 'node:child_process';
import {resolve, join} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const root = resolve(fileURLToPath(new URL('..', import.meta.url)));

export function combinePrebuild(input = {}, {moduleRoot = root, run = execFileSync} = {}) {
  const scripts = [
    resolve(moduleRoot, '../../../scripts/moon-prebuild-native-link-flags.cjs'),
    join(moduleRoot, 'scripts/mizchi-v8-consumer-prebuild.mjs'),
  ];
  const vars = {};
  for (const script of scripts) {
    const output = run(process.execPath, [script], {
      cwd: moduleRoot,
      input: JSON.stringify(input),
      encoding: 'utf8',
      maxBuffer: 16 * 1024 * 1024,
    }).trim();
    const last = output.split('\n').at(-1);
    Object.assign(vars, JSON.parse(last).vars ?? {});
  }
  return {vars};
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  let raw = '';
  for await (const chunk of process.stdin) raw += chunk;
  const input = raw.trim() ? JSON.parse(raw) : {};
  process.stdout.write(JSON.stringify(combinePrebuild(input, {moduleRoot: input.paths?.module_root ?? root})));
}
