import { test, expect } from '@playwright/test';
test.use({ launchOptions: { args: ['--enable-experimental-web-platform-features', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] } });

async function run(page, name, input) {
  return page.evaluate(async ({ name, input }) => {
    const tool = (await document.modelContext.getTools()).find(t => t.name === name);
    const args = typeof tool.inputSchema === 'string' ? JSON.stringify(input) : input;
    return JSON.parse(await document.modelContext.executeTool(tool, args));
  }, { name, input });
}

test('declarative MoonBit and Wasm pane tools publish through the parent and survive closing the view', async ({ page }) => {
  await page.goto('/'); await page.waitForFunction(() => !!globalThis.kagura);
  await page.evaluate(async () => {
    await kagura.webmcp.ready;
    const module = await import('/plugins/moonbit-demo.mjs');
    kagura.panes.registerPlugin(kagura.plugins.fromJSONModule(module));
    const bytes = await (await fetch('/plugins/wasm-demo.wasm')).arrayBuffer();
    kagura.panes.registerPlugin(await kagura.plugins.fromWasm(bytes));
    await kagura.webmcp.settled();
  });
  expect((await run(page, 'kagura.pane.demo.moonbit.count_nodes', { arguments: {} })).result).toBe(3);
  expect((await run(page, 'kagura.pane.demo.wasm.inspect_request', { arguments: { value: 'こんにちは' } })).result.arguments.value).toBe('こんにちは');
  await page.getByRole('tab', { name: 'MoonBit tools', exact: true }).click();
  await page.getByLabel('Plugin tool', { exact: true }).selectOption('rename_selected');
  await page.getByLabel('Plugin arguments JSON', { exact: true }).fill('{"name":"Luna hero"}');
  await page.getByRole('button', { name: 'Run plugin tool', exact: true }).click();
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('Luna hero');
  await page.getByRole('button', { name: 'Close pane', exact: true }).click();
  expect((await run(page, 'kagura.pane.demo.moonbit.rename_selected', { arguments: { name: 'AI hero' }, expectedRevision: 1 })).ok).toBe(true);
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('AI hero');
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('Name', { exact: true })).toHaveValue('Luna hero');
  await page.evaluate(async () => { kagura.panes.unregister('demo.moonbit'); await kagura.webmcp.settled(); });
  const names = await page.evaluate(async () => (await document.modelContext.getTools()).map(t => t.name));
  expect(names).not.toContain('kagura.pane.demo.moonbit.count_nodes');
  expect(names).toContain('kagura.pane.demo.wasm.inspect_request');
  expect(names).toContain('kagura.snapshot');
});

test('JavaScript pane replacement replaces the WebMCP declarations without leaking old tools', async ({ page }) => {
  await page.goto('/'); await page.waitForFunction(() => !!globalThis.kagura);
  await page.evaluate(async () => {
    await kagura.webmcp.ready;
    const make = name => kagura.plugins.defineJSPlugin({
      manifest: { apiVersion: 1, id: 'game.js', title: 'JS tools', tools: [{ name, description: 'Read test data', effect: 'read', inputSchema: { type: 'object', properties: {}, additionalProperties: false } }] },
      invoke: () => ({ result: name }),
    });
    kagura.panes.registerPlugin(make('old')); await kagura.webmcp.settled();
    kagura.panes.registerPlugin(make('new')); await kagura.webmcp.settled();
  });
  const names = await page.evaluate(async () => (await document.modelContext.getTools()).map(t => t.name));
  expect(names).not.toContain('kagura.pane.game.js.old'); expect(names).toContain('kagura.pane.game.js.new');
  expect((await run(page, 'kagura.pane.game.js.new', { arguments: {} })).result).toBe('new');
});
