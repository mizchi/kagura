// End-to-end check of `kagura scene3d`: the Node host reads the file and the
// MoonBit analysis (cmd/inspect3d) answers. Run after just cli-build.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import test from 'node:test';

const main = resolve(import.meta.dirname, '../cmd/kagura/main.mjs');
const box = (center) => ({center, half_extents: [0.5, 0.5, 0.5], rotation: [0, 0, 0, 1]});
const node = (path, subject, center) => ({
  path, name: path, kind: 'mesh', subject, position: center, rotation: [0, 0, 0, 1], scale: [1, 1, 1], box: box(center),
});
const snapshot = {
  schema: 'kagura.scene3d-snapshot', version: 1,
  camera: {position: [0, 0, 10], target: [0, 0, 0], up: [0, 1, 0], near: 0.1, far: 100,
    projection: {kind: 'perspective', fov_y_rad: 1.0472, aspect: 1}},
  nodes: [node('world/player', 'player', [0, 0, 0]), node('world/enemy', 'enemy', [0.5, 0, 0]),
    node('world/crate', null, [3, 0, 0]), node('world/behind', null, [0, 0, 30])],
};
const file = join(mkdtempSync(join(tmpdir(), 'kagura-scene3d-')), 'scene.scene3d.json');
writeFileSync(file, JSON.stringify(snapshot));
const kagura = (...args) => spawnSync(process.execPath, [main, ...args], {encoding: 'utf8'});

test('check fails on unallowed findings and passes once each is allowed', () => {
  const failing = kagura('scene3d', 'check', file);
  assert.equal(failing.status, 1);
  assert.match(failing.stdout, /overlap: world\/player \(player\) overlaps world\/enemy \(enemy\)/);
  assert.match(failing.stdout, /outside_view: world\/behind/);
  const passing = kagura('scene3d', 'check', file, '--allow', 'overlap', '--allow', 'outside_view@world/behind');
  assert.equal(passing.status, 0, passing.stdout);
  const stale = kagura('scene3d', 'check', file, '--allow', 'overlap', '--allow', 'outside_view', '--allow', 'zero_scale');
  assert.equal(stale.status, 1);
  assert.match(stale.stdout, /unused allow rule: "zero_scale"/);
});

test('distance, overlaps and raycast answer from the snapshot', () => {
  const distance = JSON.parse(kagura('scene3d', 'distance', file, 'world/player', 'world/crate', '--json').stdout);
  assert.equal(distance.distance, 2);
  assert.equal(distance.intersecting, false);
  assert.deepEqual(JSON.parse(kagura('scene3d', 'overlaps', file, '--json').stdout).pairs, [['world/player', 'world/enemy']]);
  const ray = JSON.parse(kagura('scene3d', 'raycast', file, '--from', '-10,0,0', '--direction', '1,0,0', '--json').stdout);
  assert.deepEqual(ray.hits.map(hit => hit.path), ['world/player', 'world/enemy', 'world/crate']);
  assert.equal(ray.hits[0].distance, 9.5);
});

test('bad input is reported without a stack trace', () => {
  const missing = kagura('scene3d', 'distance', file, 'world/player', 'world/none');
  assert.equal(missing.status, 1);
  assert.match(missing.stderr, /world\/none: no mesh at or below this path/);
  assert.doesNotMatch(missing.stderr, /\.mbt:/);
  const usage = kagura('scene3d', 'raycast', file, '--from', '0,0,0');
  assert.equal(usage.status, 2);
  assert.match(usage.stderr, /needs --from x,y,z and --direction x,y,z/);
});
