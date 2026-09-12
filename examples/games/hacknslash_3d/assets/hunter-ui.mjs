import {createControlInput, bindVirtualStick} from '@kagura-web/kagura-controls.js';
import {createHunterInput, skillStatus} from './hunter-input.mjs';

const paths={
  blade:'M6 26 25 5l2 9-15 15M6 22l8 8M5 31l5-5',
  whirl:'M9 8a12 12 0 1 1-4 14M4 8h7V2M11 22 24 9M17 25l-9-9',
  fire:'M18 3c3 9-4 10-1 15 3-1 6-4 6-7 9 10 4 21-6 21C4 32 2 20 10 12c-1 5 1 7 3 8-3-8 6-10 5-17Z',
  frost:'M17 2v30M4 9l26 16M4 25 30 9M12 5l5 5 5-5M12 29l5-5 5 5M4 15l7-1-1-7M24 27l-1-7 7-1',
  dodge:'M5 12h12M3 19h10M7 26h9M20 8l9 10-9 10M16 18h13',
  bag:'M10 10V6h14v4M7 11h20l3 19H4Z M11 20h12',
  book:'M17 8C12 3 5 5 3 6v24c7-3 11-2 14 1 3-3 7-4 14-1V6c-2-1-9-3-14 2Zm0 0v23',
  pause:'M11 6v23M23 6v23',
};
const icon=name=>`<svg viewBox="0 0 34 34" aria-hidden="true"><path d="${paths[name]}"/></svg>`;
const escape=value=>String(value).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('"','&quot;');
const root=document.querySelector('#hunter-hud');
const controls=createControlInput();
const input=createHunterInput(controls);
globalThis.__ashenControls=input;
let current=null;
let panelKey='';
const names=['処刑の一撃','回転斬り','分裂火弾','霜の輪'];
root.innerHTML=`
  <div class="edge-shade" aria-hidden="true"></div>
  <section class="vitals" aria-label="狩人の状態">
    <div class="hunter-seal" aria-hidden="true">${icon('blade')}</div>
    <div class="vital-lines"><div class="vital-caption"><span>HUNTER <b id="hunter-level">01</b></span><span id="health-text">—</span></div>
    <div class="health-track" role="progressbar" aria-label="体力"><i id="health-fill"></i></div>
    <div class="xp-track" role="progressbar" aria-label="経験値"><i id="xp-fill"></i></div></div>
  </section>
  <section class="expedition" aria-label="狩場の目標"><p id="night-label">第一夜</p><h1>灰の森</h1><div><i></i><span id="hunt-objective">灯火をたどり、群れを狩る</span></div></section>
  <aside class="map-card" aria-label="灰の森の地図"><span>ASHWOOD</span><svg viewBox="0 0 100 80" aria-hidden="true"><path class="map-outline" d="M2 2h96v76H2z"/><path class="map-road" d="M2 42Q18 62 35 40T67 33 98 44M43 36v30"/><path class="map-clearing" d="M14 43h12v12H14zM33 30h12v12H33zM53 23h14v14H53zM70 41h14v14H70zM37 56h12v12H37z"/><g class="map-lights"><circle cx="27" cy="46" r="2"/><circle cx="51" cy="28" r="2"/><circle cx="87" cy="48" r="2"/></g><circle id="map-player" r="2.2" cx="20" cy="49"/></svg><small>灯火の旧街道</small></aside>
  <div class="utility" aria-label="メニュー"><button data-key="73" aria-label="装備袋">${icon('bag')}<span>装備 <kbd>I</kbd></span></button><button data-key="75" aria-label="技と成長">${icon('book')}<span>技 <kbd>K</kbd></span></button><button data-key="80" aria-label="一時停止">${icon('pause')}<kbd>P</kbd></button></div>
  <div class="journey-note"><span>ASHEN HUNT</span><p>鐘が消えるまで、夜は明けない。</p></div>
  <div class="combat-controls">
    <div id="move-stick" role="group" aria-label="仮想移動スティック"><div class="stick-ring"><i class="stick-cross"></i><i id="stick-thumb"></i></div><span>移動</span></div>
    <div class="action-dock">
      <div class="skill-buttons">${names.map((name,i)=>`<button class="skill skill-${i}" data-key="${49+i}" data-skill="${i}" aria-label="${name}"><kbd>${i+1}</kbd><span class="skill-glyph">${icon(['blade','whirl','fire','frost'][i])}<i class="cooldown-sweep"></i></span><strong>${name}</strong><small class="skill-status">使用可能</small><span class="skill-tooltip"></span></button>`).join('')}</div>
      <div class="primary-actions"><button id="attack-button" data-hold="attack" aria-label="通常攻撃"><span>${icon('blade')}</span><strong>斬撃</strong><kbd>J / 左クリック</kbd></button><button id="dodge-button" data-key="32" aria-label="回避"><span>${icon('dodge')}</span><strong>回避</strong><small id="dodge-status">SPACE</small></button></div>
    </div>
  </div>
  <section id="hunter-panel" class="modal-wrap" hidden aria-live="polite"></section>
  <div id="damage-edge" aria-hidden="true"></div>
`;
const $=id=>document.getElementById(id);
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
  if(button.dataset.hold){input.hold(e.pointerId,'attack');button.setPointerCapture(e.pointerId);button.dataset.pressed='';}
  else if(button.dataset.key)input.tap(Number(button.dataset.key),selection);
}
root.addEventListener('pointerdown',e=>{
  const b=e.target.closest('button');if(!b)return;
  e.stopPropagation();
  if(b.closest('.combat-controls')){e.preventDefault();activate(b,e);}
});
for(const type of ['pointerup','pointercancel','lostpointercapture'])root.addEventListener(type,e=>{input.release(e.pointerId);e.target.closest('button')?.removeAttribute('data-pressed');});
root.addEventListener('click',e=>{
  const b=e.target.closest('button');if(!b||b.disabled)return;
  if(b.closest('.combat-controls') && e.detail!==0)return;
  e.preventDefault();e.stopPropagation();
  input.tap(b.dataset.hold?74:Number(b.dataset.key),Number(b.dataset.selection??-1));
});
window.addEventListener('blur',clear);
const heldKeyboardCodes=new Set([
  'KeyW','KeyA','KeyS','KeyD','KeyQ','KeyE','KeyR','KeyJ','KeyM',
  'ArrowUp','ArrowDown','ArrowLeft','ArrowRight','ShiftLeft','ShiftRight',
  'Digit5','Digit6','Digit7','Digit8','F2','F3','F4','F5',
]);
// Discrete keys are intents, retained until a simulation tick consumes them.
// A short key tap must survive a busy GPU frame just like a touch button tap.
window.addEventListener('keydown',e=>{
  if(e.ctrlKey || e.metaKey || e.altKey || e.target?.isContentEditable || e.target?.closest?.('input,textarea,select'))return;
  if(e.target instanceof HTMLButtonElement && ['Space','Enter'].includes(e.code))return;
  const keys={Space:32,Enter:13,Escape:27,KeyP:80,KeyI:73,KeyK:75,Digit1:49,Digit2:50,Digit3:51,Digit4:52};
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
window.addEventListener('resize',clear);
document.addEventListener('visibilitychange',()=>{if(document.hidden)clear();});

function panel(hud){
  const state=hud.mode!=='playing'?hud.mode:hud.menu!=='none'?hud.menu:hud.paused?'pause':'';
  const signature=JSON.stringify([state,hud.cursor,hud.inventory,hud.equipment,hud.nodes,hud.offers]);
  if(signature===panelKey)return;panelKey=signature;
  const el=$('hunter-panel');el.hidden=!state;
  root.dataset.blocked=state?'true':'false';
  if(!state)return;
  clear();
  const close='<button class="close-panel" data-key="27" aria-label="閉じる">×</button>';
  const heading=(eyebrow,title)=>`<p class="eyebrow">${eyebrow}</p><h2>${title}</h2>`;
  let body='';
  if(state==='title')body=`${heading('A HUNTER’S NIGHT','ASHEN HUNT')}<p class="title-jp">灰の森に、灯を。</p><p class="panel-description">途切れた旧街道。眠らない群れ。<br>灯火をたどり、夜の狩場へ。</p><button class="begin-button" data-key="32">狩りを始める <span>→</span></button><small>WASDで移動 · 左クリックで斬撃<br>モバイルでは画面のスティックとボタンで操作</small>`;
  if(state==='character_select')body=`${heading('CHOOSE YOUR OATH','狩人の誓い')}<p class="panel-description">4つの技を携え、灰の森へ踏み入る。</p><div class="oath-list">${['刃の狩人','術の狩人','呪弾の狩人'].map((n,i)=>`<button data-key="13" data-selection="${i}" class="${hud.cursor===i?'selected':''}">${icon(['blade','fire','frost'][i])}<strong>${n}</strong><small>${['体力と近接攻撃に優れる','術の威力に優れる','遠距離から群れを狙う'][i]}</small><span>→</span></button>`).join('')}</div>`;
  if(state==='gameover')body=`${heading('THE NIGHT REMAINS','灯は、まだ消えない。')}<p class="panel-description">灰の森で倒れた。もう一度、夜の向こうへ。</p><button class="begin-button" data-key="32">再び立ち上がる →</button>`;
  if(state==='pause')body=`${heading('TAKE A BREATH','一時停止')}<p class="panel-description">狩場はあなたの帰りを待っています。</p><button class="begin-button" data-key="80">狩りに戻る →</button>`;
  if(state==='inventory')body=`${close}${heading('BELONGINGS','装備袋')}<p class="panel-description">所持品をタップして装備。装備中の品と交換します。</p><div class="equipped">${hud.equipment.map((name,i)=>`<span>${['武器','防具','装飾'][i]}<b>${escape(name)}</b></span>`).join('')}</div><div class="inventory-list">${hud.inventory.map((name,i)=>`<button data-key="69" data-selection="${i}" ${name==='空きスロット'?'disabled':''} class="${hud.cursor===i?'selected':''}"><small>${String(i+1).padStart(2,'0')}</small><span>${escape(name)}</span></button>`).join('')}</div>`;
  if(state==='skills')body=`${close}${heading('THE HUNTER’S ARTS','技と成長')}<div class="skill-guide">${hud.skills.map((s,i)=>`<article>${icon(['blade','whirl','fire','frost'][i])}<div><strong><kbd>${i+1}</kbd> ${escape(s.name)}</strong><p>${escape(s.description)}</p></div></article>`).join('')}</div><h3>熟練を高める</h3><p class="panel-description">レベルアップで技を獲得。ポイントがあれば下の技を強化できます。</p><div class="growth-list">${hud.nodes.map((n,i)=>`<button data-key="13" data-selection="${i}" ${n.available?'':'disabled'}><strong>${escape(n.name)}</strong><span>Lv ${n.level} / ${n.max_level}</span><small>${n.available?`${n.cost} ptで強化`:'成長で習得'}</small></button>`).join('')}</div>`;
  if(state==='levelup')body=`${heading('BLOOD & EXPERIENCE','新たな力を選ぶ')}<p class="panel-description">ひとつ選ぶと狩りを再開します。</p><div class="oath-list">${hud.offers.map((name,i)=>`<button data-key="13" data-selection="${i}" class="${hud.cursor===i?'selected':''}">${icon('book')}<strong>${escape(name)}</strong><span>→</span></button>`).join('')}</div>`;
  el.innerHTML=`<div class="hunter-panel panel-${state}" role="dialog" aria-label="${state}">${body}</div>`;
}

let previousHp=null;
function render(hud){
  current=hud;
  root.dataset.mode=hud.mode;
  setText('hunter-level',String(hud.level).padStart(2,'0'));
  setText('health-text',`${Math.max(0,hud.hp)} / ${hud.max_hp}`);
  $('health-fill').style.width=`${Math.max(0,hud.hp/hud.max_hp)*100}%`;
  const health=root.querySelector('.health-track');health.setAttribute('aria-valuenow',hud.hp);health.setAttribute('aria-valuemax',hud.max_hp);
  $('xp-fill').style.width=`${Math.min(1,hud.xp/Math.max(1,hud.next_xp))*100}%`;
  root.querySelector('.xp-track').setAttribute('aria-valuenow',hud.xp);
  root.querySelector('.xp-track').setAttribute('aria-valuemax',hud.next_xp);
  setText('night-label',`第 ${hud.floor} 夜 · THE LONG NIGHT`);
  setText('hunt-objective',`灯火をたどり、群れを狩る · 残り ${hud.remaining}`);
  $('map-player').setAttribute('cx',hud.map_x);$('map-player').setAttribute('cy',hud.map_z);
  hud.skills.forEach((skill,i)=>{
    const b=root.querySelector(`[data-skill="${i}"]`),status=skillStatus(skill);
    b.disabled=status.disabled || hud.paused || hud.menu!=='none';
    b.style.setProperty('--cooldown',`${status.progress}turn`);
    b.querySelector('.skill-status').textContent=status.label;
    b.querySelector('.skill-tooltip').textContent=skill.description;
    b.setAttribute('aria-label',`${skill.name} · ${status.label}`);
  });
  setText('dodge-status',hud.dodge>0?`${(hud.dodge/60).toFixed(1)}s`:'SPACE');
  $('dodge-button').disabled=hud.dodge>0;
  if(previousHp!==null && hud.hp<previousHp)$('damage-edge').animate([{opacity:1},{opacity:0}],{duration:450});
  previousHp=hud.hp;
  panel(hud);
}
globalThis.__ashenUI=Object.freeze({version:1,render});
