import {createControlInput, bindVirtualStick} from '@kagura-web/kagura-controls.js';
import {createHunterInput, skillStatus} from './hunter-input.mjs';
import {createInventoryPanel} from './hunter-inventory.mjs';
import {bindHunterArts} from './hunter-arts.mjs';
import {renderWorldMap} from './hunter-world-map.mjs';
import {renderSkillTree} from './hunter-skill-tree.mjs';

const paths={
  waypoint:'M17 2 26 17 17 30 8 17ZM3 28q14 9 28 0M17 9v13',
  spear:'M5 30 24 8M20 8 30 3 25 14ZM10 22l3 3',
  fist:'M10 18V8q0-4 4-2v10-11q2-3 4 0v11-9q3-3 4 0v10-7q4-2 4 2v12l-7 7H10L4 20q-1-4 3-3l5 5',
  bow:'M10 3q25 14 0 28L19 17ZM3 17h27M25 12l5 5-5 5',
  blade:'M6 26 25 5l2 9-15 15M6 22l8 8M5 31l5-5',
  whirl:'M9 8a12 12 0 1 1-4 14M4 8h7V2M11 22 24 9M17 25l-9-9',
  fire:'M18 3c3 9-4 10-1 15 3-1 6-4 6-7 9 10 4 21-6 21C4 32 2 20 10 12c-1 5 1 7 3 8-3-8 6-10 5-17Z',
  frost:'M17 2v30M4 9l26 16M4 25 30 9M12 5l5 5 5-5M12 29l5-5 5 5M4 15l7-1-1-7M24 27l-1-7 7-1',
  dodge:'M5 12h12M3 19h10M7 26h9M20 8l9 10-9 10M16 18h13',
  bag:'M10 10V6h14v4M7 11h20l3 19H4Z M11 20h12',
  book:'M17 8C12 3 5 5 3 6v24c7-3 11-2 14 1 3-3 7-4 14-1V6c-2-1-9-3-14 2Zm0 0v23',
  pause:'M11 6v23M23 6v23',
  heart:'M17 29 5 17C-3 5 10 0 17 10 24 0 37 5 29 17Z',
  blood:'M17 2C16 9 6 17 6 23a11 11 0 0 0 22 0C28 17 18 9 17 2Z',
  lightning:'M20 2 6 20h10l-2 12L29 13H18Z',
  eye:'M2 17Q17-3 32 17 17 37 2 17Zm20 0a5 5 0 1 1-10 0 5 5 0 0 1 10 0',
  shield:'M17 3 4 8v10q1 8 13 13 12-5 13-13V8ZM17 9v15M11 17h12',
};
const icon=name=>`<svg viewBox="0 0 34 34" aria-hidden="true"><path d="${paths[name]}"/></svg>`;
const escape=value=>String(value).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('"','&quot;');
const root=document.querySelector('#hunter-hud');
const controls=createControlInput();
const input=createHunterInput(controls);
globalThis.__ashenControls=input;
let current=null;
let panelKey='';
let showTreeDetail=false;
const names=['処刑の一撃','回転斬り','分裂火弾','霜の輪'];
root.innerHTML=`
  <div class="edge-shade" aria-hidden="true"></div>
  <section class="vitals" aria-label="狩人の状態">
    <div class="hunter-seal" aria-hidden="true">${icon('blade')}</div>
    <div class="vital-lines"><div class="vital-caption"><span>HUNTER <b id="hunter-level">01</b></span><span id="health-text">—</span></div>
    <div class="health-track" role="progressbar" aria-label="体力"><i id="health-fill"></i></div>
    <div class="xp-track" role="progressbar" aria-label="経験値"><i id="xp-fill"></i></div></div>
  </section>
  <section class="expedition" aria-label="狩場の目標"><p id="night-label">第一夜</p><h1 id="region-name">灰の森</h1><div><i></i><span id="hunt-objective">灯火をたどり、群れを狩る</span></div></section>
  <aside class="map-card" aria-label="灰の森の地図"><span id="minimap-region">ASHWOOD</span><svg viewBox="0 0 100 80" aria-hidden="true"><path class="map-outline" d="M2 2h96v76H2z"/><path class="map-road" d="M2 42Q18 62 35 40T67 33 98 44M43 36v30"/><path class="map-clearing" d="M14 43h12v12H14zM33 30h12v12H33zM53 23h14v14H53zM70 41h14v14H70zM37 56h12v12H37z"/><g class="map-lights"><circle cx="27" cy="46" r="2"/><circle cx="51" cy="28" r="2"/><circle cx="87" cy="48" r="2"/></g><g id="minimap-exits" stroke="#bdb589" fill="#bdb589" stroke-width="1"/><path id="minimap-waypoint" d="M0 -3 3 0 0 3 -3 0Z" fill="#e9d294" stroke="#284633" stroke-width=".6"/><circle id="map-player" r="2.2" cx="20" cy="49"/></svg><small id="minimap-subtitle">灯火の旧街道</small></aside>
  <div class="utility" aria-label="メニュー"><button data-key="73" aria-label="装備袋">${icon('bag')}<span>装備 <kbd>I</kbd></span></button><button data-key="75" aria-label="技と成長">${icon('book')}<span>技 <kbd>K</kbd><b id="tree-sp-badge" hidden></b></span></button><button data-key="71" aria-label="世界地図">${icon('waypoint')}<span>地図 <kbd>G</kbd></span></button><button data-key="27" aria-label="一時停止メニュー">${icon('pause')}<kbd>ESC</kbd></button></div>
  <div class="journey-note"><span>ASHEN HUNT</span><p>鐘が消えるまで、夜は明けない。</p></div>
  <div class="combat-controls">
    <div id="move-stick" role="group" aria-label="仮想移動スティック"><div class="stick-ring"><i class="stick-cross"></i><i id="stick-thumb"></i></div><span>移動</span></div>
    <div class="action-dock">
      <div class="hunter-arts" aria-label="狩人の戦技">
        <button id="guard-button" data-hold="guard" aria-label="盾ガード" title="Fを押して構える。正面120度の攻撃を軽減。構え始めは完全防御。"><span>${icon('shield')}</span><strong>盾ガード</strong><small id="guard-status">F / 長押し</small><i class="guard-reserve"><i id="guard-reserve-fill"></i></i></button>
        <button id="astral-button" data-key="84" aria-label="星落とし" title="Tで照準、地面をクリック／タップして指定。円の中に0.5秒後に落雷。"><span>${icon('lightning')}</span><strong>星落とし</strong><small id="astral-status">T / 位置指定</small></button>
        <button id="dash-strike-button" data-key="86" aria-label="踏込斬り" title="Vで踏み込み、敵の手前で止まって斬る。壁で停止、回避で中断。"><span>${icon('blade')}</span><strong>踏込斬り</strong><small id="dash-strike-status">V</small></button>
      </div>
      <div class="learned-arts" id="learned-arts" aria-label="習得した技" hidden></div>
      <label class="weapon-picker">武器 <select id="player-weapon" aria-label="プレーヤーの武器"></select><kbd>X</kbd></label>
      <div class="skill-buttons">${names.map((name,i)=>`<button class="skill skill-${i}" data-key="${49+i}" data-skill="${i}" aria-label="${name}"><kbd>${i+1}</kbd><span class="skill-glyph">${icon(['blade','whirl','fire','frost'][i])}<i class="cooldown-sweep"></i></span><strong>${name}</strong><small class="skill-status">使用可能</small><span class="skill-tooltip"></span></button>`).join('')}</div>
      <button id="charge-button" class="charge-button" data-key="67" aria-label="突進"><span>${icon('dodge')}</span><strong>突進</strong><small id="charge-status">C</small></button>
      <div class="primary-actions"><button id="attack-button" data-hold="attack" aria-label="通常攻撃"><span id="weapon-icon">${icon('blade')}</span><strong id="weapon-action">斬撃</strong><kbd>J / 左クリック</kbd></button><button id="dodge-button" data-key="32" aria-label="回避"><span>${icon('dodge')}</span><strong>回避</strong><small id="dodge-status">SPACE</small></button></div>
    </div>
  </div>
  <div id="target-surface" aria-label="星落としの位置指定" hidden></div>
  <div id="target-hint" role="status" hidden><strong>星落とし</strong><span>地面をクリック／タップして発動</span><button data-key="84" aria-label="位置指定を取り消す">取消 <kbd>ESC</kbd></button></div>
  <button id="waypoint-prompt" class="waypoint-prompt" data-key="71" aria-label="ウェイポイントを使う" hidden>${icon('waypoint')}<span>ウェイポイント</span><kbd>G</kbd></button>
  <section id="hunter-panel" class="modal-wrap" hidden aria-live="polite"></section>
  <div id="combat-feedback" role="status" hidden></div>
  <div id="damage-edge" aria-hidden="true"></div>
`;
const $=id=>document.getElementById(id);
const renderArts=bindHunterArts({root,input});
const inventoryPanel=createInventoryPanel($('hunter-panel'),{input,icon,escape});
$('player-weapon').addEventListener('change',e=>{
  input.tap(88,Number(e.target.value));
  document.querySelector('#app')?.focus({preventScroll:true});
});
const setText=(id,value)=>{const e=$(id);if(e.textContent!==String(value))e.textContent=String(value);};
const stick=$('move-stick');
const clear=()=>{input.clear();virtualStick.reset();$('stick-thumb').style.transform='translate(0,0)';root.querySelectorAll('[data-pressed]').forEach(e=>e.removeAttribute('data-pressed'));};

