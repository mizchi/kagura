import { runtimeEntry } from '../projects/settings.mjs';
import { decodeSceneFile } from '../scene/moonbit.mjs';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, access } from 'node:fs/promises';
import { join } from 'node:path';
import {
  EXAMPLE_ROOT,
  listExampleNames,
  findExampleCategory,
  findExampleDir,
} from '../../../scripts/example-dirs.mjs';
import { validateProject } from '../projects/project.mjs';
import { createHeadlessEditor } from '../headless/index.mjs';
import {
  validateLaunch,
  readLaunch,
  launchCommand,
  invokeLaunch,
  launchTools,
} from '../examples/contract.mjs';
import { createPluginHost } from '../plugins/host.mjs';
import { defineJSPlugin } from '../plugins/adapters.mjs';
import { assetURL } from '../examples/assets.mjs';

test('every game and demo has a loadable project with a shared scene or its own extension', async () => {
  const catalog = JSON.parse(await readFile(new URL('../examples/catalog.json', import.meta.url)));
  const names = listExampleNames([EXAMPLE_ROOT.examples]).filter((n) =>
    ['games', 'demos-2d', 'demos-3d'].includes(findExampleCategory(n, [EXAMPLE_ROOT.examples])),
  );
  assert.deepEqual(catalog.map((e) => e.id).sort(), names);
  for (const item of catalog) {
    const dir = findExampleDir(item.id, [EXAMPLE_ROOT.examples]);
    const manifest = validateProject(JSON.parse(await readFile(join(dir, item.manifest))));
    assert.equal(manifest.game, item.id);
    assert.equal(manifest.id, 'mizchi.kagura.examples.' + item.id);
    assert.equal(manifest.save.namespace, manifest.id);
    assert.deepEqual(manifest.display, { width: item.width, height: item.height });
    const pkg = await readFile(join(dir, manifest.build.package, 'moon.pkg'), 'utf8');
    if (item.preview !== 'asset') assert.deepEqual(
      manifest.runtime.targets,
      pkg.match(/supported_targets\s*=\s*"([^"]+)"/)[1].split('+'),
    );
    const doc = decodeSceneFile(manifest.scene, await readFile(join(dir, manifest.scene), 'utf8'));
    if (item.id === 'iron_yard') {
      assert.equal(manifest.editor.id, 'iron-yard');
      continue;
    }
    if (item.preview === 'asset') {
      assert.equal(manifest.editor.id, 'kagura.scene');
      assert.equal(manifest.runtime, undefined);
      assert.deepEqual(createHeadlessEditor(doc).snapshot().document.resources, []);
      for (const path of Object.values(manifest.resources)) await access(join(dir, path));
      continue;
    }
    const twoD =
      item.category === 'demos-2d' ||
      ['action_rpg', 'card_game', 'flappy_bird', 'hacknslash', 'survivor'].includes(item.id);
    assert.equal(
      manifest.editor.id,
      item.id === 'flappy_bird'
        ? 'flappy-bird'
        : twoD
          ? 'kagura.example2d'
          : ['hacknslash_3d', 'arena3d', 'fps_demo'].includes(item.id)
            ? item.id.replaceAll('_', '-')
            : 'kagura.example',
    );
    assert.equal(readLaunch(createHeadlessEditor(doc).snapshot()).example, item.id);
    if (['hacknslash_3d', 'arena3d', 'fps_demo'].includes(item.id)) assert.ok(doc.nodes.length > 0);
    else assert.equal(doc.nodes.length, 0, 'do not invent an unrelated game level');
    assert.equal(!!runtimeEntry(manifest), item.preview === 'webgpu');
    for (const path of Object.values(manifest.resources)) {
      if (path !== runtimeEntry(manifest)) await access(join(dir, path));
    }
  }
});

test('launch settings are headless, undoable, validated and use the existing transaction contract', async () => {
  const editor = createHeadlessEditor();
  const config = {
    example: 'hacknslash_3d',
    query: { mute: true, shadows: true, stress_enemies: 25 },
  };
  const before = editor.snapshot();
  assert.equal(
    editor.dispatch({ expectedRevision: before.revision, commands: [launchCommand(config)] }).ok,
    true,
  );
  const host = createPluginHost(editor);
  host.register(
    defineJSPlugin({
      manifest: { apiVersion: 1, id: 'studio.example', title: 'Example', tools: launchTools },
      invoke: (r) => invokeLaunch(r.tool, r.arguments, r.snapshot),
    }),
  );
  assert.equal((await host.invoke('studio.example', 'launch_read', {})).ok, true);
  host.dispose();
  const reply = await invokeLaunch('launch_update', { query: { mute: false } }, editor.snapshot());
  assert.equal(
    editor.dispatch({ expectedRevision: editor.snapshot().revision, commands: reply.commands }).ok,
    true,
  );
  assert.equal(readLaunch(editor.snapshot()).query.mute, false);
  editor.undo(editor.snapshot().revision);
  assert.deepEqual(readLaunch(editor.snapshot()), config);
  for (const query of [{ x: {} }, { x: Infinity }, { 'bad key': true }])
    assert.throws(() => validateLaunch({ ...config, query }));
  assert.throws(() => validateLaunch({ ...config, example: '../outside' }));
  assert.throws(() => validateLaunch({ ...config, extra: true }));
});

test('runtime assets resolve within the project, leaving external fetches and request objects intact', () => {
  const base = 'http://localhost/example-runtime/index.html';
  const assets = { 'assets/model.glb': 'blob:local-model' };
  assert.equal(assetURL('./assets/model.glb', base, assets), 'blob:local-model');
  assert.equal(assetURL('https://remote.test/assets/model.glb', base, assets), null);
  assert.equal(assetURL('../assets/model.glb', base, assets), null);
  assert.equal(assetURL('assets/missing.glb', base, assets), null);
});
