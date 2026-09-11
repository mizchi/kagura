import { pathToFileURL, fileURLToPath } from 'node:url';
import { resolveBuildArtifact } from '../../../../scripts/moon-build-artifact-utils.mjs';
import { compileScene } from './scene.mjs';
const artifact = resolveBuildArtifact(
  fileURLToPath(new URL('../_build/js/release/build/scene_api.js', import.meta.url)),
);
if (!artifact)
  throw Error(
    'Build scene API first: moon -C examples/games/hacknslash_3d build scene_api --target js --release',
  );
const api = await import(pathToFileURL(artifact));
export function createSceneRuntime(document) {
  const recipe = compileScene(document),
    world = api.create(JSON.stringify(recipe.data));
  return Object.freeze({
    snapshot: () => JSON.parse(api.snapshot(world)),
    blocked(x, z) {
      if (![x, z].every(Number.isFinite)) throw Error('Expected finite coordinates');
      return api.blocked(world, x, z);
    },
    step(x = 0, z = 0) {
      if (![x, z].every((v) => Number.isFinite(v) && Math.abs(v) <= 1))
        throw Error('Movement must be between -1 and 1');
      api.step(world, x, z);
      return JSON.parse(api.snapshot(world));
    },
  });
}
