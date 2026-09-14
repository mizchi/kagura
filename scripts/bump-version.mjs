import {readFileSync, readdirSync, writeFileSync, existsSync} from 'node:fs';
import {join, resolve, relative, basename} from 'node:path';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {defaultRepoRoot} from './moon-release-utils.mjs';
import {publishModules} from './release-modules.mjs';

function releaseVersion(version) {
  if (!/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/.test(version))
    throw new Error(`Invalid release version ${version}; expected X.Y.Z (for example 0.5.0)`);
  return version.split('.').map(BigInt);
}

function compareVersions(a, b) {
  const left = releaseVersion(a);
  const right = releaseVersion(b);
  for (let i = 0; i < 3; i++) if (left[i] !== right[i]) return left[i] < right[i] ? -1 : 1;
  return 0;
}

// Keep source positions so a version bump preserves comments and formatting.
// String tokens take precedence over comment delimiters inside quoted values.
function manifestTokens(source) {
  return [...source.matchAll(/"(?:\\.|[^"\\])*"|\/\*[\s\S]*?\*\/|\/\/[^\n]*|[A-Za-z_][\w-]*|[^\s]/g)]
    .filter(match => !match[0].startsWith('//') && !match[0].startsWith('/*'))
    .map(match => ({value: match[0], start: match.index, end: match.index + match[0].length}));
}

export function updateManifest(source, {version, publicNames, updateOwnVersion = false, json = false}) {
  if (json) {
    const manifest = JSON.parse(source);
    let changed = false;
    if (updateOwnVersion && manifest.version !== version) {
      manifest.version = version;
      changed = true;
    }
    for (const [name, spec] of Object.entries(manifest.deps ?? {})) {
      if (!publicNames.has(name)) continue;
      if (typeof spec === 'string') {
        if (spec !== version) { manifest.deps[name] = version; changed = true; }
      } else if (spec && typeof spec.path === 'string') {
        if (spec.version !== version) { spec.version = version; changed = true; }
      } else {
        throw new Error(`Unsupported dependency specification for ${name}`);
      }
    }
    if (!changed) return source;
    const indent = source.match(/\n([\t ]+)"/)?.[1] ?? 2;
    return JSON.stringify(manifest, null, indent) + '\n';
  }
  const tokens = manifestTokens(source);
  const edits = [];
  const replaceString = (token, value) => {
    if (!token?.value.startsWith('"')) throw new Error('Expected a quoted manifest value');
    if (JSON.parse(token.value) !== value) edits.push({...token, replacement: JSON.stringify(value)});
  };
  let depth = 0;
  let ownVersions = 0;
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (depth === 0 && token.value === 'version' && tokens[i + 1]?.value === '=') {
      ownVersions++;
      if (updateOwnVersion) replaceString(tokens[i + 2], version);
    }
    if (depth === 0 && token.value === 'import' && tokens[i + 1]?.value === '{') {
      i += 2;
      for (; i < tokens.length && tokens[i].value !== '}'; i++) {
        const entry = tokens[i];
        if (!entry.value.startsWith('"')) continue;
        const spec = JSON.parse(entry.value);
        const at = spec.lastIndexOf('@');
        const name = at < 0 ? spec : spec.slice(0, at);
        if (publicNames.has(name)) replaceString(entry, `${name}@${version}`);
      }
      if (i === tokens.length) throw new Error('Unclosed manifest import block');
      continue;
    }
    if (['{', '(', '['].includes(token.value)) depth++;
    if (['}', ')', ']'].includes(token.value)) depth--;
  }
  if (updateOwnVersion && ownVersions !== 1) throw new Error('Expected exactly one module version field');
  for (const edit of edits.sort((a, b) => b.start - a.start))
    source = source.slice(0, edit.start) + edit.replacement + source.slice(edit.end);
  return source;
}

// Only source-owned trees: never traverse vendor copies, caches or build output.
const SOURCE_DIRS = ['core', 'engine', 'game', 'platform', 'platform_web', 'platform_native',
  'cmd', 'editor', 'examples', 'benchmarks', 'experiments'];
const SKIP_DIRS = new Set(['_build', '_site', 'node_modules', 'target', 'dist', 'public',
  'assets', 'vendor', 'fixtures', 'test-results', 'playwright-report']);
