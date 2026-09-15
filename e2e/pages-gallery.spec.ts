import {test, expect} from '@playwright/test';
import {catalog} from '../scripts/example-catalog.mjs';

for (const width of [1440, 768, 390]) {
  test(`game gallery has complete thumbnails and working routes at ${width}px`, async ({page, request}, info) => {
    await page.setViewportSize({width, height: 900});
    const response = await page.goto('./examples/');
    expect(response?.ok()).toBe(true);
    await expect(page.getByRole('heading', {level: 1})).toHaveText('ゲーム一覧');
    const cards = page.locator('.game-card');
    const games = catalog.filter(item => item.category === 'games');
    await expect(cards).toHaveCount(games.length);
    for (const game of games) {
      const card = cards.filter({has: page.getByRole('heading', {name: game.title, exact: true})});
      await card.scrollIntoViewIfNeeded();
      const img = card.locator('img');
      await expect(img).toHaveAttribute('alt', game.gallery.thumbnailAlt);
      await expect.poll(() => img.evaluate(image => image.complete && image.naturalWidth > 0)).toBe(true);
      const href = await card.getByRole('link', {name: `${game.title} をプレイ`, exact: true}).getAttribute('href');
      // Check the real emitted route, including /kagura/ rather than the domain root.
      const target = new URL(href!, page.url());
      expect(target.pathname).toContain('/kagura/');
      expect((await request.get(target.href)).ok()).toBe(true);
    }
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    await page.getByRole('link', {name: /2D のゲーム/}).click();
    await expect(page).toHaveURL(/#games-2d$/);
    await page.getByRole('link', {name: 'Flappy Bird をプレイ', exact: true}).focus();
    await page.keyboard.press('Enter');
    await expect(page).toHaveURL(/\/flappy_bird\/$/);
    await page.goBack();
    await page.evaluate(() => window.scrollTo({top: 0, behavior: 'instant'}));
    await page.screenshot({path: info.outputPath(`gallery-${width}.png`), fullPage: true});
    await page.screenshot({path: info.outputPath(`gallery-${width}-preview.png`)});
  });
}
