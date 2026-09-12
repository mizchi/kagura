import { test, expect } from '@playwright/test';

test('inspector, debugger, agent and terminal are named parts', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  expect(await page.evaluate(() => kagura.workspace.list())).toEqual([
    'hierarchy',
    'resources',
    'viewport',
    'timeline',
    'inspector',
    'tools',
  ]);
  expect(await page.evaluate(() => kagura.workspace.active('inspector'))).toBe('default');
  await expect(page.getByRole('tab', { name: 'Inspector', exact: true })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Debugger', exact: true })).toBeDisabled();
  await expect(page.getByRole('tab', { name: 'Agent', exact: true })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Terminal', exact: true })).toBeVisible();
  const tabNames = await page.locator('.pane-tabs [role=tab]').allTextContents();
  expect(tabNames.indexOf('Console')).toBeLessThan(tabNames.indexOf('Agent'));
  expect(tabNames.indexOf('Agent')).toBeLessThan(tabNames.indexOf('Terminal'));
  expect(tabNames.indexOf('Terminal')).toBeLessThan(tabNames.indexOf('Storage'));
  await expect(page.getByLabel('Project scene', { exact: true })).toBeHidden();
  await page.getByRole('tab', { name: 'Agent', exact: true }).click();
  await expect(page.getByText('Ask to inspect, rename, or switch scenes.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Send', exact: true })).toBeVisible();
  await expect(page.getByLabel('Agent message', { exact: true })).toBeVisible();
  await page.getByRole('tab', { name: 'Terminal', exact: true }).click();
  await expect(page.locator('.studio-terminal')).toBeVisible();
  await expect(page.getByRole('button', { name: 'New pane', exact: true })).toBeHidden();
  await expect(page.getByRole('button', { name: 'Close pane', exact: true })).toBeHidden();
  await page.getByRole('tab', { name: 'Agent', exact: true }).click();
  await expect(page.getByRole('button', { name: 'New pane', exact: true })).toBeHidden();
  await page.getByRole('tab', { name: 'Console', exact: true }).click();
  await expect(page.getByRole('button', { name: 'New pane', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Apply commands' })).toBeVisible();
  const graph = await page.evaluate(() => kagura.graph());
  expect(graph.view.length).toBeGreaterThan(0);
  expect(graph.view[0].origin).toBe('definition');
});
