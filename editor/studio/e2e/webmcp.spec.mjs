import { test, expect } from '@playwright/test';

test.use({ launchOptions: { args: ['--enable-experimental-web-platform-features', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] } });

test('native WebMCP discovers tools, shares UI edits, creates forms and respects conflicts', async ({ page }) => {
  const errors = []; page.on('pageerror', error => errors.push(error.message));
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.waitForFunction(() => globalThis.kagura?.webmcp.status().state === 'ready');
  const tools = await page.evaluate(async () => (await document.modelContext.getTools()).map(t => t.name));
  expect(tools).toHaveLength(13);
  expect(tools).toContain('kagura.panes_create_form');
  const run = (name, input) => page.evaluate(async ({ name, input }) => {
    const tool = (await document.modelContext.getTools()).find(t => t.name === name);
    // Chromium 153 uses JSON strings; the newer draft uses objects.
    const args = typeof tool.inputSchema === 'string' ? JSON.stringify(input) : input;
    return JSON.parse(await document.modelContext.executeTool(tool, args));
  }, { name, input });
  const before = await run('kagura.snapshot', {});
  const edit = { expectedRevision: before.snapshot.revision, commands: [{ op: 'node.rename', id: 'hero', name: 'WebMCP player' }] };
  expect((await run('kagura.dispatch', edit)).ok).toBe(true);
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('WebMCP player');
  expect((await run('kagura.dispatch', edit)).error.code).toBe('conflict');
  const definition = { id: 'game.ai', gameId: 'test-game', title: 'AI settings', fields: [{ key: 'enabled', label: 'AI enabled', type: 'boolean' }], values: { enabled: true } };
  expect((await run('kagura.panes_create_form', { expectedRevision: 0, definition })).error.code).toBe('conflict');
  expect((await run('kagura.panes_create_form', { expectedRevision: 1, definition })).ok).toBe(true);
  await expect(page.getByRole('switch', { name: 'AI enabled' })).toHaveAttribute('aria-checked', 'true');
  await page.getByRole('switch', { name: 'AI enabled' }).press('Space');
  const snapshot = await run('kagura.snapshot', {});
  expect(snapshot.snapshot.document.resources[0].data.values.enabled).toBe(false);
  expect((await run('kagura.history', { direction: 'undo', expectedRevision: 3 })).ok).toBe(true);
  await expect(page.getByRole('switch', { name: 'AI enabled' })).toHaveAttribute('aria-checked', 'true');
  await run('kagura.panes_close', { id: 'form.game.ai' });
  await expect(page.getByRole('button', { name: 'Apply commands' })).toBeVisible();
  expect((await run('kagura.storage_save', { location: { store: 'indexeddb', key: 'ai/scene.json' }, expectedRevision: 4 })).ok).toBe(true);
  const listed = await run('kagura.storage_list', { store: 'indexeddb', prefix: 'ai/' });
  expect(listed.objects[0].key).toBe('ai/scene.json');
  expect((await run('kagura.storage_load', { location: { store: 'indexeddb', key: 'missing' }, expectedRevision: 4 })).error.code).toBe('not_found');
  await page.evaluate(() => kagura.webmcp.dispose());
  expect(await page.evaluate(async () => (await document.modelContext.getTools()).length)).toBe(0);
  expect(errors).toEqual([]);
});
