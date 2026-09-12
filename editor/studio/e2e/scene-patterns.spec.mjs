import { readFile } from 'node:fs/promises';
import { test, expect } from '@playwright/test';
for (const game of ['arena3d', 'fps_demo'])
  test(game + ' edits and runs an authored scene', async ({ page }) => {
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    await page.goto('/');
    const scenes = page.getByLabel('Project scene', { exact: true });
    await expect(scenes).toBeHidden();
    await page.getByLabel('Examples', { exact: true }).selectOption(game);
    await expect(page.getByRole('status')).toContainText('Opened project');
    await expect(scenes).toBeVisible();
    await expect(scenes).toHaveValue('training');
    const brand = await page.locator('.brand').boundingBox(), selector = await scenes.boundingBox();
    expect(selector.x).toBeGreaterThan(brand.x + brand.width);
    expect(selector.x).toBeLessThan(220);
    expect(selector.y + selector.height).toBeLessThanOrEqual(40);
    if (game === 'fps_demo') await expect(scenes).toBeDisabled();
    await page.locator('[data-node-id=wall]').click();
    await page.getByLabel('Position X', { exact: true }).fill('6');
    await page.getByLabel('Position X', { exact: true }).press('Tab');
    if (game === 'arena3d') {
      await page.getByLabel('Project scene', { exact: true }).selectOption('second');
      await expect(page.getByRole('status')).toContainText('Opened scene · second');
      await page.getByLabel('Project scene', { exact: true }).selectOption('training');
      await expect(page.getByRole('status')).toContainText('Opened scene · training');
      await page.locator('[data-node-id=wall]').click();
      await expect(page.getByLabel('Position X', { exact: true })).toHaveValue('6');
    }
    await page.getByRole('button', { name: 'Play', exact: true }).click();
    await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
      timeout: 30000,
    });
    const body = page.frameLocator('.game-frame').locator('body');
    const snapshot = () => body.evaluate(() => kaguraSceneRuntime.snapshot());
    const state = await snapshot();
    expect(state.scene.entities.find((e) => e.id === 'wall').position[0]).toBe(6);
    expect(state.player[2]).toBe(5);
    if (game === 'arena3d') {
      const canvas = page.frameLocator('.game-frame').locator('canvas');
      await canvas.focus();
      await page.keyboard.down('w');
      try {
        await expect.poll(async () => (await snapshot()).sceneId).toBe('second');
      } finally {
        await page.keyboard.up('w');
      }
      expect((await snapshot()).scene.entities.find((e) => e.id === 'floor').color).toBe(0x806750);
    }
    await page.screenshot({ path: `/tmp/kgr-${game}-scene.png` });
    await page.getByRole('button', { name: 'Stop', exact: true }).click();
    expect(errors).toEqual([]);
  });

test('MoonBit project saves source, preserves handwritten code and imports the downloaded scene', async ({
  page,
}) => {
  await page.goto('/');
  await page.evaluate(async () => {
    const root = await (
      await navigator.storage.getDirectory()
    ).getDirectoryHandle('moon-project-' + crypto.randomUUID(), { create: true });
    const files = [
      'arena3d.kgrprj',
      'scenes/training.mbt',
      'scenes/second.mbt',
      'editor/dist/runtime.js',
    ];
    for (const path of files) {
      const parts = path.split('/');
      let directory = root;
      for (const name of parts.slice(0, -1))
        directory = await directory.getDirectoryHandle(name, { create: true });
      let text = await (await fetch('/examples/arena3d/' + path)).text();
      if (path.endsWith('training.mbt')) text += '\n// handwritten: keep me\n';
      const writable = await (
        await directory.getFileHandle(parts.at(-1), { create: true })
      ).createWritable();
      await writable.write(text);
      await writable.close();
    }
    window.moonProjectRoot = root;
    window.showDirectoryPicker = async () => root;
  });
  await page.getByRole('button', { name: 'Open project', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.locator('[data-node-id=wall]').click();
  await page.getByLabel('Position X', { exact: true }).fill('6');
  await page.getByLabel('Position X', { exact: true }).press('Tab');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Saved project');
  const source = await page.evaluate(async () => {
    const directory = await moonProjectRoot.getDirectoryHandle('scenes');
    return (await (await directory.getFileHandle('training.mbt')).getFile()).text();
  });
  expect(source).toContain('pub fn training() -> @scene_document.Document');
  expect(source).toContain('// handwritten: keep me');
  await page.getByRole('button', { name: '拡張を再読込', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Reloaded extension');
  // Reopen the persisted source, not just the host's reload draft.
  await page.getByRole('button', { name: 'Open project', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.locator('[data-node-id=wall]').click();
  await expect(page.getByLabel('Position X', { exact: true })).toHaveValue('6');
  await page.getByLabel('Examples', { exact: true }).selectOption('arena3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.locator('[data-node-id=wall]').click();
  await page.getByLabel('Position X', { exact: true }).fill('7');
  await page.getByLabel('Position X', { exact: true }).press('Tab');
  const downloadPromise = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toBe('training.mbt');
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('Position X', { exact: true })).toHaveValue('4');
  await page
    .getByLabel('Import scene', { exact: true })
    .setInputFiles({
      name: download.suggestedFilename(),
      mimeType: 'text/plain',
      buffer: await readFile(await download.path()),
    });
  await expect(page.getByRole('status')).not.toContainText('Error');
  await page.locator('[data-node-id=wall]').click();
  await expect(page.getByLabel('Position X', { exact: true })).toHaveValue('7');
});
