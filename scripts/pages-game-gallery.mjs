import {cpSync, mkdirSync, writeFileSync} from 'node:fs';
import {join} from 'node:path';

const ASSETS = new URL('../assets/pages/', import.meta.url);
const escape = value => String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

// Catalog owns presentation metadata; this build-time template performs no runtime loading.
export function galleryGames(catalog) {
  return catalog.filter(item => item.category === 'games').sort((a, b) => a.gallery.order - b.gallery.order);
}

export function emitGameGallery({site, catalog}) {
  const games = galleryGames(catalog);
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
    ['3D', '3D のゲーム', 'シューティング、アクション RPG、メカ TPS など。'],
    ['2D', '2D のゲーム', 'カードゲーム、サバイバル、ダンジョン探索など。'],
  ];
  return `<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <meta name="description" content="Kagura のサンプルゲーム一覧。各ゲームの画面、内容、入力方法、プレイとソースコードへのリンクを掲載しています。">
  <meta name="color-scheme" content="dark">
  <title>ゲーム一覧 | Kagura Playground</title>
  <link rel="stylesheet" href="./examples.css">
</head>
<body>
  <a class="skip-link" href="#games">ゲーム一覧へスキップ</a>
  <header class="site-header">
    <a class="brand" href="../"><span class="brand-mark" aria-hidden="true">K</span>KAGURA <span class="brand-sub">PLAYGROUND</span></a>
    <nav aria-label="メインナビゲーション">
      <a href="../studio/">Studio <span aria-hidden="true">↗</span></a>
      <a href="https://github.com/mizchi/kagura">GitHub <span aria-hidden="true">↗</span></a>
    </nav>
  </header>
  <main id="games">
    <section class="intro" aria-labelledby="gallery-title">
      <p class="eyebrow">Kagura <span aria-hidden="true">/</span> ${games.length} 本のサンプルゲーム</p>
      <h1 id="gallery-title">ゲーム一覧</h1>
      <p class="intro-copy">Kagura で作成したサンプルゲームの一覧です。各ゲームをブラウザでプレイできます。</p>
      <div class="collection-nav">
        <nav aria-label="ゲームの種類">
          ${sections.map(([dimension]) => `<a href="#games-${dimension.toLowerCase()}">${dimension} のゲーム <span>${games.filter(g => g.gallery.dimension === dimension).length}</span><span aria-hidden="true">↓</span></a>`).join('')}
        </nav>
        <p class="requirement">プレイには WebGPU 対応ブラウザが必要です</p>
      </div>
    </section>
    ${sections.map(([dimension, title, description]) => `<section class="collection" id="games-${dimension.toLowerCase()}" aria-labelledby="heading-${dimension}">
      <div class="section-heading"><h2 id="heading-${dimension}">${title}</h2><p>${description}</p></div>
      <div class="game-grid">${games.filter(game => game.gallery.dimension === dimension).map(game => renderCard(game, games.indexOf(game))).join('\n')}</div>
    </section>`).join('\n')}
    <aside class="create-panel"><div><h2>エディタと機能デモ</h2><p>Studio ではシーンやモデルの編集、モーションの確認ができます。エンジンの各機能を試せるデモもあります。</p></div><div class="create-links"><a href="../studio/">Studio を開く <span aria-hidden="true">↗</span></a><a href="../">機能デモを見る <span aria-hidden="true">→</span></a></div></aside>
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
      <span class="image-label">${escape(gallery.genre)}</span><span class="image-play" aria-hidden="true">↗</span>
    </a>
    <div class="card-body">
      <div class="card-heading"><h3 id="title-${escape(game.id)}"><a href="${escape(playHref)}">${escape(game.title)}</a></h3><span class="game-number" aria-hidden="true">${String(index + 1).padStart(2, '0')}</span></div>
      <p class="description">${escape(gallery.description)}</p>
      <p class="input">${escape(gallery.input)}</p>
      <div class="card-actions"><a class="play-link" href="${escape(playHref)}" aria-label="${escape(game.title)} をプレイ">プレイする <span aria-hidden="true">→</span></a><a class="source-link" href="https://github.com/mizchi/kagura/tree/main/examples/games/${escape(game.id)}" aria-label="${escape(game.title)} のソースコード">ソース <span aria-hidden="true">↗</span></a></div>
    </div>
  </article>`;
}
