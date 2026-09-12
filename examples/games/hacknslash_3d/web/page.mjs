import {renderWebRuntimeImportMap} from '../../../../scripts/web-runtime-assets.mjs';
// Shared dev/gallery shell. Gameplay HUD is part of Kagura's capture surface.
export function renderHunterPage({scriptTag,homeHref,homeLabel,libPrefix}) {
  const escape=value=>String(value).replaceAll('&','&amp;').replaceAll('"','&quot;').replaceAll('<','&lt;');
  return `<!doctype html>
<html lang="ja"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
${renderWebRuntimeImportMap(libPrefix)}
<meta name="theme-color" content="#14231a"><title>ASHEN HUNT — 灰の森</title>
<link rel="stylesheet" href="./assets/hunter-ui.css"></head><body>
<main id="game-surface" data-kagura-surface aria-label="ASHEN HUNT ゲーム画面">
<canvas id="app" width="640" height="480" data-kagura-presentation="fullscreen" data-kagura-fit="viewport" tabindex="0" aria-label="灰の森の3D狩場"></canvas>
<div id="hunter-hud"></div></main>
<nav class="presentation-tools" data-kagura-overlay aria-label="表示設定"><button id="fullscreen" type="button">全画面</button><details><summary>操作方法</summary><div>WASD：移動<br>左クリック / J：斬撃<br>Space：回避<br>1〜4：技 / I：装備 / K：成長<br>Q・E / 右ドラッグ：カメラ回転<br>ホイール：ズーム / R：視点リセット<br>P：一時停止 / M：ミュート<br><a href="${escape(homeHref)}">${escape(homeLabel)} ↗</a></div></details></nav>
<script>
const canvas=document.querySelector('canvas');canvas.addEventListener('contextmenu',e=>e.preventDefault());
const nav=document.querySelector('.presentation-tools');for(const type of ['mousedown','mouseup','keydown','keyup'])nav.addEventListener(type,e=>e.stopPropagation());
document.querySelector('#fullscreen').addEventListener('click',async()=>{try{await globalThis.__kaguraPresentation?.requestFullscreen()}catch{}canvas.focus({preventScroll:true})});
</script>
<script type="module" src="./assets/hunter-ui.mjs"></script>
${scriptTag}</body></html>`;
}
