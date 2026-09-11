import { test, expect } from '@playwright/test';

test('generic model preview changes resources, preserves documents and releases on pane/project changes', async ({
  page,
}) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('gltf_viewer');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.getByRole('button', { name: 'Play', exact: true })).toBeDisabled();
  const before = await page.evaluate(() => kagura.snapshot());
  await page.getByRole('button', { name: 'assets/test_scene.glb', exact: true }).click();
  await expect(page.locator('.model-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await expect(page.getByLabel('Model information')).toContainText('triangles');
  const gpu = await page
    .frameLocator('.model-frame')
    .locator('body')
    .evaluate(() => ({
      error: __kaguraWebRuntime.webgpu.lastError,
      renderer: !!__kaguraWebRuntime.webgpu.device,
    }));
  expect(gpu.error).toBeFalsy();
  expect(gpu.renderer).toBe(true);
  await page.screenshot({ path: '/tmp/kgr-model-preview.png' });
  await page.getByLabel('Model resource').selectOption('assets/RiggedFigure.glb');
  await expect(page.locator('.model-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  expect((await page.evaluate(() => kagura.assets.snapshot())).path).toBe(
    'assets/RiggedFigure.glb',
  );
  const after = await page.evaluate(() => kagura.snapshot());
  expect(after.document).toEqual(before.document);
  expect(after.revision).toBe(before.revision);
  await page.getByRole('tab', { name: 'Project', exact: true }).click();
  await expect(page.locator('.model-frame')).toHaveCount(0);
  expect((await page.evaluate(() => kagura.assets.snapshot())).state).toBe('idle');
  await page.evaluate(() => kagura.assets.preview('assets/test_scene.glb'));
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.locator('.model-frame')).toHaveCount(0);
  expect(errors).toEqual([]);
});

test('missing and superseded model loads cannot publish stale previews', async ({ page }) => {
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('gltf_viewer');
  await expect(page.getByRole('status')).toContainText('Opened project');
  const error = await page.evaluate(async () => {
    try {
      await kagura.assets.preview('assets/missing.glb');
    } catch (e) {
      return e.message;
    }
  });
  expect(error).toBeTruthy();
  await expect(page.locator('.model-frame')).toHaveCount(0);
  const states = await page.evaluate(async () => {
    const a = kagura.assets.preview('assets/RiggedFigure.glb').catch((e) => e.name);
    const b = kagura.assets.preview('assets/test_scene.glb');
    return [await a, await b];
  });
  expect(states[0]).toBe('AbortError');
  expect(states[1].path).toBe('assets/test_scene.glb');
  await page.evaluate(() => kagura.assets.close());
  await expect(page.locator('.model-frame')).toHaveCount(0);
});

test('a generic local project previews glTF with an external buffer without an example extension', async ({
  page,
}) => {
  const { prepareModel } = await import('../assets/model.mjs');
  const { readFile } = await import('node:fs/promises');
  const model = await prepareModel(
    {
      read: async () =>
        new Blob([
          await readFile(
            new URL(
              '../../../examples/demos-3d/gltf_viewer/assets/test_scene.glb',
              import.meta.url,
            ),
          ),
        ]),
    },
    'model.glb',
  );
  const json = JSON.parse(model.json);
  json.buffers[0].uri = '../shared/geometry.bin';
  await page.goto('/');
  await page.evaluate(
    async ({ json, binary }) => {
      const root = await (
        await navigator.storage.getDirectory()
      ).getDirectoryHandle('model-project', { create: true });
      async function write(path, bytes) {
        const parts = path.split('/');
        let dir = root;
        for (const part of parts.slice(0, -1))
          dir = await dir.getDirectoryHandle(part, { create: true });
        const stream = await (
          await dir.getFileHandle(parts.at(-1), { create: true })
        ).createWritable();
        await stream.write(bytes);
        await stream.close();
      }
      await write(
        'local.kgrprj',
        JSON.stringify({
          format: 'kagura.project',
          version: 1,
          name: 'Local models',
          scene: 'editor/scene.json',
          resources: { model: 'models/robot.gltf' },
        }),
      );
      await write('editor/scene.json', JSON.stringify(kagura.snapshot().document));
      await write('models/robot.gltf', JSON.stringify(json));
      await write('shared/geometry.bin', new Uint8Array(binary));
      window.showDirectoryPicker = async () => root;
    },
    { json, binary: [...model.buffers[0]] },
  );
  await page.getByRole('button', { name: 'Open project', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Opened project · Local models');
  await page.getByRole('button', { name: 'models/robot.gltf', exact: true }).click();
  await expect(page.locator('.model-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  expect((await page.evaluate(() => kagura.assets.snapshot())).stats.triangles).toBeGreaterThan(0);
  await expect(page.getByLabel('Model preview workspace')).toBeVisible();
  await page.getByRole('button', { name: 'Close model', exact: true }).click();
  await expect(page.locator('.model-frame')).toHaveCount(0);
});
