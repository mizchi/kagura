import { spawnSync } from 'node:child_process';
import { cp, mkdir } from 'node:fs/promises';
import { resolveBuildArtifact } from '../../../scripts/moon-build-artifact-utils.mjs';
import { fileURLToPath } from 'node:url';
const moduleRoot = new URL('../../model-viewer/', import.meta.url);
const result = spawnSync('moon', ['build', '.', '--target', 'js', '--release'], {
  cwd: moduleRoot,
  stdio: 'inherit',
});
if (result.status !== 0) process.exit(result.status ?? 1);
const target = new URL('../public/model-runtime/', import.meta.url);
await mkdir(new URL('lib/', target), { recursive: true });
const artifact = resolveBuildArtifact(
  fileURLToPath(new URL('_build/js/release/build/studio_model_viewer.js', moduleRoot)),
);
if (!artifact) throw Error('Missing model viewer build');
await cp(artifact, new URL('model-viewer.js', target));
for (const name of ['runtime.mjs', 'index.html'])
  await cp(new URL('../assets/' + name, import.meta.url), new URL(name, target));
for (const name of ['kagura-init.js', 'kagura-gfx.js'])
  await cp(new URL('../../../assets/web/' + name, import.meta.url), new URL('lib/' + name, target));
