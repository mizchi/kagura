import { test } from 'node:test';
import assert from 'node:assert/strict';
import { prepareModel, modelFormat, dependencyPath } from '../assets/model.mjs';
import { readFile } from 'node:fs/promises';

test('model resources resolve sibling buffers inside the project root', async () => {
  assert.equal(modelFormat('models/Robot.GLB'), 'glb');
  assert.equal(modelFormat('notes.json'), null);
  assert.equal(
    dependencyPath('models/robot/model.gltf', '../shared/body.bin'),
    'models/shared/body.bin',
  );
  for (const uri of [
    '../../../secret',
    '/absolute',
    'https://example.com/a',
    '//host/a',
    '%2e%2e/x',
    'a?x',
    'a\\b',
  ])
    assert.throws(() => dependencyPath('models/model.gltf', uri));
  const reads = [];
  const model = await prepareModel(
    {
      async read(path) {
        reads.push(path);
        return path.endsWith('.gltf')
          ? new Blob([
              JSON.stringify({
                asset: { version: '2.0' },
                buffers: [{ uri: '../shared/body.bin', byteLength: 4 }],
              }),
            ])
          : new Blob([new Uint8Array([1, 2, 3, 4])]);
      },
    },
    'models/robot/model.gltf',
  );
  assert.deepEqual(reads, ['models/robot/model.gltf', 'models/shared/body.bin']);
  assert.deepEqual([...model.buffers[0]], [1, 2, 3, 4]);
});

test('GLB and OBJ sample resources prepare without the example runtime', async () => {
  const reader = {
    async read(path) {
      return new Blob([
        await readFile(new URL('../../../examples/demos-3d/' + path, import.meta.url)),
      ]);
    },
  };
  const glb = await prepareModel(reader, 'gltf_viewer/assets/test_scene.glb');
  assert.equal(glb.format, 'gltf');
  assert.ok(JSON.parse(glb.json).meshes.length > 0);
  assert.ok(glb.buffers[0].byteLength > 0);
  const obj = await prepareModel(reader, 'obj_viewer/assets/bunny.obj');
  assert.equal(obj.format, 'obj');
  assert.match(obj.text, /^v /m);
});

test('malformed GLB, missing/truncated buffers and unsupported required features fail explicitly', async () => {
  const load = (doc, path = 'model.gltf', extra = new Blob()) =>
    prepareModel(
      {
        read: async (p) =>
          p === path
            ? new Blob([
                typeof doc === 'object' && !(doc instanceof Uint8Array) ? JSON.stringify(doc) : doc,
              ])
            : extra,
      },
      path,
    );
  await assert.rejects(load(new Uint8Array(20), 'model.glb'), /GLB/);
  await assert.rejects(load({ asset: { version: '1.0' } }), /version/);
  await assert.rejects(load({ asset: { version: '2.0' }, buffers: [{ byteLength: 4 }] }), /buffer/);
  await assert.rejects(
    load({ asset: { version: '2.0' }, buffers: [{ uri: 'mesh.bin', byteLength: 4 }] }),
    /buffer/,
  );
  await assert.rejects(
    load({ asset: { version: '2.0' }, extensionsRequired: ['KHR_draco_mesh_compression'] }),
    /KHR_draco/,
  );
  await assert.rejects(load({ asset: { version: '2.0' }, nodes: [{ children: [0] }] }), /cycle/);
  const embedded = await load({
    asset: { version: '2.0' },
    buffers: [{ uri: 'data:application/octet-stream;base64,AQIDBA==', byteLength: 4 }],
    images: [{}],
    animations: [{}],
  });
  assert.deepEqual([...embedded.buffers[0]], [1, 2, 3, 4]);
  assert.ok(embedded.warnings.length >= 2);
});

test('model hierarchy limits apply regardless of node ordering and repeated children', async () => {
  const load = (nodes) =>
    prepareModel(
      { read: async () => new Blob([JSON.stringify({ asset: { version: '2.0' }, nodes })]) },
      'a.gltf',
    );
  await assert.rejects(load([{ children: [2] }, { children: [2] }, {}]), /multiple parents/);
  await assert.rejects(
    load(Array.from({ length: 130 }, (_, id) => ({ children: id ? [id - 1] : [] }))),
    /128 levels/,
  );
});
