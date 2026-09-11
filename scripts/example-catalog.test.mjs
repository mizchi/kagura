import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { catalog, catalogProjectDir } from './example-catalog.mjs';
import { listExampleNames, EXAMPLE_ROOT } from './example-dirs.mjs';

test('the catalog separates code examples from one shared model asset project', () => {
  assert.equal(new Set(catalog.map((e) => e.id)).size, catalog.length);
  assert.ok(!catalog.some((e) => ['gltf_viewer', 'obj_viewer'].includes(e.id)));
  const models = catalog.find((e) => e.id === 'model_assets');
  assert.equal(models.category, 'assets');
  assert.equal(models.preview, 'asset');
  assert.ok(existsSync(join(catalogProjectDir(models), models.manifest)));
  assert.ok(!existsSync(join(catalogProjectDir(models), 'moon.mod')));
  const code = listExampleNames([EXAMPLE_ROOT.examples]);
  assert.ok(!code.includes('model_assets'));
  for (const entry of catalog) {
    assert.ok(entry.purpose.trim().length > 8, entry.id);
    assert.ok(existsSync(join(catalogProjectDir(entry), entry.manifest)), entry.id);
    if (entry.category !== 'assets') assert.ok(code.includes(entry.id), entry.id);
  }
});

test('catalog paths cannot escape the known example categories', () => {
  const valid = catalog[0];
  for (const patch of [{ id: '../bad' }, { category: '..' }, { manifest: '../bad.kgrprj' }])
    assert.throws(() => catalogProjectDir({ ...valid, ...patch }));
});
