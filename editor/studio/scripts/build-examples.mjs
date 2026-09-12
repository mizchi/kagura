import {copyWebRuntimeAssets} from '../../../scripts/web-runtime-assets.mjs';
import { packagedPath } from '../examples/files.mjs';
import { runtimeEntry, projectBuild } from '../projects/settings.mjs';
import { validateProject } from '../projects/project.mjs';
import { spawnSync } from 'node:child_process';
import { cp, mkdir, rm, readFile, writeFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { catalog, catalogProjectDir } from '../../../scripts/example-catalog.mjs';
import { resolveBuildArtifact } from '../../../scripts/moon-build-artifact-utils.mjs';

const studio = new URL('../', import.meta.url);
const selected = process.argv.slice(2);
for (const id of selected)
  if (!catalog.some((e) => e.id === id)) throw Error('Unknown example: ' + id);
if (
  (!selected.length || selected.includes('iron_yard')) &&
  process.env.STUDIO_IRON_YARD_BUILT !== '1'
) {
  // This public task is also usable on a clean checkout. build-games already built IRON YARD.
  const result = spawnSync('just', ['iron-yard-editor-build'], {
    cwd: new URL('../../../', import.meta.url),
    stdio: 'inherit',
  });
  if (result.status !== 0) process.exit(result.status ?? 1);
}
const destination = new URL('public/examples/', studio);
// Full builds own this generated directory; remove retired projects as well.
if (!selected.length) await rm(destination, { recursive: true, force: true });
await mkdir(destination, { recursive: true });
const wrapper = new URL('public/example-runtime/', studio);
await mkdir(new URL('lib/', wrapper), { recursive: true });
copyWebRuntimeAssets(new URL('lib/', wrapper));
for (const file of ['runtime.mjs', 'assets.mjs', 'index.html'])
  await cp(new URL('examples/' + file, studio), new URL(file, wrapper));

for (const item of catalog.filter((e) => !selected.length || selected.includes(e.id))) {
  const dir = catalogProjectDir(item);
  const manifest = validateProject(JSON.parse(await readFile(join(dir, item.manifest))));
  const settings = projectBuild(manifest, item.id);
  if (
    manifest.runtime?.kind === 'script' ||
    (!manifest.runtime && item.id !== 'iron_yard' && item.preview === 'webgpu')
  ) {
    console.log('Building Studio example: ' + item.id);
    const result = spawnSync(
      'moon',
      ['build', settings.package, '--target', 'js', '--' + (settings.editorMode ?? 'release')],
      {
        cwd: dir,
        stdio: 'inherit',
      },
    );
    if (result.status !== 0) process.exit(result.status ?? 1);
    if (settings.scenePackage) {
      const scenes = spawnSync(
        'moon',
        ['build', settings.scenePackage, '--target', 'js', '--release'],
        { cwd: dir, stdio: 'inherit' },
      );
      if (scenes.status !== 0) process.exit(scenes.status ?? 1);
    }
    if (item.id === 'hacknslash_3d') {
      const headless = spawnSync('moon', ['build', 'scene_api', '--target', 'js', '--release'], {
        cwd: dir,
        stdio: 'inherit',
      });
      if (headless.status !== 0) process.exit(headless.status ?? 1);
    }
    const artifact = resolveBuildArtifact(
      join(dir, '_build/js/' + (settings.editorMode ?? 'release') + '/build/' + settings.artifact),
    );
    if (!artifact) throw Error('Missing browser artifact for ' + item.id);
    await mkdir(dirname(join(dir, runtimeEntry(manifest))), { recursive: true });
    await cp(artifact, join(dir, runtimeEntry(manifest)));
  }
  const out = new URL(item.id + '/', destination);
  await rm(out, { recursive: true, force: true });
  await mkdir(out, { recursive: true });
  const files = [
    item.manifest,
    manifest.scene,
    ...Object.values(manifest.scenes ?? {}),
    ...Object.values(manifest.resources),
  ];
  if (manifest.editor?.entry) files.push(manifest.editor.entry);
  if (runtimeEntry(manifest)) files.push(runtimeEntry(manifest));
  for (const file of new Set(files)) {
    const target = new URL(packagedPath(file), out);
    await mkdir(new URL('.', target), { recursive: true });
    await cp(join(dir, file), target);
  }
  await writeFile(new URL('files.json', out), JSON.stringify([...new Set(files)]));
}
// Publish only complete builds; a selected build never advertises missing examples.
const built = [];
for (const item of catalog) {
  try {
    await readFile(new URL(item.id + '/files.json', destination));
    built.push(item);
  } catch {}
}
await writeFile(new URL('catalog.json', destination), JSON.stringify(built));