for(const event of ['mousedown','mouseup','touchstart','touchmove','touchend','touchcancel']) root.addEventListener(event,e=>e.stopPropagation(),{passive:true});
// Keep actual keyboard controls working when focus is on a HUD button.
root.addEventListener('keydown',e=>{if(e.target instanceof HTMLButtonElement && ['Space','Enter'].includes(e.code))e.stopPropagation();});
root.addEventListener('keyup',e=>{if(e.target instanceof HTMLButtonElement && ['Space','Enter'].includes(e.code))e.stopPropagation();});

const virtualStick=bindVirtualStick(stick, {
  input: controls,
  radius: 48,
  enabled: () => !current?.paused && current?.menu === 'none',
  center: () => {
    const rect=stick.querySelector('.stick-ring').getBoundingClientRect();
    return {x:rect.x+rect.width/2,y:rect.y+rect.height/2};
  },
  onChange: vector => {
    $('stick-thumb').style.transform=`translate(${vector.x*36}px,${vector.y*36}px)`;
  },
});

function activate(button,e){
  if(button.disabled)return;
  const selection=Number(button.dataset.selection??-1);
  if(button.dataset.hold){input.tap(button.dataset.hold==='guard'?70:74);input.hold(e.pointerId,button.dataset.hold);button.setPointerCapture(e.pointerId);button.dataset.pressed='';}
  else if(button.dataset.key)input.tap(Number(button.dataset.key),selection);
}
root.addEventListener('pointerdown',e=>{
  const b=e.target.closest('button');if(!b)return;
  e.stopPropagation();
  if(b.closest('.combat-controls')){e.preventDefault();activate(b,e);}
});
for(const type of ['pointerup','pointercancel','lostpointercapture'])root.addEventListener(type,e=>{input.release(e.pointerId);e.target.closest('button')?.removeAttribute('data-pressed');});
root.addEventListener('click',e=>{
  const b=e.target.closest('button');if(!b||b.disabled||b.closest('[data-inventory-view]'))return;
  if(b.closest('.combat-controls') && e.detail!==0)return;
  e.preventDefault();e.stopPropagation();
  if(b.hasAttribute('data-tree-return')){
    const node=$('hunter-panel').querySelector('[data-tree-node][aria-pressed=true]');
    node?.focus({preventScroll:true});node?.scrollIntoView({block:'center'});return;
  }
  if(b.dataset.key==='0'){
    showTreeDetail=b.hasAttribute('data-tree-node')&&matchMedia('(max-width:760px)').matches;
    if(showTreeDetail&&current?.cursor===Number(b.dataset.selection)){
      $('hunter-panel').querySelector('.tree-detail')?.scrollIntoView({block:'start'});showTreeDetail=false;return;
    }
    input.select(Number(b.dataset.selection));return;
  }
  input.tap(b.dataset.hold?(b.dataset.hold==='guard'?70:74):Number(b.dataset.key),Number(b.dataset.selection??-1));
});
window.addEventListener('blur',()=>{inventoryPanel.cancelDrag();clear();});
const heldKeyboardCodes=new Set([
  'KeyW','KeyA','KeyS','KeyD','KeyQ','KeyE','KeyR','KeyJ','KeyM','KeyF',
  'ArrowUp','ArrowDown','ArrowLeft','ArrowRight','ShiftLeft','ShiftRight',
  'Digit7','F2','F3','F4','F5',
]);
// Discrete keys are intents, retained until a simulation tick consumes them.
// A short key tap must survive a busy GPU frame just like a touch button tap.
window.addEventListener('keydown',e=>{
  if(current?.menu==='inventory'&&inventoryPanel.handleKeyDown(e)){e.preventDefault();e.stopImmediatePropagation();return;}
  if(e.code==='Escape' && !e.ctrlKey && !e.metaKey && !e.altKey){
    e.preventDefault();e.stopImmediatePropagation();
    if(!e.repeat)input.tap(27);
    return;
  }
  if(e.ctrlKey || e.metaKey || e.altKey || e.target?.isContentEditable || e.target?.closest?.('input,textarea,select'))return;
  if(e.target instanceof HTMLButtonElement && ['Space','Enter'].includes(e.code))return;
  const keys={Space:32,Enter:13,Escape:27,KeyP:80,KeyI:73,KeyK:75,KeyG:71,KeyX:88,KeyC:67,KeyT:84,KeyV:86,Digit1:49,Digit2:50,Digit3:51,Digit4:52,Digit5:53,Digit6:54,Digit8:56};
  if(current?.menu==='inventory')keys.KeyE=69;
  const code=keys[e.code];
  if(!code){
    // Held keys still reach the engine, but must not invoke native text input
    // (and its warning bell on macOS), including auto-repeat and HUD focus.
    if(heldKeyboardCodes.has(e.code))e.preventDefault();
    return;
  }
  e.preventDefault();e.stopImmediatePropagation();
  if(!e.repeat)input.tap(code);
});
window.addEventListener('resize',()=>{inventoryPanel.cancelDrag();clear();});
document.addEventListener('visibilitychange',()=>{if(document.hidden){inventoryPanel.cancelDrag();clear();}});

