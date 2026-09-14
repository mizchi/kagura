import {renderExpeditionMap} from './expedition-map.mjs';
const themes=['ashwood','rustland','mire','belfry'];
const descriptions=[
  '古街道を東へたどると荒野へ。南の巡礼路は霧の湿地につながる。',
  '風に削られた岩と枯れ木の平原。南には鐘楼の廃墟が残る。',
  '青い霧が漂う湿地。東の石の道を進むと鐘楼に至る。',
  '崩れた石碑と灯火が残る廃墟。西は湿地、北は赤錆の荒野。',
];
export function renderWorldMap(hud,{icon,escape}) {
  const atlas=hud.atlas;if(!atlas)return '<p>このマップにはウェイポイントがありません。</p>';
  const selected=atlas.regions[hud.cursor]??atlas.regions[atlas.current];
  const travelling=atlas.travel_target!==undefined&&atlas.travel_target!==null;
  const canTravel=atlas.near_waypoint&&selected.unlocked&&(selected.id!==atlas.current||(atlas.expedition&&!atlas.at_region_waypoint))&&!travelling&&!hud.weapon_locked;
  const status=selected.id===atlas.current?'現在地':selected.unlocked?'ウェイポイント解放済み':selected.visited?'灯火を探してください':'未踏の地';
  return `<p class="eyebrow">THE OLD PILGRIM ROAD</p><h2>世界地図</h2>
    <p class="atlas-intro">灯火をつなぎ、夜の向こうへ。</p>
    <div class="atlas-layout">
      <div class="atlas-chart" aria-label="接続された4つのエリア">
        <div class="atlas-compass" aria-hidden="true">N <span>✧</span></div>
        <svg class="atlas-roads" viewBox="0 0 100 100" aria-hidden="true"><path d="M25 25H75V75H25ZM25 25V75"/></svg>
        ${atlas.regions.map(region=>`<button class="atlas-region ${themes[region.id]} ${region.visited?'visited':''} ${region.id===hud.cursor?'selected':''}" data-key="0" data-selection="${region.id}" data-world-region="${region.id}" data-focus="region-${region.id}" aria-pressed="${region.id===hud.cursor}" aria-label="${escape(region.name)}・${region.id===atlas.current?'現在地':region.unlocked?'解放済み':'未解放'}" style="--rx:${region.x};--rz:${region.z}"><span class="atlas-landscape" aria-hidden="true">${['♠','⋀','≈','♜'][region.id]}</span><span class="atlas-node ${region.unlocked?'lit':''}">${icon('waypoint')}</span><strong>${escape(region.name)}</strong><small>${region.id===atlas.current?'● 現在地':region.unlocked?'灯火がともっている':region.visited?'灯火を探す':'未踏の地'}</small></button>`).join('')}
        <span class="atlas-map-caption">灰の領域 / THE ASHEN MARCHES</span>
      </div>
      <aside class="atlas-detail" aria-label="選択したウェイポイント">
        <div class="atlas-destination ${themes[selected.id]}"><span>${icon('waypoint')}</span><small>WAYPOINT ${String(selected.id+1).padStart(2,'0')}</small><h3>${escape(selected.name)}</h3><p>${escape(selected.subtitle)}</p></div>
        <p class="atlas-status ${selected.unlocked?'lit':''}">${status}</p>
        <p class="atlas-description">${descriptions[selected.id]}</p>
        <dl class="atlas-facts"><div><dt>危険度</dt><dd>${'◆'.repeat(selected.tier)}${'◇'.repeat(3-selected.tier)}</dd></div><div><dt>接続先</dt><dd>${atlas.regions.filter(r=>Math.abs(r.x-selected.x)+Math.abs(r.z-selected.z)===1).map(r=>escape(r.name)).join('・')}</dd></div></dl>
        <button class="atlas-travel" data-key="13" data-selection="${selected.id}" data-focus="world-travel" ${canTravel?'':'disabled'}>${travelling?'灯火への道を準備中…':selected.id===atlas.current?(canTravel?'地域の灯火へ戻る':'このエリアにいます'):!selected.unlocked?'ウェイポイント未解放':!atlas.near_waypoint?'灯火の近くで移動できます':hud.weapon_locked?'動作終了後に移動できます':'この灯火へジャンプ'}<span>${travelling?'◌':'→'}</span></button>
        ${travelling?`<div class="atlas-progress" role="progressbar" aria-label="移動先を準備中" aria-valuenow="${atlas.regions[atlas.travel_target].progress}" aria-valuemin="0" aria-valuemax="100"><i style="width:${atlas.regions[atlas.travel_target].progress}%"></i></div>`:''}
        <p class="atlas-help">道を歩いてエリアを越えられます。<br>灯火に近づくとウェイポイントが解放されます。</p>
      </aside>
    </div>${renderExpeditionMap(atlas,{cursor:hud.cursor,locked:hud.weapon_locked,escape})}<p class="atlas-footer">${atlas.near_waypoint?'✧ 灯火のそばにいます。解放済みの地点へ移動できます。':'灯火のそばから、解放済みの地点へ移動できます。'}<span>G / ESC で戻る</span></p>`;
}
