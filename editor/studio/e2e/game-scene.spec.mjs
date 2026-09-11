import { test, expect } from '@playwright/test';
test('game scene nodes edit the actual level, survive save/reload, and reject invalid placements', async ({
  page,
}) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('hacknslash_3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.locator('[data-node-id=barrier]')).toBeVisible();
  await page.locator('[data-node-id=barrier]').click();
  await page.getByLabel('Position X', { exact: true }).fill('22.5');
  await page.getByLabel('Position X', { exact: true }).press('Tab');
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  const state = await page
    .frameLocator('.game-frame')
    .locator('body')
    .evaluate(() => kaguraSceneRuntime.snapshot());
  expect(state.scene.rectangles.find((r) => r.id === 'barrier').x).toBe(22);
  expect(state.player).toEqual([12.5, 15.5]);
  expect(state.enemyCount).toBe(2);
  await page.screenshot({ path: '/tmp/kgr-scene-game.png' });
  await page.getByRole('button', { name: 'Stop', exact: true }).click();
  const downloadPromise = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  const download = await downloadPromise;
  const file = await download.path();
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('Position X', { exact: true })).toHaveValue('20.5');
  await page.getByLabel('Import scene', { exact: true }).setInputFiles(file);
  await expect(page.locator('[data-node-id=barrier]')).toBeVisible();
  await page.locator('[data-node-id=barrier]').click();
  await expect(page.getByLabel('Position X', { exact: true })).toHaveValue('22.5');
  await page.screenshot({ path: '/tmp/kgr-scene-editor.png' });
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready', 'true');
  expect(
    await page
      .frameLocator('.game-frame')
      .locator('body')
      .evaluate(
        () => kaguraSceneRuntime.snapshot().scene.rectangles.find((r) => r.id === 'barrier').x,
      ),
  ).toBe(22);
  await page.getByRole('button', { name: 'Stop', exact: true }).click();
  await page.locator('[data-node-id=spawn]').click();
  await page.getByLabel('Position X', { exact: true }).fill('0');
  await page.getByLabel('Position X', { exact: true }).press('Tab');
  await page.getByRole('button', { name: 'Play', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('開始位置と敵');
  await expect(page.locator('.game-frame')).toHaveCount(0);
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await page.getByRole('tab', { name: 'Game scene', exact: true }).click();
  await page.getByRole('button', { name: '敵を追加', exact: true }).click();
  await expect(page.getByLabel('Scene validation')).toContainText('敵 3');
  await page.locator('[data-node-id=enemy-a]').click();
  await page.getByLabel('Enemy HP',{exact:true}).fill('95');
  await page.getByLabel('Enemy HP',{exact:true}).press('Tab');
  await page.getByLabel('Enemy kind',{exact:true}).selectOption('tank');
  await page.getByRole('button',{name:'Play',exact:true}).click();
  await expect(page.locator('.game-frame')).toHaveAttribute('data-ready','true');
  expect(await page.frameLocator('.game-frame').locator('body').evaluate(()=>kaguraSceneRuntime.snapshot().scene.enemies.find(e=>e.id==='enemy-a'))).toMatchObject({kind:'tank',hp:95});
  await page.getByRole('button',{name:'Stop',exact:true}).click();
  const before=await page.evaluate(()=>kagura.snapshot());
  const invalid=structuredClone(before.document);invalid.nodes.pop();
  await page.getByLabel('Import scene',{exact:true}).setInputFiles({name:'broken.kgrscene',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(invalid))});
  await expect(page.getByRole('status')).toContainText('Invalid or dangling scene binding');
  expect((await page.evaluate(()=>kagura.snapshot())).revision).toBe(before.revision);
  expect(errors).toEqual([]);
});
