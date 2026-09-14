// Rendering only: the game supplies roads, repaired elevations and unlock state.
export function renderExpeditionMap(atlas,{cursor,locked,escape}){
  const map=atlas.expedition;if(!map)return '';
  const anchors=atlas.anchors??[];
  const canTravel=atlas.near_waypoint&&!locked&&atlas.travel_target==null;
  return `<section class="atlas-expedition" aria-label="地域の探索進行">
    <div class="expedition-heading"><div><p class="eyebrow">EXPLORE & CONNECT</p><h3>${escape(atlas.name??'')} · ${escape(map.name)}</h3></div><strong>解放 ${anchors.filter(a=>a.unlocked).length} / ${anchors.length}</strong></div>
    <div class="expedition-layout"><div><svg viewBox="0 0 100 80" class="expedition-map" role="img" aria-label="街道と高台の探索経路">
      <rect width="100" height="80" fill="#243e3b"/>${map.contours}
      <path d="${escape(map.road_path)}" fill="none" stroke="#131e20" stroke-width="2.1" stroke-linecap="round"/>
      <path d="${escape(map.road_path)}" fill="none" stroke="#dfc487" stroke-width=".9" stroke-linecap="round"/>
      ${map.features??''}
      ${anchors.map(a=>`<g transform="translate(${a.x} ${a.z})"><circle r="3" fill="${a.unlocked?'#b6e6cd':'#312d37'}" stroke="#f1d99c" stroke-width=".6"/><text text-anchor="middle" y="1.15" fill="${a.unlocked?'#193b2d':'#fff2ca'}" font-size="3.6">${a.id+1}</text></g>`).join('')}
      <circle cx="${atlas.waypoint_x}" cy="${atlas.waypoint_z}" r="1.8" fill="#f2f4da"/>
    </svg><p class="expedition-legend"><span>低地・補給路</span><i></i><span>高台・廃墟</span></p></div>
    <div class="expedition-anchors">${anchors.map(a=>`<button data-expedition-site="${a.id}" data-key="13" data-selection="${a.id+4}" data-focus="expedition-${a.id}" aria-pressed="${cursor===a.id+4}" ${canTravel&&a.unlocked?'':'disabled'}><span class="expedition-number">${a.id+1}</span><span><strong>${escape(a.name)}</strong><small>${escape(a.reward)} · 高さ ${a.height.toFixed(1)}</small><em>${a.unlocked?'帰還地点へ移動':'宝箱を開けると帰還地点を解放'}</em></span><b>${a.unlocked?'↗':'◇'}</b></button>`).join('')}</div></div>
    <p class="expedition-help">${map.features?'橋で川を渡り、山腹の抜け洞窟から高台へ。':'低地で補給し、尾根を登ってレア装備を探す。'}宝箱で解放した帰還地点はセーブに残ります。灯火か帰還地点のそばで移動できます。</p>
  </section>`;
}
