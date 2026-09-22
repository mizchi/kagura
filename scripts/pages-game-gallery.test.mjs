import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, readFileSync, existsSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {catalog} from './example-catalog.mjs';
import {DEMO_PAGES, renderLandingHtml} from './web-demo-pages.mjs';
import {galleryExamples, emitGameGallery} from './pages-game-gallery.mjs';

test('every catalog game has a thumbnail and an existing Pages build destination', () => {
  const games = galleryExamples(catalog);
  assert.deepEqual(games.map(game => game.id).sort(), catalog.filter(item => item.gallery).map(item => item.id).sort());
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
    assert.match(html, /lang="en"/);
    assert.doesNotMatch(html, /WebGPU/);
    assert.match(html, /href="\.\/examples.css"/);
    assert.match(html, /href="\.\.\/studio\/"/);
    const gamesSection = html.match(/<section class="collection" id="games"[\s\S]*?<\/section>/)?.[0] ?? '';
    const demosSection = html.match(/<section class="collection" id="demos"[\s\S]*?<\/section>/)?.[0] ?? '';
    for (const id of ['emberwing', 'hacknslash_3d', 'iron_yard']) assert.ok(gamesSection.includes(`title-${id}`), id);
    for (const id of ['arena3d', 'card_game', 'survivor', 'flappy_bird']) {
      assert.ok(demosSection.includes(`title-${id}`), id);
      assert.ok(!gamesSection.includes(`title-${id}`), id);
    }
    assert.ok(existsSync(join(site, 'examples/examples.css')));
    for (const game of galleryExamples(catalog)) {
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
