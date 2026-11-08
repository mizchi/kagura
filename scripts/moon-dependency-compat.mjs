// Compatibility fixes for published versions that predate MoonBit 0.10.20.
// Keep these scoped by module and version; upstream releases can remove them.
import {existsSync, readFileSync, readdirSync, writeFileSync} from 'node:fs';
import {join} from 'node:path';
import {readModuleManifest} from './moon-mod-manifest.mjs';

function rewrite(directory, transform) {
  for (const entry of readdirSync(directory, {withFileTypes: true})) {
    if (entry.name.startsWith('.') || ['_build', 'target', 'node_modules'].includes(entry.name)) continue;
    const path = join(directory, entry.name);
    if (entry.isDirectory()) rewrite(path, transform);
    else if (entry.name.endsWith('.mbt') || entry.name === 'moon.pkg') {
      const before = readFileSync(path, 'utf8');
      const after = transform(before, path);
      if (after !== before) writeFileSync(path, after);
    }
  }
}

export function patchMoonDependencies(cache) {
  const names = ['crater-core', 'crater-dom', 'crater-layout', 'crater-painter', 'crater-renderer', 'differentiable_ecs'];
  for (const name of names) {
    const directory = join(cache, 'mizchi', name);
    if (!existsSync(join(directory, 'moon.mod'))) continue;
    const manifest = readModuleManifest(directory);
    if (name.startsWith('crater-') && manifest.version === '0.19.0') {
      // css 0.8 names the CSS float enum CssFloat; Float is now reserved.
      rewrite(directory, source => source.replace(/\bFloat\b/g, 'CssFloat'));
    } else if (name === 'differentiable_ecs' && manifest.version === '0.2.1') {
      const path = join(directory, 'src/optimizer/moon.pkg');
      const before = readFileSync(path, 'utf8');
      if (!before.includes('"moonbitlang/core/cmp"')) {
        writeFileSync(path, before.replace('import {', 'import {\n  "moonbitlang/core/cmp",'));
      }
    }
  }
}
