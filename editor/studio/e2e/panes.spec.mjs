import { test, expect } from '@playwright/test';

test('create a form pane live, edit with Luna, undo and restore from saved document', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByRole('button', { name: 'New pane', exact: true }).click();
  await page.getByRole('button', { name: 'Create pane', exact: true }).click();
  await expect(page.getByRole('tab', { name: 'Mission settings', exact: true })).toBeVisible();
  await page.getByLabel('Enemy count', { exact: true }).fill('12');
  await page.getByLabel('Enemy count', { exact: true }).press('Tab');
  await page.getByRole('switch', { name: 'Friendly fire' }).click();
  await expect(page.getByRole('switch', { name: 'Friendly fire' })).toHaveAttribute('aria-checked', 'true');
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByRole('switch', { name: 'Friendly fire' })).toHaveAttribute('aria-checked', 'false');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('status')).toContainText('Saved');
  await page.reload();
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByRole('tab', { name: 'Mission settings', exact: true }).click();
  await expect(page.getByLabel('Enemy count', { exact: true })).toHaveValue('12');
  expect(await page.evaluate(() => document.documentElement.scrollHeight <= innerHeight)).toBe(true);
});

test('custom mounts clean up subscriptions and recover from plugin failures', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.waitForFunction(() => !!globalThis.kagura?.panes);
  const result = await page.evaluate(() => {
    let notifications = 0, disposals = 0, aborted = false;
    const mount = ({ element, subscribe, signal }) => {
      element.textContent = 'Custom game tools';
      subscribe(() => notifications++);
      signal.addEventListener('abort', () => { aborted = true; });
      return () => { disposals++; };
    };
    kagura.panes.register({ id: 'game.tools', title: 'Tools', mount });
    kagura.panes.open('game.tools');
    kagura.seek(0.03);
    kagura.panes.close('game.tools');
    kagura.seek(0.04);
    kagura.panes.open('game.tools');
    kagura.panes.unregister('game.tools');
    kagura.panes.register({ id: 'bad', title: 'Bad', mount(ctx) { ctx.subscribe(() => notifications++); throw Error('Plugin failure'); } });
    kagura.panes.open('bad');
    kagura.seek(0.05);
    return { notifications, disposals, aborted };
  });
  expect(result).toEqual({ notifications: 1, disposals: 2, aborted: true });
  await expect(page.getByText('Plugin failure', { exact: false })).toBeVisible();
  await page.getByRole('tab', { name: 'Console', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Apply commands' })).toBeVisible();
});

test('form typing survives preview updates and invalid imported form data recovers on undo', async ({ page }) => {
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  await page.getByRole('button', { name: 'New pane', exact: true }).click();
  await page.getByRole('button', { name: 'Create pane', exact: true }).click();
  await page.getByLabel('Mission name', { exact: true }).fill('Draft mission');
  await page.evaluate(() => kagura.seek(0.03));
  await expect(page.getByLabel('Mission name', { exact: true })).toHaveValue('Draft mission');
  await page.getByLabel('Mission name', { exact: true }).press('Tab');
  expect(await page.evaluate(() => {
    const s = kagura.snapshot(), resource = s.document.resources[0];
    return kagura.dispatch({ expectedRevision: s.revision, commands: [{ op: 'resource.put', resource: { ...resource, data: { ...resource.data, values: null } } }] }).ok;
  })).toBe(true);
  await expect(page.getByRole('alert')).toContainText('Invalid form data');
  await expect(page.getByLabel('Mission name', { exact: true })).toBeDisabled();
  await page.getByRole('button', { name: 'Undo', exact: true }).click();
  await expect(page.getByLabel('Mission name', { exact: true })).toBeEnabled();
  await expect(page.getByLabel('Mission name', { exact: true })).toHaveValue('Draft mission');
  await page.screenshot({ path: 'test-results/custom-pane.png' });
});

test('malformed saved pane metadata does not break editing and can be repaired live', async ({ page }) => {
  const errors = []; page.on('pageerror', error => errors.push(error.message));
  await page.goto('/');
  await page.waitForFunction(() => !!globalThis.kagura);
  expect(await page.evaluate(() => kagura.dispatch({ expectedRevision: 0, commands: [{ op: 'resource.put', resource: { id: 'broken', kind: 'kagura.form-pane', version: 1, data: { title: '   ' } } }] }).ok)).toBe(true);
  await page.getByRole('tab', { name: 'broken', exact: true }).click();
  await expect(page.getByText('Pane error:', { exact: false })).toBeVisible();
  expect(await page.evaluate(() => kagura.panes.registerForm({ id: 'broken', gameId: 'test', title: 'Repaired', fields: [], values: {} }).ok)).toBe(true);
  await expect(page.getByRole('heading', { name: 'Repaired', exact: true })).toBeVisible();
  expect(errors).toEqual([]);
});
