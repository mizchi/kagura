import {renderWebRuntimeImportMap} from '../../../../scripts/web-runtime-assets.mjs';
// Shared dev/gallery shell. Gameplay HUD is part of Kagura's capture surface.
export function renderHunterPage({scriptTag,homeHref,homeLabel,libPrefix}) {
  const escape=value=>String(value).replaceAll('&','&amp;').replaceAll('"','&quot;').replaceAll('<','&lt;');
  return `<!doctype html>
<html lang="ja"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
${renderWebRuntimeImportMap(libPrefix)}
<meta name="theme-color" content="#14231a"><title>ASHEN REALMS — 装備とスキルでつくるアクションRPG</title>
<link rel="stylesheet" href="./assets/hunter-ui.css"></head><body>
<main id="game-surface" data-kagura-surface aria-label="ASHEN REALMS ゲーム画面">
<canvas id="app" width="640" height="480" data-kagura-presentation="fullscreen" data-kagura-fit="viewport" tabindex="0" aria-label="冒険フィールド"></canvas>
<div id="hunter-hud"></div></main>
<nav class="presentation-tools" data-kagura-overlay aria-label="表示設定"><button id="fullscreen" type="button">全画面</button><details><summary>操作方法</summary><div>WASD：移動<br>左 / 右クリック：スキル1 / 2<br>J：通常攻撃<br>Space：回避<br>1〜4：技 / I：装備 / K：成長・スロット設定<br>Q・E：カメラ回転<br>ホイール：ズーム / R：視点リセット<br>O：カメラ設定 / Z：TPS切替<br>N：地形実験<br>Esc：一時停止・セーブ選択 / M：ミュート<br>ゲームパッド・タッチ操作対応<br><a href="${escape(homeHref)}">${escape(homeLabel)} ↗</a></div></details></nav>
<script>
const canvas=document.querySelector('canvas');canvas.addEventListener('contextmenu',e=>e.preventDefault());
const nav=document.querySelector('.presentation-tools');for(const type of ['mousedown','mouseup','keydown','keyup'])nav.addEventListener(type,e=>e.stopPropagation());
document.querySelector('#fullscreen').addEventListener('click',async()=>{try{await globalThis.__kaguraPresentation?.requestFullscreen()}catch{}canvas.focus({preventScroll:true})});
</script>
<script type="module" src="./assets/hunter-ui.mjs"></script>
${scriptTag}</body></html>`;
}
