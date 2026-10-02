import {test, expect} from '@playwright/test';
import {DEMO_PAGES, renderDemoHtml} from '../../../../scripts/web-demo-pages.mjs';

test('all shared game launch pages fit desktop and phone viewports and expose their controls', async ({page}) => {
  let html = '';
  await page.route('**/presentation-verification', route => route.fulfill({contentType: 'text/html', body: html}));
  const games = DEMO_PAGES.filter(demo => demo.sourcePath.startsWith('examples/games/') && demo.name !== 'hacknslash_3d');
  for (const viewport of [{width: 1280, height: 900}, {width: 375, height: 812}]) {
    await page.setViewportSize(viewport);
    for (const demo of games) {
      html = renderDemoHtml({demo, libPrefix: '/assets/web', scriptTag: `<script type="module">
        import {installGamePresentation} from '/assets/web/kagura-presentation.js';
        installGamePresentation(document.querySelector('#app'));
      </script>`});
      await page.goto('/presentation-verification');
      await expect.poll(() => page.evaluate(() => (globalThis as any).__kaguraPresentation?.mode)).toBe('fullscreen');
      const bounds = await page.locator('#app').boundingBox();
      expect(bounds!.x).toBeGreaterThanOrEqual(0);
      expect(bounds!.y).toBeGreaterThanOrEqual(48);
      expect(bounds!.x + bounds!.width).toBeLessThanOrEqual(viewport.width + 0.05);
      expect(bounds!.y + bounds!.height).toBeLessThanOrEqual(viewport.height + 0.05);
      expect(Math.abs(bounds!.width - viewport.width) < 0.05 || Math.abs(bounds!.height - (viewport.height - 48)) < 0.05).toBe(true);
      await expect(page.getByRole('button', {name: '全画面', exact: true})).toBeVisible();
      await page.locator('#game-guide summary').focus();
      await page.keyboard.press('Enter');
      await expect(page.getByRole('heading', {name: 'Controls'})).toBeVisible();
      await page.keyboard.press('Escape');
      await expect(page.getByRole('heading', {name: 'Controls'})).toBeHidden();
    }
  }
});
