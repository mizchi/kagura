import {test, expect} from '@playwright/test';
import {catalog} from '../scripts/example-catalog.mjs';

for (const width of [1440, 768, 390]) {
  test(`game gallery has complete thumbnails and working routes at ${width}px`, async ({page, request}, info) => {
    await page.setViewportSize({width, height: 900});
    const response = await page.goto('./examples/');
    expect(response?.ok()).toBe(true);
    await expect(page.getByRole('heading', {level: 1})).toHaveText('Games & Technical Demos');
    const cards = page.locator('.game-card');
    const games = catalog.filter(item => item.gallery);
    await expect(cards).toHaveCount(games.length);
    await expect(page.locator('#games .game-card')).toHaveCount(3);
    await expect(page.locator('#demos .game-card')).toHaveCount(4);
    for (const game of games) {
      const card = cards.filter({has: page.getByRole('heading', {name: game.title, exact: true})});
      await expect(page.locator(game.kind === 'game' ? '#games' : '#demos').getByRole('heading', {name: game.title, exact: true})).toBeVisible();
      await card.scrollIntoViewIfNeeded();
      const img = card.locator('img');
      await expect(img).toHaveAttribute('alt', game.gallery.thumbnailAlt);
      await expect.poll(() => img.evaluate(image => image.complete && image.naturalWidth > 0)).toBe(true);
      const href = await card.getByRole('link', {name: `${game.kind === 'game' ? 'Play' : 'Open'} ${game.title}`, exact: true}).getAttribute('href');
      // Check the real emitted route, including /kagura/ rather than the domain root.
      const target = new URL(href!, page.url());
      expect(target.pathname).toContain('/kagura/');
      expect((await request.get(target.href)).ok()).toBe(true);
    }
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    await page.getByRole('link', {name: /^Technical Demos/}).click();
    await expect(page).toHaveURL(/#demos$/);
    await page.getByRole('link', {name: 'Open Flappy Bird', exact: true}).focus();
    await page.keyboard.press('Enter');
    await expect(page).toHaveURL(/\/flappy_bird\/$/);
    await page.goBack();
    await page.evaluate(() => window.scrollTo({top: 0, behavior: 'instant'}));
    await page.screenshot({path: info.outputPath(`gallery-${width}.png`), fullPage: true});
    await page.screenshot({path: info.outputPath(`gallery-${width}-preview.png`)});
    await page.goto('./');
    await expect(page.locator('#games article')).toHaveCount(3);
    await expect(page.locator('#games').getByRole('link', {name: 'IRON YARD', exact: true})).toHaveAttribute('href', './studio/games/iron-yard/');
    for (const title of ['Arena 3D', 'Flappy Bird', 'Survivor', 'Card Game']) {
      await expect(page.locator('#technical-demos').getByRole('heading', {name: title, exact: true})).toBeVisible();
      await expect(page.locator('#games').getByRole('heading', {name: title, exact: true})).toHaveCount(0);
    }
    await page.screenshot({path: info.outputPath(`landing-${width}.png`)});
  });
}
