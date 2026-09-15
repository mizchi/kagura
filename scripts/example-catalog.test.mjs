import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { catalog, catalogProjectDir } from './example-catalog.mjs';
import { listExampleNames, EXAMPLE_ROOT } from './example-dirs.mjs';
import { DEMO_PAGES } from './web-demo-pages.mjs';
import { FRAME_VRT_ENTRIES } from './frame-vrt-manifest.mjs';
import { UI_MATRIX_EXAMPLES } from './ui-matrix-manifest.mjs';

test('the catalog separates code examples from one shared model asset project', () => {
  assert.equal(new Set(catalog.map((e) => e.id)).size, catalog.length);
  assert.ok(!catalog.some((e) => ['gltf_viewer', 'obj_viewer', 'action_rpg', 'hacknslash', 'fps_demo'].includes(e.id)));
  const models = catalog.find((e) => e.id === 'model_assets');
  assert.equal(models.category, 'assets');
  assert.equal(models.preview, 'asset');
  assert.ok(existsSync(join(catalogProjectDir(models), models.manifest)));
  assert.ok(!existsSync(join(catalogProjectDir(models), 'moon.mod')));
  const code = listExampleNames([EXAMPLE_ROOT.examples]);
  assert.ok(!code.includes('model_assets'));
  for (const entry of catalog) {
    assert.ok(['game', 'demo', 'asset'].includes(entry.kind), entry.id);
    assert.ok(entry.purpose.trim().length > 8, entry.id);
    assert.ok(existsSync(join(catalogProjectDir(entry), entry.manifest)), entry.id);
    if (entry.category !== 'assets') assert.ok(code.includes(entry.id), entry.id);
  }
  assert.deepEqual(catalog.filter(entry => entry.kind === 'game').map(entry => entry.id).sort(), ['emberwing', 'hacknslash_3d', 'iron_yard']);
  assert.equal(models.kind, 'asset');
});

test('public game builds and visual test targets reference existing examples', () => {
  const code = listExampleNames([EXAMPLE_ROOT.examples]);
  for (const retired of ['action_rpg', 'hacknslash', 'fps_demo']) assert.ok(!code.includes(retired), retired);
  const targets = new Set([
    ...DEMO_PAGES.filter(demo => demo.sourcePath.startsWith('examples/games/')).map(demo => demo.name),
    ...FRAME_VRT_ENTRIES.map(entry => entry.example),
    ...UI_MATRIX_EXAMPLES,
  ]);
  for (const name of targets) assert.ok(code.includes(name), name);
});

test('catalog paths cannot escape the known example categories', () => {
  const valid = catalog[0];
  for (const patch of [{ id: '../bad' }, { category: '..' }, { manifest: '../bad.kgrprj' }])
    assert.throws(() => catalogProjectDir({ ...valid, ...patch }));
});
