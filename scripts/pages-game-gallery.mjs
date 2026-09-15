import {cpSync, mkdirSync, writeFileSync} from 'node:fs';
import {join} from 'node:path';

const ASSETS = new URL('../assets/pages/', import.meta.url);
const escape = value => String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

// Catalog owns presentation metadata; this build-time template performs no runtime loading.
export function galleryExamples(catalog) {
  return catalog.filter(item => item.gallery).sort((a, b) => a.gallery.order - b.gallery.order);
}

export function emitGameGallery({site, catalog}) {
  const games = galleryExamples(catalog);
  const destination = join(site, 'examples');
  mkdirSync(join(destination, 'thumbnails'), {recursive: true});
  cpSync(new URL('examples.css', ASSETS), join(destination, 'examples.css'));
  for (const game of games) {
    // Missing screenshots must fail the build instead of publishing broken cards.
    cpSync(new URL(`thumbnails/${game.id}.jpg`, ASSETS), join(destination, 'thumbnails', `${game.id}.jpg`));
  }
  writeFileSync(join(destination, 'index.html'), renderGameGallery(games));
}

function renderGameGallery(games) {
  const sections = [
    ['game', 'games', 'ゲーム', '戦闘や探索、育成などを組み合わせて遊べるゲーム。'],
    ['demo', 'demos', '技術デモ', '物理・入力・描画・ゲームループの実装を試せるサンプル。'],
  ];
  return `<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <meta name="description" content="Kagura のゲームと技術デモ。画面、内容、入力方法、プレイとソースコードへのリンクを掲載しています。">
  <meta name="color-scheme" content="dark">
  <title>ゲームと技術デモ | Kagura Playground</title>
  <link rel="stylesheet" href="./examples.css">
</head>
<body>
  <a class="skip-link" href="#examples">一覧へスキップ</a>
  <header class="site-header">
    <a class="brand" href="../"><span class="brand-mark" aria-hidden="true">K</span>KAGURA <span class="brand-sub">PLAYGROUND</span></a>
    <nav aria-label="メインナビゲーション">
      <a href="../studio/">Studio <span aria-hidden="true">↗</span></a>
      <a href="https://github.com/mizchi/kagura">GitHub <span aria-hidden="true">↗</span></a>
    </nav>
  </header>
  <main id="examples">
    <section class="intro" aria-labelledby="gallery-title">
      <p class="eyebrow">Kagura <span aria-hidden="true">/</span> ${games.filter(item => item.kind === 'game').length} 本のゲーム・${games.filter(item => item.kind === 'demo').length} 本の技術デモ</p>
      <h1 id="gallery-title">ゲームと技術デモ</h1>
      <p class="intro-copy">Kagura で作成したゲームと、機能を試すための技術デモです。ブラウザから開けます。</p>
      <div class="collection-nav">
        <nav aria-label="サンプルの分類">
          ${sections.map(([kind, id, title]) => `<a href="#${id}">${title} <span>${games.filter(item => item.kind === kind).length}</span><span aria-hidden="true">↓</span></a>`).join('')}
        </nav>
      </div>
    </section>
    ${sections.map(([kind, id, title, description]) => `<section class="collection" id="${id}" aria-labelledby="heading-${id}">
      <div class="section-heading"><h2 id="heading-${id}">${title}</h2><p>${description}</p></div>
      <div class="game-grid">${games.filter(game => game.kind === kind).map(game => renderCard(game, games.indexOf(game))).join('\n')}</div>
    </section>`).join('\n')}
    <aside class="create-panel"><div><h2>エディタとその他の技術デモ</h2><p>Studio ではシーンやモデルの編集、モーションの確認ができます。描画や物理などの機能を個別に試せるデモもあります。</p></div><div class="create-links"><a href="../studio/">Studio を開く <span aria-hidden="true">↗</span></a><a href="../#technical-demos">その他の技術デモ <span aria-hidden="true">→</span></a></div></aside>
  </main>
  <footer><span>KAGURA / MoonBit Game Engine</span><span>サムネイルは実際のゲーム画面です。</span></footer>
</body>
</html>
`;
}

function renderCard(game, index) {
  const {gallery} = game;
  const playHref = `../${gallery.playPath ?? `${game.id}/`}`;
  return `<article class="game-card" aria-labelledby="title-${escape(game.id)}">
    <a class="thumbnail-link" href="${escape(playHref)}" tabindex="-1">
      <img src="./thumbnails/${escape(game.id)}.jpg" alt="${escape(gallery.thumbnailAlt)}" width="960" height="600" loading="${index < 3 ? 'eager' : 'lazy'}" decoding="async">
      <span class="image-label">${escape(gallery.dimension)} / ${escape(gallery.genre)}</span><span class="image-play" aria-hidden="true">↗</span>
    </a>
    <div class="card-body">
      <div class="card-heading"><h3 id="title-${escape(game.id)}"><a href="${escape(playHref)}">${escape(game.title)}</a></h3><span class="game-number" aria-hidden="true">${String(index + 1).padStart(2, '0')}</span></div>
      <p class="description">${escape(gallery.description)}</p>
      <p class="input">${escape(gallery.input)}</p>
      <div class="card-actions"><a class="play-link" href="${escape(playHref)}" aria-label="${escape(game.title)} を${game.kind === 'game' ? 'プレイ' : '開く'}">${game.kind === 'game' ? 'プレイする' : 'デモを開く'} <span aria-hidden="true">→</span></a><a class="source-link" href="https://github.com/mizchi/kagura/tree/main/examples/${escape(game.category)}/${escape(game.id)}" aria-label="${escape(game.title)} のソースコード">ソース <span aria-hidden="true">↗</span></a></div>
    </div>
  </article>`;
}
