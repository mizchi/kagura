import {existsSync, readFileSync} from 'node:fs';
import {basename, dirname, join, resolve} from 'node:path';
import {EXAMPLE_ROOT, findExampleDir, isExampleDir, REPO_ROOT} from './example-dirs.mjs';
import {readModuleManifest} from './moon-mod-manifest.mjs';

const roots = [EXAMPLE_ROOT.effectStudio, EXAMPLE_ROOT.modeling3d, EXAMPLE_ROOT.examples];

/** Locate a runnable module, keeping paths intact (including spaces/Unicode). */
export function resolveWebProject(selector, cwd = process.cwd()) {
  let directory;
  if (selector) {
    const explicit = resolve(cwd, selector);
    directory = isExampleDir(explicit) ? explicit : findExampleDir(selector, roots);
    if (!directory) throw new Error(`Project not found: ${selector}`);
  } else {
    directory = resolve(cwd);
    while (!isExampleDir(directory) && dirname(directory) !== directory) directory = dirname(directory);
  }
  if (directory === REPO_ROOT || !isExampleDir(directory)) {
    throw new Error('Specify a runnable project, e.g. kagura dev hacknslash_3d, or run inside a game directory.');
  }
  const manifest = readModuleManifest(directory);
  const source = resolve(directory, manifest.source ?? '.');
  const entry = ['.', 'src'].find(entry => {
    const file = join(source, entry, 'moon.pkg');
    const legacy = join(source, entry, 'moon.pkg.json');
    if (existsSync(file)) return /\bis_main\s*[:=]\s*true\b|pkgtype\s*\(\s*kind\s*:\s*"executable"/.test(readFileSync(file, 'utf8'));
    if (existsSync(legacy)) return JSON.parse(readFileSync(legacy, 'utf8'))['is-main'] === true;
    return false;
  });
  if (entry == null) throw new Error(`No runnable root or src package in project: ${directory}`);
  const artifactName = entry === '.' ? manifest.name.split('/').at(-1) : basename(entry);
  const packageName = manifest.name + (entry === '.' ? '' : '/' + entry);
  return {directory, name: basename(directory), entry, artifactName, packageName};
}

/** Workspace builds include the module path; standalone projects can be flat. */
export function resolveProjectArtifact(project, mode) {
  const directory = join(project.directory, '_build/js', mode, 'build');
  return [join(directory, project.packageName, project.artifactName + '.js'),
    join(directory, project.entry ?? '.', project.artifactName + '.js'),
    join(directory, project.artifactName + '.js')].find(existsSync) ?? null;
}
