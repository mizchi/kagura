import { test, expect } from '@playwright/test';
import { defaultScene } from '../../../examples/games/iron_yard/editor/scene/document.ts';

async function open(page) {
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('iron_yard');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button', { name: 'Edit', exact: true }).click();
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
}
async function change(page, label, value) {
  const input = page.getByLabel(label, { exact: true });
  await input.fill(value);
  await input.press('Tab');
}
test('IRON YARD authoring selects real models and buildings, edits, undoes, saves and trials the edited scene', async ({
  page,
}) => {
  test.setTimeout(90000);
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await open(page);
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute(
    'data-renderer',
    'kagura-webgpu',
  );
  await expect(page.locator('.iron-tree-entry')).toHaveCount(23);
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await page.getByRole('button', { name: 'hangar-a', exact: true }).click();
  await change(page, '位置 X', '-30');
  await change(page, 'サイズ X', '20');
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('サイズ X', { exact: true })).toHaveValue('22');
  await page.getByRole('button', { name: 'Redo', exact: true }).click();
  await expect(page.getByLabel('サイズ X', { exact: true })).toHaveValue('20');
  await page.getByRole('button', { name: 'Frame selected', exact: true }).click();
  await page.getByRole('button', { name: '出撃地点 / STRIX', exact: true }).click();
  await page.getByLabel('IRON YARD シーンプレビュー').click();
  await expect(page.getByRole('button', { name: 'hangar-a', exact: true })).toHaveAttribute(
    'aria-pressed',
    'true',
  );
  const download = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  expect((await download).suggestedFilename()).toBe('iron-yard.json');
  await page.getByRole('button', { name: '拡張を再読込', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Reloaded extension');
  await page.getByRole('button', { name: 'hangar-a', exact: true }).click();
  await expect(page.getByLabel('位置 X', { exact: true })).toHaveValue('-30');
  await expect(page.getByLabel('サイズ X', { exact: true })).toHaveValue('20');
  await page.getByRole('button', { name: '試遊', exact: true }).click();
  const frame = page.frameLocator('.game-frame');
  await expect
    .poll(
      () =>
        frame
          .locator('body')
          .evaluate(() => globalThis.kaguraGame?.sceneDocument()?.stage.solids[0].center[0]),
      { timeout: 30000 },
    )
    .toBe(-30);
  expect(
    await frame.locator('body').evaluate(() => globalThis.kaguraGame.sceneDocument().stage.solids[0].size[0]),
  ).toBe(20);
  await expect
    .poll(() => frame.locator('body').evaluate(() => globalThis.kaguraGame.snapshot().phase))
    .toBe('playing');
  await page.keyboard.down('KeyW');
  await expect
    .poll(() => frame.locator('body').evaluate(() => globalThis.kaguraGame.snapshot().pilot.position[2]))
    .toBeGreaterThan(-35.8);
  await page.keyboard.up('KeyW');
  await page.keyboard.press('Escape');
  await frame.getByRole('button', { name: '編集に戻る', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await expect(page.getByLabel('位置 X', { exact: true })).toHaveValue('-30');
  const separator = page.getByRole('separator', { name: 'Resize scene and action preview' }),
    before = await page.getByLabel('IRON YARD シーンプレビュー').boundingBox(),
    box = await separator.boundingBox();
  await page.mouse.move(box.x + box.width / 2, box.y + 3);
  await page.mouse.down();
  await page.mouse.move(box.x + box.width / 2, box.y + 60);
  await page.mouse.up();
  expect((await page.getByLabel('IRON YARD シーンプレビュー').boundingBox()).height).toBeGreaterThan(
    before.height + 20,
  );
  expect(await page.evaluate(() => document.documentElement.scrollHeight <= innerHeight)).toBe(true);
  await page.screenshot({ path: 'test-results/iron-yard-scene-editor.png' });
  expect(errors).toEqual([]);
});

test('source scene JSON imports with waves; entities and attack parameters share history and real hit preview', async ({
  page,
}) => {
  await page.addInitScript(() => {
    globalThis.audioStarts = 0;
    const start = AudioBufferSourceNode.prototype.start;
    AudioBufferSourceNode.prototype.start = function (...args) {
      globalThis.audioStarts++;
      return start.apply(this, args);
    };
  });
  await open(page);
  const doc = defaultScene();
  doc.mission.timeLimit = 10;
  doc.camera.fov = 70;
  const input = page.getByLabel('シーンJSONを読み込む');
  await input.setInputFiles({
    name: 'invalid.json',
    mimeType: 'application/json',
    buffer: Buffer.from(JSON.stringify({ ...doc, version: 99 })),
  });
  await expect(page.locator('.iron-editor-error')).toContainText('設定が不正');
  await page.getByLabel('Import scene', { exact: true }).setInputFiles({
    name: 'source.json',
    mimeType: 'application/json',
    buffer: Buffer.from(JSON.stringify(doc)),
  });
  await expect(page.getByLabel('制限時間（秒）')).toHaveValue('10');
  await expect(page.getByLabel('カメラ FOV')).toHaveValue('70');
  await page.getByRole('button', { name: 'B-04', exact: true }).click();
  await expect(page.getByLabel('表示する波')).toHaveValue('1');
  await page.getByLabel('表示する波').selectOption('1');
  await page.getByRole('button', { name: '＋ 敵機', exact: true }).click();
  await expect(page.locator('.iron-tree-entry')).toHaveCount(24);
  await change(page, '向き（度）', '90');
  await page.getByRole('button', { name: '選択を削除', exact: true }).click();
  await expect(page.locator('.iron-tree-entry')).toHaveCount(23);
  await page.getByRole('button', { name: '攻撃・エフェクト', exact: true }).click();
  await page.getByLabel('攻撃の時間').fill('0.5');
  await expect(page.getByTestId('attack-result')).toHaveAttribute('data-hp', '168');
  await change(page, 'ダメージ', '180');
  await page.getByLabel('攻撃の時間').fill('0.5');
  await expect(page.getByTestId('attack-result')).toHaveAttribute('data-hp', '0');
  await page.getByLabel('攻撃の時間').fill('0');
  await expect(page.getByTestId('attack-result')).toHaveAttribute('data-shots', '0');
  expect(await page.evaluate(() => globalThis.audioStarts)).toBe(0);
  await page.getByLabel('発射音', { exact: true }).selectOption('sfx.confirm');
  await page.getByRole('button', { name: '攻撃を再生', exact: true }).click();
  await expect.poll(() => page.evaluate(() => globalThis.audioStarts)).toBe(2);
  await expect(page.getByTestId('attack-result')).toHaveAttribute('data-shots', '1');
  await page.getByLabel('攻撃の時間').fill('0');
  await expect(page.getByTestId('attack-result')).toHaveAttribute('data-shots', '0');
  const download = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Export JSON', exact: true }).click();
  const file = await download;
  const stream = await file.createReadStream();
  const chunks = [];
  for await (const chunk of stream) chunks.push(chunk);
  const exported = JSON.parse(Buffer.concat(chunks).toString());
  expect(exported.action.damage).toBe(180);
  expect(exported.mission.timeLimit).toBe(10);
  expect(exported.stage.targets).toHaveLength(9);
  await page.screenshot({ path: 'test-results/iron-yard-attack-editor.png' });
});

test('loading cancellation and plugin disposal stop the trial without replaying saved commands', async ({
  page,
}) => {
  test.setTimeout(60000);
  await open(page);
  let release;
  const gate = new Promise((resolve) => (release = resolve));
  await page.route('**/games/iron-yard/index.html*', async (route) => {
    await gate;
    await route.continue();
  });
  await page.getByRole('button', { name: '試遊', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveCount(1);
  await page.getByRole('button', { name: 'Pause game', exact: true }).click();
  release();
  await expect
    .poll(
      () =>
        page
          .frameLocator('.game-frame')
          .locator('body')
          .evaluate(() => globalThis.kaguraGame?.snapshot().phase),
      { timeout: 30000 },
    )
    .toBe('ready');
  await page.evaluate(() => kagura.panes.unregister('iron-yard'));
  await expect(page.getByRole('button', { name: 'Play', exact: true })).toBeDisabled();
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveCount(0);
  await expect(page.getByLabel('3D scene viewport')).toBeVisible();
});