const MANIFEST_NAME = /^moon\.mod(?:\.json)?(?:\.template)?$/;

function manifestFiles(repoRoot) {
  const files = [];
  const visit = dir => {
    for (const entry of readdirSync(dir, {withFileTypes: true})) {
      if (entry.name.startsWith('.')) continue;
      const file = join(dir, entry.name);
      if (entry.isDirectory() && !SKIP_DIRS.has(entry.name)) visit(file);
      else if (entry.isFile() && MANIFEST_NAME.test(entry.name)) files.push(file);
    }
  };
  for (const name of ['moon.mod', 'moon.mod.json'])
    if (existsSync(join(repoRoot, name))) files.push(join(repoRoot, name));
  for (const dir of SOURCE_DIRS) if (existsSync(join(repoRoot, dir))) visit(join(repoRoot, dir));
  return files.sort();
}

export function planVersionUpdate(version, {repoRoot = defaultRepoRoot(), moduleDirs} = {}) {
  releaseVersion(version);
  repoRoot = resolve(repoRoot);
  const modules = publishModules({repoRoot, moduleDirs});
  for (const mod of modules)
    if (compareVersions(version, mod.version) < 0)
      throw new Error(`Cannot downgrade ${mod.name} from version ${mod.version} to ${version}`);
  const publicNames = new Set(modules.map(mod => mod.name));
  const ownManifests = new Set(modules.map(mod => resolve(mod.manifestPath)));
  const changes = [];
  const files = manifestFiles(repoRoot);
  for (const mod of modules)
    if (!files.includes(resolve(mod.manifestPath))) throw new Error(`Version scan missed ${mod.manifestPath}`);
  for (const file of files) {
    const before = readFileSync(file, 'utf8');
    let after;
    try {
      after = updateManifest(before, {version, publicNames, updateOwnVersion: ownManifests.has(file),
        json: basename(file).includes('.json')});
    } catch (error) {
      throw new Error(`${relative(repoRoot, file)}: ${error.message}`, {cause: error});
    }
    if (before !== after) changes.push({file, path: relative(repoRoot, file).replaceAll('\\', '/'), before, after});
  }
  return {version, repoRoot, modules, changes};
}

export function applyVersionUpdate(plan) {
  // Complete preflight before the first write, including edits made since planning.
  for (const change of plan.changes)
    if (readFileSync(change.file, 'utf8') !== change.before)
      throw new Error(`${change.path} changed after the version update was planned`);
  for (const change of plan.changes) writeFileSync(change.file, change.after);
}

function main(args) {
  if (args.length === 1 && ['--help', '-h'].includes(args[0])) {
    console.log('Usage: just version X.Y.Z [--dry-run | --check]\nUpdates public modules, internal dependencies and scaffolding; regenerates Web runtime and CLI.');
    return;
  }
  const [version, ...flags] = args;
  if (flags.length > 1 || flags.some(flag => !['--dry-run', '--check'].includes(flag)))
    throw new Error('Use one of --dry-run or --check');
  const plan = planVersionUpdate(version);
  console.log(`Release ${version}: ${plan.modules.length} modules, ${plan.changes.length} manifest changes`);
  for (const mod of plan.modules) console.log(`  ${mod.name}: ${mod.version} -> ${version}`);
  for (const change of plan.changes) console.log(`  ${change.path}`);
  if (flags.includes('--dry-run')) return;
  if (flags.includes('--check')) {
    if (plan.changes.length) process.exitCode = 1;
    return;
  }
  applyVersionUpdate(plan);
  // Also run on an already-aligned version, so retrying a failed build repairs
  // generated artifacts without requiring another version bump.
  for (const script of ['scripts/build-web-runtime.mjs', 'cmd/kagura/build.mjs']) {
    const result = spawnSync(process.execPath, [join(plan.repoRoot, script)], {cwd: plan.repoRoot, stdio: 'inherit'});
    if (result.error || result.status !== 0)
      throw new Error(`Version manifests updated, but ${script} failed. Fix the build and rerun just version ${version}.`, {cause: result.error});
  }
  console.log(`Updated to ${version}. Review git diff and run just check-release before publishing.`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try { main(process.argv.slice(2)); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
