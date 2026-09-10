import { test, expect } from '@playwright/test';

async function drag(page, name, dx, dy) {
  const handle = page.getByRole('separator', { name, exact: true });
  const box = await handle.boundingBox();
  expect(box).not.toBeNull();
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  await page.mouse.move(box.x + box.width / 2 + dx, box.y + box.height / 2 + dy, { steps: 8 });
  await page.mouse.up();
}

async function bounds(page, selector) { return page.locator(selector).boundingBox(); }

for (const viewport of [{ width: 1440, height: 900 }, { width: 768, height: 650 }]) {
  test(`workspace stays within ${viewport.width}x${viewport.height}, with scrolling inside panes`, async ({ page }) => {
    await page.setViewportSize(viewport);
    await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
    await page.waitForFunction(() => !!globalThis.kagura);
    // Make both sides taller than the available pane height using real editor data.
    await page.evaluate(() => kagura.dispatch({ expectedRevision: 0, commands: Array.from({ length: 45 }, (_, i) =>
      ({ op: 'node.add', id: `item-${i}`, name: `Object ${i}`, asset: 'primitive.box' })) }));
    const metrics = await page.evaluate(() => ({
      height: document.documentElement.scrollHeight, width: document.documentElement.scrollWidth,
      editor: document.querySelector('.studio').getBoundingClientRect().height,
      footer: document.querySelector('.statusbar').getBoundingClientRect().bottom,
      panels: [...document.querySelectorAll('.workspace .panel')].map(p => {
        const b = p.getBoundingClientRect(); return { bottom: b.bottom, right: b.right, height: b.height, width: b.width };
      }),
    }));
    expect(metrics.height).toBe(viewport.height);
    expect(metrics.width).toBe(viewport.width);
    expect(metrics.editor).toBe(viewport.height);
    expect(metrics.footer).toBeLessThanOrEqual(viewport.height);
    for (const panel of metrics.panels) {
      expect(panel.bottom).toBeLessThanOrEqual(viewport.height);
      expect(panel.right).toBeLessThanOrEqual(viewport.width);
      expect(panel.height).toBeGreaterThan(0);
      expect(panel.width).toBeGreaterThan(0);
    }
    for (const selector of ['.hierarchy', '.inspector']) {
      const pane = page.locator(selector);
      await pane.hover();
      await page.mouse.wheel(0, 1000);
      await expect.poll(() => pane.evaluate(p => p.scrollTop)).toBeGreaterThan(0);
    }
    expect(await page.evaluate(() => window.scrollY)).toBe(0);
  });
}

test('every pane resizes by dragging, without editing the document, and sizes restore', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const initial = await page.evaluate(() => kagura.snapshot());
  const left = await bounds(page, '.hierarchy');
  const right = await bounds(page, '.inspector');
  await drag(page, 'Resize hierarchy and scene columns', 80, 0);
  expect((await bounds(page, '.hierarchy')).width).toBeCloseTo(left.width + 80, 0);
  await drag(page, 'Resize scene and inspector columns', -60, 0);
  expect((await bounds(page, '.inspector')).width).toBeCloseTo(right.width + 60, 0);
  for (const [name, top, bottom] of [
    ['Resize hierarchy and resources', '.hierarchy', '.assets'],
    ['Resize scene and action preview', '.viewport', '.timeline'],
    ['Resize inspector and command console', '.inspector', '.agent'],
  ]) {
    const beforeTop = await bounds(page, top);
    const beforeBottom = await bounds(page, bottom);
    await drag(page, name, 0, -65);
    expect((await bounds(page, top)).height).toBeCloseTo(beforeTop.height - 65, 0);
    expect((await bounds(page, bottom)).height).toBeCloseTo(beforeBottom.height + 65, 0);
  }
  const resized = await bounds(page, '.viewport');
  expect((await page.evaluate(() => kagura.snapshot())).document).toEqual(initial.document);
  expect((await page.evaluate(() => kagura.snapshot())).revision).toBe(initial.revision);
  await page.reload();
  await page.waitForFunction(() => !!globalThis.kagura);
  expect((await bounds(page, '.viewport')).width).toBeCloseTo(resized.width, 0);
  expect((await bounds(page, '.viewport')).height).toBeCloseTo(resized.height, 0);
  const canvas = await bounds(page, 'canvas');
  const surface = await bounds(page, '#viewport');
  expect(canvas.width).toBeCloseTo(surface.width, 0);
  expect(canvas.height).toBeCloseTo(surface.height, 0);
});

test('splitters clamp to bounds, support keyboard and cancel, and adapt to window and layout changes', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const handle = page.getByRole('separator', { name: 'Resize hierarchy and scene columns', exact: true });
  await handle.focus();
  const before = await bounds(page, '.hierarchy');
  await page.keyboard.press('ArrowRight');
  expect((await bounds(page, '.hierarchy')).width).toBeGreaterThan(before.width);
  const committed = await bounds(page, '.hierarchy');
  const box = await handle.boundingBox();
  await page.mouse.move(box.x + box.width / 2, box.y + 20);
  await page.mouse.down();
  await page.mouse.move(box.x + 100, box.y + 20);
  await page.keyboard.press('Escape');
  await page.mouse.up();
  expect((await bounds(page, '.hierarchy')).width).toBeCloseTo(committed.width, 0);
  await drag(page, 'Resize hierarchy and scene columns', 2000, 0);
  await drag(page, 'Resize scene and action preview', 0, 2000);
  expect((await bounds(page, '.viewport')).width).toBeGreaterThanOrEqual(150);
  expect((await bounds(page, '.timeline')).height).toBeGreaterThanOrEqual(79);
  await page.getByRole('button', { name: 'Action layout', exact: true }).click();
  await page.setViewportSize({ width: 768, height: 600 });
  await expect.poll(() => page.evaluate(() => document.documentElement.scrollHeight)).toBe(600);
  for (const selector of ['.hierarchy', '.viewport', '.inspector', '.assets', '.timeline', '.agent']) {
    const panel = await bounds(page, selector);
    expect(panel.width).toBeGreaterThan(0);
    expect(panel.height).toBeGreaterThan(0);
    expect(panel.y + panel.height).toBeLessThanOrEqual(600);
  }
});

test('compact header leaves room for editing and fits its actions at 768px', async ({ page }) => {
  await page.setViewportSize({ width: 768, height: 650 });
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  const header = page.locator('.toolbar');
  expect((await header.boundingBox()).height).toBeLessThanOrEqual(40);
  expect(await header.evaluate(el => el.scrollWidth <= el.clientWidth)).toBe(true);
  const bar = await page.locator('.workspace-bar').boundingBox();
  expect(bar.y + bar.height).toBeLessThanOrEqual(72);
  await expect(page.getByRole('button', {name:'Save', exact:true})).toBeVisible();
  await expect(page.getByRole('button', {name:'Export GLB', exact:true})).toBeVisible();
});
