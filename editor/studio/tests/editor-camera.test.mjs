import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  pick,
  ray,
  orbitCamera,
  frameCamera,
} from '../../../examples/games/iron_yard/editor/ui/camera.mjs';
test('editor camera picking respects nearest authored bounds and orbit/frame targets', () => {
  const camera = { eye: [0, 4, -20], target: [0, 4, 0] };
  const bounds = [
    { id: 'far', center: [0, 4, 10], size: [6, 8, 6] },
    { id: 'near', center: [0, 4, 0], size: [6, 8, 6] },
  ];
  assert.equal(pick(ray(camera, 0, 0, 1), bounds), 'near');
  assert.equal(pick(ray(camera, 1, 1, 1), bounds), null);
  assert.deepEqual(frameCamera(camera, bounds[0]).target, [0, 4, 10]);
  const moved = orbitCamera(camera, 0.5, 0.3);
  assert.ok(moved.eye.every(Number.isFinite));
  assert.deepEqual(moved.target, camera.target);
});
