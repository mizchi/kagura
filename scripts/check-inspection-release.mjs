import assert from 'node:assert/strict';
import { renderHeadlessFrame } from '../assets/web/kagura-headless-frame.js';
import { spawnSync } from 'node:child_process';
import { readFileSync, statSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { resolveBuildArtifact } from './moon-build-artifact-utils.mjs';
import { assertInspectionArtifact } from './inspection-artifact.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));
const dir = resolve(root, 'examples/games/flappy_bird');
const target = process.argv[2] ?? 'js';
if (!['js', 'native'].includes(target)) throw Error('Expected js or native');
for (const [module, file] of [
  ['game', 'inspection/control_release_wbtest.mbt'],
  ['game', 'scene/inspection_release_wbtest.mbt'],
  ['engine/kagura_engine', 'scene3d/inspection_release_wbtest.mbt'],
]) {
  const result = spawnSync('moon', ['test', file, '--target', target, '--release'], {
    cwd: resolve(root, module),
    stdio: 'inherit',
  });
  if (result.status !== 0) throw Error('Release inspection contract failed');
}
function build(target, mode) {
  const result = spawnSync('moon', ['build', '.', '--target', target, '--' + mode, '--deny-warn'], {
    cwd: dir,
    stdio: 'inherit',
  });
  if (result.status !== 0) throw Error('Inspection artifact build failed');
  const file = resolveBuildArtifact(
    resolve(dir, `_build/${target}/${mode}/build/flappy_bird.${target === 'js' ? 'js' : 'c'}`),
  );
  if (!file) throw Error('Missing compiler artifact');
  const source = readFileSync(file, 'utf8');
  assertInspectionArtifact(source, mode);
  return { target, mode, bytes: statSync(file).size, file };
}
// The debug artifact must prove that the gate can see every feature it forbids.
const debug = build('js', 'debug');
const release = build(target, 'release');
const compared = [];
if (target === 'js') {
  for (const scenario of [{ frames: 1 }, { frames: 30, keys: [32] }, { frames: 180, keys: [32] }]) {
    const a = await renderHeadlessFrame(debug.file, scenario);
    assert.ok(globalThis.kaguraDebugAdapter, 'debug build must register its adapter');
    delete globalThis.kaguraDebugAdapter;
    delete globalThis.kaguraSceneRuntime;
    const b = await renderHeadlessFrame(release.file, scenario);
    assert.equal(globalThis.kaguraDebugAdapter, undefined);
    assert.equal(globalThis.kaguraSceneRuntime, undefined);
    assert.ok(a.drawnTriangles > 0);
    assert.equal(b.drawnTriangles, a.drawnTriangles);
    assert.deepEqual(b.png, a.png, 'inspection stripping changed the rendered game');
    compared.push(scenario);
  }
}
console.log(
  JSON.stringify({ debug, release, inspectionRemoved: true, identicalFrames: compared }, null, 2),
);
