import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import * as THREE from 'three';
import { createSceneGrid } from '../web/scene-grid.mjs';

function segments(grid) {
  grid.updateMatrixWorld(true);
  const positions = grid.geometry.getAttribute('position');
  const result = [];
  for (let i = 0; i < positions.count; i += 2) {
    result.push([i, i + 1].map(index =>
      new THREE.Vector3().fromBufferAttribute(positions, index).applyMatrix4(grid.matrixWorld),
    ));
  }
  return result;
}

function dispose(grid) {
  grid.geometry.dispose();
  grid.material.dispose();
}

test('Hack & Slash grid covers every floor tile without moving the authored stage', async () => {
  const doc = JSON.parse(await readFile(new URL(
    '../../../examples/games/hacknslash_3d/scenes/training.kgrscene', import.meta.url,
  ), 'utf8'));
  const floor = doc.nodes.find(node => node.id === 'floor');
  const center = new THREE.Vector3().fromArray(floor.position);
  const bounds = new THREE.Box3().setFromCenterAndSize(center, new THREE.Vector3().fromArray(floor.scale));
  const before = bounds.clone();
  const grid = createSceneGrid(bounds);
  const lines = segments(grid);
  for (let x = bounds.min.x; x <= bounds.max.x; x++) {
    assert.ok(lines.some(([a, b]) => a.x === x && b.x === x && a.z <= bounds.min.z && b.z >= bounds.max.z), `missing tile column ${x}`);
  }
  for (let z = bounds.min.z; z <= bounds.max.z; z++) {
    assert.ok(lines.some(([a, b]) => a.z === z && b.z === z && a.x <= bounds.min.x && b.x >= bounds.max.x), `missing tile row ${z}`);
  }
  assert.ok(lines.flat().every(point => Math.abs(point.y - (bounds.max.y + 0.01)) < 1e-6));
  assert.ok(bounds.equals(before));
  dispose(grid);
});

test('fractional scene centers preserve integer world grid lines and world origin axes', () => {
  const grid = createSceneGrid(new THREE.Box3(
    new THREE.Vector3(-3.3, -0.5, -2.1), new THREE.Vector3(6.2, 4, 5.6),
  ));
  const lines = segments(grid);
  const colors = grid.geometry.getAttribute('color');
  const axis = new THREE.Color(0x697784);
  lines.forEach(([a, b], index) => {
    assert.ok([a.x, a.z, b.x, b.z].every(Number.isInteger));
    const isAxis = (a.x === 0 && b.x === 0) || (a.z === 0 && b.z === 0);
    const color = new THREE.Color().fromBufferAttribute(colors, index * 2);
    assert.equal(color.r === Math.fround(axis.r), isAxis, 'highlight axes only at world zero');
    assert.ok(Math.abs(a.y - 0.01) < 1e-6, 'ground stays at Y=0 below elevated objects');
  });
  dispose(grid);
});

test('grid fits transformed hierarchy bounds and can shrink when the scene changes', () => {
  const root = new THREE.Group();
  root.position.set(90, 0, -70);
  root.rotation.y = Math.PI / 4;
  const mesh = new THREE.Mesh(new THREE.BoxGeometry(12, 1, 5));
  mesh.position.set(4, -0.5, 3);
  root.add(mesh);
  const bounds = new THREE.Box3().setFromObject(root);
  const grid = createSceneGrid(bounds);
  const gridBounds = new THREE.Box3().setFromPoints(segments(grid).flat());
  assert.ok(gridBounds.min.x < bounds.min.x && gridBounds.max.x > bounds.max.x);
  assert.ok(gridBounds.min.z < bounds.min.z && gridBounds.max.z > bounds.max.z);
  const empty = createSceneGrid(new THREE.Box3());
  const emptyBounds = new THREE.Box3().setFromPoints(segments(empty).flat());
  assert.equal(emptyBounds.min.x, -20);
  assert.equal(emptyBounds.max.z, 20);
  dispose(grid);
  dispose(empty);
  mesh.geometry.dispose();
  mesh.material.dispose();
});

test('very large scenes use coarser world-aligned lines with bounded geometry', () => {
  const bounds = new THREE.Box3(new THREE.Vector3(-1e6, 0, -1e6), new THREE.Vector3(1e6, 1, 1e6));
  const grid = createSceneGrid(bounds);
  const lines = segments(grid);
  assert.ok(lines.length <= 404);
  const gridBounds = new THREE.Box3().setFromPoints(lines.flat());
  assert.ok(gridBounds.min.x <= bounds.min.x && gridBounds.max.x >= bounds.max.x);
  assert.ok(gridBounds.min.z <= bounds.min.z && gridBounds.max.z >= bounds.max.z);
  assert.ok(lines.flat().every(point => [point.x, point.y, point.z].every(Number.isFinite)));
  dispose(grid);
});
