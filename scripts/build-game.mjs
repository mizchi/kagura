import {spawnSync} from 'node:child_process';
import {existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, renameSync, rmSync, writeFileSync} from 'node:fs';
import {dirname, join, relative, resolve, sep} from 'node:path';
import {buildWebRuntime} from './build-web-runtime.mjs';
import {copyWebRuntimeAssets} from './web-runtime-assets.mjs';
import {emitExamplePage} from './web-demo-package.mjs';
import {resolveDemoPage} from './web-demo-pages.mjs';

const marker = '.kagura-build.json';
const within = (parent, child) => {
  const path = relative(parent, child);
  return path === '' || (!path.startsWith('..' + sep) && path !== '..' && !path.startsWith(sep));
};

function canonical(path) {
  return existsSync(path) ? realpathSync(path) : join(canonical(dirname(path)), path.slice(dirname(path).length + 1));
}

/** Build into a temporary directory and only replace a previously owned build. */
export function buildGame({project, outDir = join(project.directory, 'dist'), compile = spawnSync, buildRuntime = buildWebRuntime}) {
  const output = canonical(resolve(outDir));
  const source = realpathSync(project.directory);
  if (within(output, source) || ['assets', '_build', '.mooncakes', 'node_modules'].some(dir => within(join(source, dir), output))) {
    throw new Error(`Invalid output directory: ${output}`);
  }
  if (existsSync(output) && readdirSync(output).length > 0) {
    let owned;
    try { owned = JSON.parse(readFileSync(join(output, marker), 'utf8')); } catch {}
    if (owned?.project !== source || owned?.generator !== 'kagura') {
      throw new Error(`Output directory is not a Kagura build for this project: ${output}`);
    }
  }
  buildRuntime();
  const result = compile('moon', ['build', project.entry, '--target', 'js', '--release'], {cwd: source, stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw Object.assign(new Error(`MoonBit build failed (exit ${result.status ?? 1})`), {exitCode: result.status ?? 1});
  }
  mkdirSync(dirname(output), {recursive: true});
  const staging = mkdtempSync(join(dirname(output), '.kagura-build-'));
  const backup = join(staging, 'previous');
  const site = join(staging, 'site');
  try {
    copyWebRuntimeAssets(join(site, 'lib'));
    emitExamplePage({demo: resolveDemoPage(project.name), exampleDir: source, site,
      demoDir: site, artifactName: project.artifactName, packageName: project.packageName, entry: project.entry,
      libPrefix: './lib', cacheBust: String(Date.now()), homeHref: 'https://github.com/mizchi/kagura', homeLabel: 'Repository'});
    writeFileSync(join(site, marker), JSON.stringify({generator: 'kagura', project: source}) + '\n');
    if (existsSync(output)) renameSync(output, backup);
    try { renameSync(site, output); }
    catch (error) {
      if (existsSync(backup)) renameSync(backup, output);
      throw error;
    }
  } finally {
    // If restoring a previous build itself failed, leave it for recovery.
    if (existsSync(output) || !existsSync(backup)) rmSync(staging, {recursive: true, force: true});
  }
  return output;
}
