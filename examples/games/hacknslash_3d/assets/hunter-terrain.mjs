// Configuration transport only. The game owns generation and validation.
export function createTerrainInput(){
  let pending=[];
  return {
    generate(values){if(values.length===5&&values.every(Number.isFinite))pending=[...values];},
    consume(){const values=pending;pending=[];return values;},
    clear(){pending=[];},
  };
}
const patterns=[
  ['平坦','高さのない比較基準。探索経路は保持します。'],
  ['Perlin','なだらかな丘に、細かな起伏を重ねます。'],
  ['Diamond Square','分割を繰り返し、不規則な尾根と谷を作ります。'],
  ['Voronoi','近い2つの種点までの距離差から、岩塊のような起伏を作ります。'],
  ['Voronoi + Perlin','岩塊の輪郭に、なだらかな丘のうねりを混ぜます。'],
  ['探索地形','低地の補給路から、尾根の廃墟へ。探索経路を先に決め、高低差と坂道を生成します。'],
];
const fields=[
  [2,'amplitude','起伏の高さ',0,8,.25],
  [3,'scale','地形の大きさ',6,48,1],
  [4,'roughness','細部の粗さ',.1,.85,.05],
];
export function renderTerrainPanel(view){
  const pattern=patterns[view.pattern]??patterns[0];
  return `<button class="close-panel" data-key="27" aria-label="一時停止メニューに戻る">←</button>
    <p class="eyebrow">SHAPE THE WILDS</p><h2>地形実験</h2>
    <p class="camera-preview-note">フィールドを止めて比較中 · 同じ視点・同じシード</p>
    <div class="terrain-patterns" role="group" aria-label="地形の生成方式">${patterns.map(([name],i)=>`<button data-terrain-pattern="${i}" aria-pressed="${view.pattern===i}" ${view.pattern===i?'data-autofocus':''} ${i===5&&view.expedition_available===false?'disabled':''}>${name}</button>`).join('')}</div>
    <p class="terrain-description">${pattern[1]}</p>
    <label class="terrain-seed">シード<input type="number" aria-label="地形のシード" data-terrain-field="1" min="-2147483646" max="2147483646" step="1" value="${view.seed}" ${view.pattern===5?'disabled':''}></label>
    <div class="camera-sliders terrain-sliders">${fields.map(([id,key,label,min,max,step])=>`<label><span>${label}<output data-terrain-output="${id}">${view[key]}</output></span><input type="range" aria-label="${label}" data-terrain-field="${id}" min="${min}" max="${max}" step="${step}" value="${view[key]}" ${view.pattern===0||view.pattern===5||(id===4&&view.pattern===3)?'disabled':''}></label>`).join('')}</div>
    <div class="terrain-actions"><button data-terrain-apply ${view.pattern===5?'disabled':''}>生成して比較</button><button data-terrain-next ${view.pattern===5?'disabled':''}>次のシード</button></div>
    <dl class="terrain-stats"><div><dt>実際の高低差</dt><dd>${(view.stats.maximum-view.stats.minimum).toFixed(2)}</dd></div><div><dt>最大傾斜</dt><dd>${(Math.atan(view.stats.max_slope)*180/Math.PI).toFixed(1)}°</dd></div><div><dt>地面の三角形</dt><dd>${view.stats.triangles.toLocaleString('ja-JP')}</dd></div><div><dt>生成＋描画準備</dt><dd>${view.generation_ms.toFixed(0)} ms</dd></div></dl>
    <p class="camera-help">探索地形はセーブのワールドシードと地域から生成します。他の方式は比較用です。全方式を同じ三角形で描画。方式ボタンで即比較、数値は「生成して比較」で反映します。</p>
    <div class="camera-actions"><button data-key="79">カメラ設定</button><button data-key="80">冒険を再開する</button></div>`;
}

export function bindTerrainPanel(root,input){
  root.addEventListener('input',event=>{
    const field=event.target.dataset.terrainField;
    if(field===undefined)return;
    const output=root.querySelector(`[data-terrain-output="${field}"]`);
    if(output)output.textContent=event.target.value;
  });
  root.addEventListener('click',event=>{
    const button=event.target.closest('[data-terrain-pattern],[data-terrain-apply],[data-terrain-next]');
    if(!button)return;
    event.preventDefault();event.stopPropagation();
    const fields=[...root.querySelectorAll('[data-terrain-field]')];
    if(!fields.every(field=>field.reportValidity()))return;
    const pattern=Number(button.dataset.terrainPattern??root.querySelector('[data-terrain-pattern][aria-pressed=true]').dataset.terrainPattern);
    const values=[pattern,...[1,2,3,4].map(id=>Number(root.querySelector(`[data-terrain-field="${id}"]`).value))];
    if(button.hasAttribute('data-terrain-next'))values[1]=values[1]>=2147483646?0:values[1]+1;
    input.generate(values);
  });
}
