import { test } from 'node:test';
import assert from 'node:assert/strict';
import { openProject, validateProject } from '../projects/project.mjs';
const manifest = {
  format: 'kagura.project',
  version: 1,
  name: 'Multi-scene',
  entryScene: 'a',
  scenes: { a: 'scenes/a.kgrscene', b: 'scenes/b.kgrscene' },
  resources: {},
};
test('named scenes resolve relative to the project and save to their own file', async () => {
  const files = new Map(
    [
      ['p/test.kgrprj', manifest],
      ['p/scenes/a.kgrscene', { name: 'A' }],
      ['p/scenes/b.kgrscene', { name: 'B' }],
    ].map(([k, v]) => [k, new Blob([JSON.stringify(v)])]),
  );
  const store = {
    read: async (key) => ({ blob: files.get(key) }),
    write: async (key, blob) => files.set(key, blob),
  };
  const project = await openProject(store, 'p/test.kgrprj');
  assert.deepEqual(await project.readScene(), { name: 'A' });
  assert.deepEqual(await project.readScene('b'), { name: 'B' });
  await project.saveScene({ name: 'Edited B' }, 'b');
  assert.deepEqual(await project.readScene('b'), { name: 'Edited B' });
  assert.deepEqual(await project.readScene('a'), { name: 'A' });
  await assert.rejects(project.readScene('../escape'));
  for (const patch of [
    { entryScene: 'absent' },
    { scenes: { a: '../outside' } },
    { scenes: { a: 'a.json', b: 'a.json' } },
  ])
    assert.throws(() => validateProject({ ...manifest, ...patch }));
});
