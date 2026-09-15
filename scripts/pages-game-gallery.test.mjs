import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, readFileSync, existsSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {catalog} from './example-catalog.mjs';
import {DEMO_PAGES, renderLandingHtml} from './web-demo-pages.mjs';
import {galleryGames, emitGameGallery} from './pages-game-gallery.mjs';

test('every catalog game has a thumbnail and an existing Pages build destination', () => {
  const games = galleryGames(catalog);
  assert.deepEqual(games.map(game => game.id).sort(), catalog.filter(item => item.category === 'games').map(item => item.id).sort());
  for (const game of games) {
    assert.ok(game.gallery.description);
    assert.ok(game.gallery.thumbnailAlt);
    assert.ok(['2D', '3D'].includes(game.gallery.dimension));
    assert.ok(existsSync(new URL(`../assets/pages/thumbnails/${game.id}.jpg`, import.meta.url)), game.id);
    assert.ok(DEMO_PAGES.some(demo => demo.name === game.id) || game.gallery.playPath === 'studio/games/iron-yard/', game.id);
  }
});

test('gallery emits complete static HTML, images and styles under a project subpath', () => {
  const site = mkdtempSync(join(tmpdir(), 'kagura-gallery-'));
  try {
    emitGameGallery({site, catalog});
    const html = readFileSync(join(site, 'examples/index.html'), 'utf8');
    assert.match(html, /lang="ja"/);
    assert.match(html, /href="\.\/examples.css"/);
    assert.match(html, /href="\.\.\/studio\/"/);
    assert.ok(existsSync(join(site, 'examples/examples.css')));
    for (const game of galleryGames(catalog)) {
      const path = game.gallery.playPath ?? `${game.id}/`;
      assert.ok(html.includes(`href="../${path}"`), game.id);
      assert.ok(existsSync(join(site, `examples/thumbnails/${game.id}.jpg`)), game.id);
      assert.ok(html.includes(`src="./thumbnails/${game.id}.jpg"`), game.id);
    }
    assert.doesNotMatch(html, /<(script|canvas|iframe)\b/);
    assert.doesNotMatch(html, /(?:href|src)="\//);
    assert.match(renderLandingHtml({demos: DEMO_PAGES}), /href="\.\/examples\/"/);
  } finally {
    rmSync(site, {recursive: true, force: true});
  }
});
