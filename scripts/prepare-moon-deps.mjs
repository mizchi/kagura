// Published dependencies may still contain JSON manifests. Current MoonBit
// requires migrating the downloaded copy before it can resolve the next edge.
import {spawnSync} from 'node:child_process';
import {existsSync} from 'node:fs';
import {resolve, dirname, join, sep} from 'node:path';
import {patchMoonDependencies} from './moon-dependency-compat.mjs';
import {pathToFileURL} from 'node:url';

export function prepareMoonDeps(directory = '.', {run = spawnSync} = {}) {
  const cwd = resolve(directory);
  const migrated = new Set();
  function invoke(args) {
    const result = run('moon', args, {cwd, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024});
    if (result.error) throw result.error;
    return {...result, output: (result.stdout ?? '') + (result.stderr ?? '')};
  }
  for (;;) {
    const result = invoke(['check', '--dry-run']);
    if (result.status === 0) {
      for (let directory = cwd;; directory = dirname(directory)) {
        const cache = join(directory, '.mooncakes');
        if (existsSync(cache)) {
          patchMoonDependencies(cache);
          break;
        }
        if (dirname(directory) === directory) break;
      }
      return;
    }
    const match = result.output.match(/`moon\.mod\.json` at '([^']+)' is no longer supported/);
    const dependency = match && resolve(match[1]);
    if (!dependency?.includes(`${sep}.mooncakes${sep}`)) {
      throw new Error(result.output || `moon check --dry-run failed (${result.status})`);
    }
    if (migrated.has(dependency)) throw new Error(`Dependency already migrated: ${dependency}\n${result.output}`);
    migrated.add(dependency);
    const formatted = invoke(['-C', dependency, 'fmt']);
    if (formatted.status !== 0) throw new Error(formatted.output || `moon fmt failed (${formatted.status})`);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    for (const directory of process.argv.slice(2).length ? process.argv.slice(2) : ['.']) prepareMoonDeps(directory);
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
