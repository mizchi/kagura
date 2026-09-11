import { test, expect } from '@playwright/test';
import { readFile } from 'node:fs/promises';
const catalog = JSON.parse(await readFile(new URL('../examples/catalog.json', import.meta.url)));

test('example settings use editor history and WebMCP tools; switching projects disposes their runtime', async ({
  page,
}) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('hacknslash_3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button', { name: 'Example設定', exact: true }).click();
  await page.getByRole('checkbox', { name: 'ミュート', exact: true }).check();
  expect(
    await page.evaluate(
      () =>
        kagura.snapshot().document.resources.find((r) => r.id === 'kagura.example').data.query.mute,
    ),
  ).toBe(true);
  await page.evaluate(() => kagura.undo(kagura.snapshot().revision));
  await expect(page.getByRole('checkbox', { name: 'ミュート', exact: true })).not.toBeChecked();
  const result = await page.evaluate(async () => {
    const tool = kagura.panes
      .tools()
      .find((t) => t.name === 'kagura.pane.studio.example.launch_update');
    return tool.execute({
      arguments: { query: { mute: true, autoplay: true } },
      expectedRevision: kagura.snapshot().revision,
    });
  });
  expect(result.ok).toBe(true);
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  expect(
    await page
      .frameLocator('.game-frame')
      .locator('body')
      .evaluate(() => location.search),
  ).toBe('?mute=true&autoplay=true');
  await page.getByRole('button', { name: '汎用エディタ', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await expect(page.getByLabel('3D scene viewport')).toBeVisible();
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true');
  await page.getByLabel('Examples', { exact: true }).selectOption('flappy_bird');
  await expect(page.getByRole('status')).toContainText('Opened project · Flappy Bird');
  await expect(page.locator('.game-frame')).toHaveCount(0);
  expect(errors).toEqual([]);
});

for (const item of catalog.filter((e) => e.id !== 'iron_yard')) {
  test('open and preview: ' + item.id, async ({ page }) => {
    test.setTimeout(60000);
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    await page.goto('/');
    await page.getByLabel('Examples', { exact: true }).selectOption(item.id);
    await expect(page.getByRole('status')).toContainText('Opened project · ' + item.title, {
      timeout: 30000,
    });
    expect(await page.evaluate(() => kagura.projects.current().manifest.name)).toBe(item.title);
    if (item.preview === 'asset') {
      await expect(page.getByRole('button', { name: 'Play', exact: true })).toBeDisabled();
      const path = await page.evaluate(async () => (await kagura.assets.list())[0]);
      await page.getByRole('button', { name: path, exact: true }).click();
      await expect(page.locator('.model-frame')).toHaveAttribute('data-ready', 'true', { timeout: 30000 });
      expect((await page.evaluate(() => kagura.assets.snapshot())).stats.triangles).toBeGreaterThan(0);
    } else if (item.preview === 'native') {
      await expect(page.getByRole('button', { name: 'Play', exact: true })).toBeDisabled();
      await page.getByRole('button', { name: 'Example設定', exact: true }).click();
      await expect(page.getByText('native専用exampleです。', { exact: false })).toBeVisible();
    } else {
      await page.getByRole('button', { name: 'Play', exact: true }).click();
      await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
        timeout: 30000,
      });
      const state = await page
        .frameLocator('.game-frame')
        .locator('body')
        .evaluate(() => ({
          renderer: kaguraExample.renderer,
          project: kaguraExample.project,
          canvas: [__kaguraWebRuntime.canvas.width, __kaguraWebRuntime.canvas.height],
          fonts: Object.keys(__kaguraWebRuntime.fonts),
          error: __kaguraWebRuntime.webgpu.lastError,
        }));
      expect(state.renderer).toBe('kagura-webgpu');
      expect(state.project.game).toBe(item.id);
      expect(state.project.save.namespace).toBe('mizchi.kagura.examples.' + item.id);
      expect(state.project.display).toEqual({ width: item.width, height: item.height });
      expect(state.canvas.every((v) => v > 0)).toBe(true);
      expect(state.error).toBe('');
      if (['action_rpg', 'draw2d_ui_demo'].includes(item.id))
        expect(state.fonts.length).toBeGreaterThan(0);
      if (item.id === 'hacknslash_3d')
        await page.screenshot({ path: '/tmp/kgr-examples-hacknslash.png' });
      await page.getByRole('button', { name: 'Stop', exact: true }).click();
      await expect(page.locator('.game-frame')).toHaveCount(0);
    }
    expect(errors).toEqual([]);
  });
}

test('a local example folder saves launch settings and reloads its own runtime and font', async ({
  page,
}) => {
  const dir = new URL('../../../examples/demos-2d/draw2d_ui_demo/', import.meta.url);
  const manifest = JSON.parse(await readFile(new URL('draw2d_ui_demo.kgrprj', dir)));
  const paths = [
    'draw2d_ui_demo.kgrprj',
    manifest.scene,
    manifest.runtime.entry,
    ...Object.values(manifest.resources),
  ];
  const files = Object.fromEntries(
    await Promise.all(
      paths.map(async (path) => [path, (await readFile(new URL(path, dir))).toString('base64')]),
    ),
  );
  await page.goto('/');
  await expect(page.getByRole('button', { name: 'Open project', exact: true })).toBeVisible();
  await page.evaluate(async (files) => {
    const root = await (
      await navigator.storage.getDirectory()
    ).getDirectoryHandle('example-' + crypto.randomUUID(), { create: true });
    for (const [path, base64] of Object.entries(files)) {
      let dir = root;
      const parts = path.split('/'),
        name = parts.pop();
      for (const part of parts) dir = await dir.getDirectoryHandle(part, { create: true });
      const stream = await (await dir.getFileHandle(name, { create: true })).createWritable();
      await stream.write(Uint8Array.from(atob(base64), (c) => c.charCodeAt(0)));
      await stream.close();
    }
    window.exampleRoot = root;
    window.showDirectoryPicker = async () => root;
  }, files);
  await page.getByRole('button', { name: 'Open project', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button', { name: 'Example設定', exact: true }).click();
  await page.getByLabel('起動パラメーター (JSON)').fill('{"snapshot":"playing"}');
  await page.getByRole('button', { name: '起動設定を適用', exact: true }).click();
  await expect(page.getByRole('alert')).toContainText('設定を更新');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Saved project');
  expect(
    await page.evaluate(
      async () =>
        JSON.parse(
          await (
            await (
              await (await exampleRoot.getDirectoryHandle('editor')).getFileHandle('studio.json')
            ).getFile()
          ).text(),
        ).resources[0].data.query,
    ),
  ).toEqual({ snapshot: 'playing' });
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true');
  const runtime = await page
    .frameLocator('.game-frame')
    .locator('body')
    .evaluate(() => ({
      src: document.querySelector('script:not([type])').src,
      fonts: Object.values(__kaguraWebRuntime.fonts).map((v) => v.length),
    }));
  expect(runtime.src).toMatch(/^blob:/);
  expect(runtime.fonts.every((size) => size > 1000)).toBe(true);
  await page.getByRole('button', { name: '拡張を再読込', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Reloaded extension');
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await page.getByRole('button', { name: 'Example設定', exact: true }).click();
  expect(JSON.parse(await page.getByLabel('起動パラメーター (JSON)').inputValue())).toEqual({
    snapshot: 'playing',
  });
});