let previousPanelState="";
function panel(hud){
  const state=hud.mode!=='playing'?hud.mode:hud.menu!=='none'?hud.menu:hud.paused?'pause':'';
  const signature=JSON.stringify([state,hud.paused,hud.muted,hud.skill_points,hud.cursor,hud.inventory,hud.equipment,hud.inventory_grid,state==='waypoints'?hud.atlas:null,hud.nodes,hud.offers]);
  if(signature===panelKey)return;panelKey=signature;
  const el=$('hunter-panel');el.hidden=!state;
  el.setAttribute('aria-live',state==='inventory'?'off':'polite');
  root.dataset.blocked=state?'true':'false';
  const changed=state!==previousPanelState;
  previousPanelState=state;
  if(state!=='inventory')inventoryPanel.close();
  if(!state){
    if(changed){clear();document.querySelector('#app')?.focus({preventScroll:true});}
    return;
  }
  const oldPanel=el.querySelector('.hunter-panel');
  const scrollTop=changed?0:(oldPanel?.scrollTop??0);
  const focusedKey=el.contains(document.activeElement)?document.activeElement.dataset.key:undefined;
  const focusedName=el.contains(document.activeElement)?document.activeElement.dataset.focus:undefined;
  const focusedTree=el.contains(document.activeElement)&&document.activeElement.hasAttribute('data-tree-node');
  clear();
  const close=`<button class="close-panel" data-key="27" aria-label="${hud.paused?'一時停止メニューに戻る':'閉じる'}">${hud.paused?'←':'×'}</button>`;
  const heading=(eyebrow,title)=>`<p class="eyebrow">${eyebrow}</p><h2>${title}</h2>`;
  let body='';
  if(state==='title')body=`${heading('A HUNTER’S NIGHT','ASHEN HUNT')}<p class="title-jp">灰の森に、灯を。</p><p class="panel-description">途切れた旧街道。眠らない群れ。<br>灯火をたどり、夜の狩場へ。</p><button class="begin-button" data-key="32">狩りを始める <span>→</span></button><small>WASDで移動 · 左クリックで通常攻撃 · Xで武器切替 · Cで突進<br>モバイルでは画面のスティックとボタンで操作</small>`;
  if(state==='character_select')body=`${heading('CHOOSE YOUR OATH','狩人の誓い')}<p class="panel-description">4つの技を携え、灰の森へ踏み入る。</p><div class="oath-list">${['刃の狩人','術の狩人','呪弾の狩人'].map((n,i)=>`<button data-key="13" data-selection="${i}" class="${hud.cursor===i?'selected':''}">${icon(['blade','fire','frost'][i])}<strong>${n}</strong><small>${['体力と近接攻撃に優れる','術の威力に優れる','遠距離から群れを狙う'][i]}</small><span>→</span></button>`).join('')}</div>`;
  if(state==='gameover')body=`${heading('THE NIGHT REMAINS','灯は、まだ消えない。')}<p class="panel-description">灰の森で倒れた。もう一度、夜の向こうへ。</p><button class="begin-button" data-key="32">再び立ち上がる →</button>`;
  if(state==='pause')body=`<div class="pause-mark">${icon('pause')}</div>${heading('THE NIGHT CAN WAIT','一時停止')}<p class="panel-description">ここで、ひと息。<br>狩場の時間は止まっています。</p><div class="pause-actions"><button class="begin-button" data-key="27" data-autofocus>狩りを再開する <kbd>ESC</kbd></button><button data-key="73">${icon('bag')}<span>装備袋</span><kbd>I</kbd></button><button data-key="75">${icon('book')}<span>技と成長</span><kbd>K</kbd></button><button data-key="71">${icon('waypoint')}<span>世界地図</span><kbd>G</kbd></button><button data-key="77" aria-label="サウンド" aria-pressed="${!hud.muted}"><span>サウンド</span><strong>${hud.muted?'OFF':'ON'}</strong><kbd>M</kbd></button></div><p class="pause-hint">メニューを確認している間も一時停止します。</p>`;
  if(state==='inventory')body=`${close}${inventoryPanel.render(hud.inventory_grid)}`;
  if(state==='waypoints')body=`${close}${renderWorldMap(hud,{icon,escape})}`;
  if(state==='skills')body=`${close}${renderSkillTree(hud,{icon,escape})}<div class="tree-guide"><h3>狩場での操作</h3><div class="skill-guide">${hud.skills.map((s,i)=>`<article>${icon(['blade','whirl','fire','frost'][i])}<div><strong><kbd>${i+1}</kbd> ${escape(s.name)}</strong><p>${escape(s.description)}</p></div></article>`).join('')}</div><p class="panel-description"><strong>C · 突進</strong><br>${escape(hud.charge.description)} 全武器で使用可能・再使用まで3秒。</p><div class="arts-guide"><p><strong>F · 盾ガード</strong><br>長押しで盾を構え、正面120度からの攻撃を80%軽減。構え始め8フレームは完全防御。防御力を使い切ると1.5秒間、体勢を立て直します。</p><p><strong>T · 星落とし</strong><br>地面を指定し、表示された円に0.5秒後に落雷。クリック／タップで確定、ESCで取消。再使用まで4秒。</p><p><strong>V · 踏込斬り</strong><br>前方へ踏み込み、敵の手前で停止して斬る。壁で停止し、回避で中断できます。再使用まで2.5秒。</p><p><strong>5 · 連鎖雷撃</strong><br>呪術のスキルツリーで習得。近くの敵へ雷をつなぎます。</p></div></div>`;
  if(state==='levelup')body=`${heading('BLOOD & EXPERIENCE','新たな力を選ぶ')}<p class="panel-description">ひとつ選ぶと狩りを再開します。</p><div class="oath-list">${hud.offers.map((name,i)=>`<button data-key="13" data-selection="${i}" class="${hud.cursor===i?'selected':''}">${icon('book')}<strong>${escape(name)}</strong><span>→</span></button>`).join('')}</div>`;
  el.innerHTML=`<div class="hunter-panel panel-${state}" role="dialog" aria-modal="true" aria-label="${state==='pause'?'一時停止メニュー':state}">${body}</div>`;
  el.querySelector('.hunter-panel').scrollTop=scrollTop;
  if(hud.paused||state==='skills'||state==='inventory'||state==='waypoints'){
    let focus=null;
    if(!changed&&focusedTree)focus=el.querySelector(`[data-tree-node][data-selection="${hud.cursor}"]`);
    else if(!changed&&focusedName)focus=el.querySelector(`[data-focus="${focusedName}"]:not(:disabled)`);
    else if(!changed&&focusedKey)focus=el.querySelector(`[data-key="${focusedKey}"]:not(:disabled)`);
    (focus??el.querySelector('[data-autofocus],button:not(:disabled)'))?.focus({preventScroll:true});
  }
  if(showTreeDetail&&state==='skills'){el.querySelector('.tree-detail')?.scrollIntoView({block:'start'});showTreeDetail=false;}
}

