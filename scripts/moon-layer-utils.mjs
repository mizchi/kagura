import fs from 'node:fs';
import path from 'node:path';
import {defaultRepoRoot, loadReleaseModules, readMoonWorkMembers} from './moon-release-utils.mjs';
import {parseMoonPkgImports} from './moon-boundary-utils.mjs';

// Check every workspace module, including independent modules nested in a layer.
// The release policy alone cannot see dependencies on geom/anim3d/renderer2d/etc.
const allowedLayers = {
  benchmarks: ['core', 'engine', 'game', 'platform', 'platform_web', 'integration'],
  experiments: ['core', 'engine', 'game', 'platform', 'platform_web', 'integration'],
  core: ['core'],
  engine: ['core', 'engine', 'platform'],
  game: ['core', 'engine', 'game', 'platform'],
  platform: ['core'],
  platform_web: ['core', 'platform'],
  facade: ['core', 'engine', 'platform'],
  integration: ['core', 'engine', 'platform', 'platform_web', 'integration'],
};

function layerOf(dir) {
  if (dir === '.') return 'facade';
  if (dir === 'platform_native' || dir === 'platform_web/runtime_hooks') return 'integration';
  return dir.split('/')[0];
}

function sourceFiles(dir) {
  return fs.readdirSync(dir, {withFileTypes: true}).flatMap(entry => {
    if (entry.name.startsWith('.') || ['_build', 'node_modules', 'target', 'dist'].includes(entry.name)) return [];
    const file = path.join(dir, entry.name);
    if (!entry.isDirectory()) return entry.isFile() ? [file] : [];
    if (['moon.mod', 'moon.mod.json'].some(name => fs.existsSync(path.join(file, name)))) return [];
    return sourceFiles(file);
  });
}

function targetFor(name, modules) {
  return modules.find(mod => name === mod.name || name.startsWith(mod.name + '/'));
}

export function validateWorkspaceLayers({repoRoot = defaultRepoRoot()} = {}) {
  const {modules} = loadReleaseModules({repoRoot, moduleDirs: readMoonWorkMembers(repoRoot)});
  const targets = [...modules].sort((a, b) => b.name.length - a.name.length);
  const errors = [];
  for (const owner of modules) {
    const layer = layerOf(owner.dir);
    const allowed = allowedLayers[layer];
    if (!allowed) {
      errors.push(`${owner.dir}: missing workspace layer policy`);
      continue;
    }
    function checkImport(name, file) {
      const target = targetFor(name, targets);
      if (target) {
        if (target.name !== owner.name && !allowed.includes(layerOf(target.dir)))
          errors.push(`${file}: ${owner.name} (${layer}) must not depend on ${name} (${layerOf(target.dir)})`);
      } else if (layer === 'core' && !name.startsWith('moonbitlang/core/') &&
                 name !== 'mizchi/terrain' && !name.startsWith('mizchi/terrain/')) {
        errors.push(`${file}: core external dependency ${name} is not a declared calculation library`);
      }
    }
    for (const name of Object.keys(owner.manifest.deps ?? {})) checkImport(name, `${owner.dir}/moon.mod`);
    for (const file of sourceFiles(owner.sourceDir)) {
      const relative = path.relative(repoRoot, file);
      if (path.basename(file) === 'moon.pkg') {
        for (const entry of parseMoonPkgImports(fs.readFileSync(file, 'utf8')))
          checkImport(entry.path, `${relative}:${entry.line}`);
      } else if (layer === 'core' && file.endsWith('.mbt') && !/_(?:wbtest|test|bench)\.mbt$/.test(file)) {
        if (/^\s*(?:pub\s+)?extern\s+"/m.test(fs.readFileSync(file, 'utf8')))
          errors.push(`${relative}: core must not call a host through FFI`);
      }
    }
  }
  return {errors, modules};
}
