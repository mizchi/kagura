import { test, expect } from '@playwright/test';
import { readFile } from 'node:fs/promises';
import { defaultScene } from '../../../examples/games/iron_yard/editor/scene/document.ts';

test('project loads a game-owned extension, reads scoped resources, saves and keeps the generic editor available', async ({
  page,
}) => {
  test.setTimeout(90000);
  await page.addInitScript(() => {
    const fetch = window.fetch;
    window.projectFetches = [];
    window.fetch = function (...args) {
      window.projectFetches.push(String(args[0]));
      return fetch.apply(this, args);
    };
  });
  const strix = await readFile(
    new URL('../../../examples/games/iron_yard/assets/generated/strix.json', import.meta.url),
    'utf8',
  );
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  const module = await readFile(
    new URL('../../../examples/games/iron_yard/editor/ui/dist/extension.mjs', import.meta.url),
    'utf8',
  );
  await page.goto('/');
  await expect(page.getByRole('button', { name: 'Open project', exact: true })).toBeVisible();
  await page.evaluate(
    async ({ module, scene, strix }) => {
      const root = await (
        await navigator.storage.getDirectory()
      ).getDirectoryHandle('project-' + crypto.randomUUID(), { create: true });
      const files = {
        'demo.kgrprj': JSON.stringify({
          format: 'kagura.project',
          version: 1,
          name: 'Local IRON YARD',
          editor: { id: 'iron-yard', entry: 'editor/extension.mjs' },
          scene: 'scenes/main.json',
          resources: { note: 'assets/note.txt', strix: 'assets/strix.json' },
        }),
        'editor/extension.mjs': module,
        'scenes/main.json': JSON.stringify(scene),
        'assets/note.txt': 'local project resource',
        'assets/strix.json': strix,
      };
      for (const [path, text] of Object.entries(files)) {
        let dir = root;
        const parts = path.split('/'),
          name = parts.pop();
        for (const part of parts) dir = await dir.getDirectoryHandle(part, { create: true });
        const out = await (await dir.getFileHandle(name, { create: true })).createWritable();
        await out.write(text);
        await out.close();
      }
      window.projectRoot = root;
      window.showDirectoryPicker = async () => root;
    },
    { module, scene: defaultScene(), strix },
  );
  await page.getByRole('button', { name: 'Open project', exact: true }).click();
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute(
    'data-renderer',
    'kagura-webgpu',
  );
  expect(
    await page.evaluate(async () => await (await kagura.projects.current().resource('note')).text()),
  ).toBe('local project resource');
  const modelURL = await page.evaluate(() => kagura.projects.current().url('assets/strix.json'));
  expect(
    await page
      .frameLocator('.iron-scene-canvas')
      .locator('body')
      .evaluate((_, url) => window.projectFetches.includes(url), modelURL),
  ).toBe(true);
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect
    .poll(
      () =>
        page
          .frameLocator('.game-frame')
          .locator('body')
          .evaluate(() => window.kaguraGame?.snapshot().phase),
      { timeout: 30000 },
    )
    .toBe('playing');
  expect(
    await page
      .frameLocator('.game-frame')
      .locator('body')
      .evaluate((_, url) => window.projectFetches.includes(url), modelURL),
  ).toBe(true);
  await page.getByRole('button', { name: 'Edit', exact: true }).click();
  await page.getByRole('button', { name: 'hangar-a', exact: true }).click();
  await page.getByLabel('位置 X', { exact: true }).fill('-30');
  await page.getByLabel('位置 X', { exact: true }).press('Tab');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Saved project');
  expect(
    await page.evaluate(
      async () =>
        JSON.parse(
          await (
            await (
              await (await window.projectRoot.getDirectoryHandle('scenes')).getFileHandle('main.json')
            ).getFile()
          ).text(),
        ).stage.solids[0].center[0],
    ),
  ).toBe(-30);
  await page.getByRole('button', { name: '汎用エディタ', exact: true }).click();
  await expect(page.getByLabel('3D scene viewport')).toBeVisible();
  await expect(page.locator('.iron-scene-canvas')).toHaveCount(0);
  await page.getByRole('button', { name: 'Edit', exact: true }).click();
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  await page.getByRole('button', { name: 'hangar-a', exact: true }).click();
  await expect(page.getByLabel('位置 X', { exact: true })).toHaveValue('-30');
  await page.getByLabel('サイズ X', { exact: true }).fill('20');
  await page.getByLabel('サイズ X', { exact: true }).press('Tab');
  await page.evaluate(async () => {
    const dir = await window.projectRoot.getDirectoryHandle('editor'),
      handle = await dir.getFileHandle('extension.mjs'),
      text = await (await handle.getFile()).text();
    const stream = await handle.createWritable();
    await stream.write(text + '\nglobalThis.editorReloaded = true;\n');
    await stream.close();
  });
  await page.getByRole('button', { name: '拡張を再読込', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Reloaded extension');
  expect(await page.evaluate(() => globalThis.editorReloaded)).toBe(true);
  await page.getByRole('button', { name: 'hangar-a', exact: true }).click();
  await expect(page.getByLabel('サイズ X', { exact: true })).toHaveValue('20');
  await page.evaluate(async () => {
    const dir = await window.projectRoot.getDirectoryHandle('editor'),
      handle = await dir.getFileHandle('extension.mjs'),
      stream = await handle.createWritable();
    await stream.write('export const apiVersion=99; export const id="iron-yard";');
    await stream.close();
  });
  await page.getByRole('button', { name: '拡張を再読込', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Invalid editor extension API');
  await expect(page.getByLabel('サイズ X', { exact: true })).toHaveValue('20');
  expect(errors).toEqual([]);
});

test('a project without an extension opens in the built-in generic editor', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('button', { name: 'Open project', exact: true })).toBeVisible();
  await page.evaluate(async () => {
    const root = await (
      await navigator.storage.getDirectory()
    ).getDirectoryHandle('generic-' + crypto.randomUUID(), { create: true });
    const doc = kagura.snapshot().document;
    doc.name = 'Generic project';
    for (const [path, data] of Object.entries({
      'generic.kgrprj': {
        format: 'kagura.project',
        version: 1,
        name: 'Generic',
        scene: 'scene.json',
        resources: {},
      },
      'scene.json': doc,
    })) {
      const stream = await (await root.getFileHandle(path, { create: true })).createWritable();
      await stream.write(JSON.stringify(data));
      await stream.close();
    }
    window.showDirectoryPicker = async () => root;
  });
  await page.getByRole('button', { name: 'Open project', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Opened project · Generic');
  await expect(page.getByLabel('3D scene viewport')).toBeVisible();
  expect(await page.evaluate(() => kagura.snapshot().document.name)).toBe('Generic project');
  await expect(page.getByRole('button', { name: 'Play', exact: true })).toBeDisabled();
});