let previousHp=null;
function render(hud){
  current=hud;
  root.dataset.mode=hud.mode;
  const weapons=$('player-weapon');
  if(!weapons.options.length)weapons.replaceChildren(...hud.weapons.map((name,index)=>new Option(name,String(index))));
  if(weapons.value!==String(hud.weapon_index))weapons.value=String(hud.weapon_index);
  weapons.disabled=hud.mode!=='playing'||hud.paused||hud.menu!=='none'||hud.weapon_locked;
  setText('weapon-action',hud.weapon_action);
  if($('weapon-icon').dataset.weapon!==String(hud.weapon_index)){
    $('weapon-icon').innerHTML=icon(['blade','spear','fist','fire','bow'][hud.weapon_index]);
    $('weapon-icon').dataset.weapon=String(hud.weapon_index);
  }
  setText('hunter-level',String(hud.level).padStart(2,'0'));
  setText('health-text',`${Math.max(0,hud.hp)} / ${hud.max_hp}`);
  $('health-fill').style.width=`${Math.max(0,hud.hp/hud.max_hp)*100}%`;
  const health=root.querySelector('.health-track');health.setAttribute('aria-valuenow',hud.hp);health.setAttribute('aria-valuemax',hud.max_hp);
  $('xp-fill').style.width=`${Math.min(1,hud.xp/Math.max(1,hud.next_xp))*100}%`;
  root.querySelector('.xp-track').setAttribute('aria-valuenow',hud.xp);
  root.querySelector('.xp-track').setAttribute('aria-valuemax',hud.next_xp);
  if(hud.atlas){
    $('minimap-waypoint').setAttribute('transform',`translate(${hud.atlas.waypoint_x} ${hud.atlas.waypoint_z})`);
    const exits=$('minimap-exits');
    if(exits.dataset.region!==String(hud.atlas.current)){
      exits.dataset.region=String(hud.atlas.current);
      const active=hud.atlas.regions[hud.atlas.current];
      exits.innerHTML=hud.atlas.regions.filter(r=>Math.abs(r.x-active.x)+Math.abs(r.z-active.z)===1).map(r=>{
        const dx=r.x-active.x,dz=r.z-active.z;
        const x=dx<0?2:dx>0?98:50,z=dz<0?2:dz>0?78:40;
        const startX=dx<0?20:dx>0?80:50,startZ=dz<0?30:dz>0?40:40;
        return `<g><title>${escape(r.name)}への道</title><path d="M${startX} ${startZ}L${x} ${z}"/><circle cx="${x}" cy="${z}" r="1.6"/></g>`;
      }).join('');
    }

    setText('region-name',hud.atlas.name);setText('minimap-region',hud.atlas.name);setText('minimap-subtitle',hud.atlas.subtitle);
    root.querySelector('.map-card').setAttribute('aria-label',`${hud.atlas.name}の地図`);
  }
  $('waypoint-prompt').hidden=hud.arts?.targeting||!hud.atlas?.near_waypoint||hud.mode!=='playing'||hud.paused||hud.menu!=='none';
  setText('night-label',`第 ${hud.floor} 夜 · THE LONG NIGHT`);
  setText('hunt-objective',`灯火をたどり、群れを狩る · 残り ${hud.remaining}`);
  $('map-player').setAttribute('cx',hud.map_x);$('map-player').setAttribute('cy',hud.map_z);
  hud.skills.forEach((skill,i)=>{
    const b=root.querySelector(`[data-skill="${i}"]`),status=skillStatus(skill);
    b.disabled=status.disabled || hud.arts?.targeting || hud.paused || hud.menu!=='none' || hud.weapon_locked;
    b.style.setProperty('--cooldown',`${status.progress}turn`);
    b.querySelector('.skill-status').textContent=hud.weapon_locked && !status.disabled?'動作中':status.label;
    b.querySelector('.skill-tooltip').textContent=skill.description;
    b.setAttribute('aria-label',`${skill.name} · ${status.label}`);
  });
  setText('charge-status',hud.charge.remaining>0?`${(hud.charge.remaining/60).toFixed(1)}s`:'C');
  $('charge-button').disabled=hud.charge.remaining>0||hud.weapon_locked||hud.attack_remaining>0||hud.paused||hud.menu!=='none';
  $('charge-button').title=hud.charge.description;
  setText('dodge-status',hud.dodge>0?`${(hud.dodge/60).toFixed(1)}s`:'SPACE');
  $('dodge-button').disabled=hud.dodge>0;
  if(previousHp!==null && hud.hp<previousHp)$('damage-edge').animate([{opacity:1},{opacity:0}],{duration:450});
  previousHp=hud.hp;
  const arts=$('learned-arts');
  const artsKey=hud.extra_skills.map(s=>s.key).join(',');
  if(arts.dataset.keys!==artsKey){
    arts.dataset.keys=artsKey;
    arts.innerHTML=hud.extra_skills.map(s=>`<button data-key="${s.key}" aria-label="${escape(s.name)}"><span>${icon(s.glyph)}</span><strong>${escape(s.name)}</strong><small></small></button>`).join('');
  }
  arts.hidden=!hud.extra_skills.length;
  hud.extra_skills.forEach((s,i)=>{
    const button=arts.children[i];
    button.disabled=s.remaining>0||hud.paused||hud.menu!=='none'||hud.weapon_locked||hud.attack_remaining>0;
    button.querySelector('small').textContent=s.remaining>0?`${(s.remaining/60).toFixed(1)}s`:String.fromCharCode(s.key);
  });
  $('tree-sp-badge').hidden=hud.skill_points===0;
  setText('tree-sp-badge',`${hud.skill_points} SP`);
  renderArts(hud);
  panel(hud);
}
globalThis.__ashenUI=Object.freeze({version:1,render});

// Keep keyboard navigation inside the stopped menu, including its submenus.
$('hunter-panel').addEventListener('keydown',e=>{
  if((!current?.paused && !['skills','inventory','waypoints'].includes(current?.menu)) || e.code!=='Tab')return;
  const buttons=[...e.currentTarget.querySelectorAll('button:not(:disabled):not([tabindex="-1"]),select:not(:disabled),a[href]')];
  const first=buttons[0],last=buttons.at(-1);
  if(e.shiftKey&&document.activeElement===first){e.preventDefault();last?.focus();}
  else if(!e.shiftKey&&document.activeElement===last){e.preventDefault();first?.focus();}
});
