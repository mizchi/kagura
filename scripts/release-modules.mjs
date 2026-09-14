import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {defaultRepoRoot, loadReleaseModules} from './moon-release-utils.mjs';

import {PUBLISH_MODULE_DIRS} from './release-policy.mjs';
export {PUBLISH_MODULE_DIRS} from './release-policy.mjs';

export function publishModules({repoRoot = defaultRepoRoot(), moduleDirs = PUBLISH_MODULE_DIRS} = {}) {
  const {modules, byName} = loadReleaseModules({repoRoot, moduleDirs});
  if (byName.size !== modules.length || modules.some(mod => !mod.name))
    throw new Error('Publication catalog has missing or duplicate module names');
  const ordered = [];
  const active = new Set();
  const visited = new Set();
  function visit(mod) {
    if (active.has(mod.name)) throw new Error(`Publication dependency cycle at ${mod.name}`);
    if (visited.has(mod.name)) return;
    active.add(mod.name);
    for (const name of Object.keys(mod.manifest.deps ?? {})) {
      if (byName.has(name)) visit(byName.get(name));
    }
    active.delete(mod.name);
    visited.add(mod.name);
    ordered.push(mod);
  }
  for (const mod of modules) visit(mod);
  return ordered;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  for (const mod of publishModules()) console.log(mod.dir);
}
