// Presentation receipts are independent of the simulation and its save format.
export function planPresentation(before, after, {lastCueId = 0, reducedMotion = false} = {}) {
  const receipts = after.effects ?? [];
  const last = Math.max(lastCueId, ...receipts.map(cue => cue.id));
  if (!before) return {transition: null, cues: [], lastCueId: last, shake: false, duration: 0};
  let kind = null;
  const town = mode => ['town', 'cleared'].includes(mode);
  if (!town(before.mode) && town(after.mode)) kind = after.event === 'defeat' ? 'defeat' : 'return';
  else if (town(before.mode) && !town(after.mode)) kind = 'enter';
  else if (before.floor !== after.floor) kind = 'stairs';
  else if (before.mode !== 'battle' && after.mode === 'battle') kind = 'battle';
  else if (before.battle?.phase !== 'won' && after.battle?.phase === 'won') kind = 'victory';
  else if (before.x !== after.x || before.z !== after.z) kind = 'step';
  else if (before.facing !== after.facing) kind = 'turn';
  const durations = {enter: 280, stairs: 280, battle: 240, return: 320, defeat: 320, victory: 300, step: 140, turn: 140};
  const stacks = new Map(),groupSizes=new Map();
  const fresh=receipts.filter(cue=>cue.id>lastCueId);
  for(const cue of fresh){const key=`${cue.team}:${cue.target}`;groupSizes.set(key,(groupSizes.get(key)??0)+1);}
  const cues = fresh.map((cue, i, array) => { const key=`${cue.team}:${cue.target}`,stack=stacks.get(key)??0;stacks.set(key,stack+1);return ({...cue, stack, groupSize:groupSizes.get(key), delay: reducedMotion ? 0 : i * Math.min(85, 500 / Math.max(1, array.length - 1)), duration: reducedMotion ? 180 : 430});});
  const transition = kind ? {kind, direction: kind==='turn'&&((after.facing-before.facing+4)%4)===3?-1:1, duration: reducedMotion ? 80 : durations[kind]} : null;
  const duration = Math.max(transition?.duration ?? 0, ...cues.map(cue => cue.delay + cue.duration), 0);
  return {transition, cues, lastCueId: last, shake: !reducedMotion && cues.some(cue => cue.team === 'party' && cue.kind !== 'heal'), duration};
}

// Presentation, input and storage adapter. The authoritative rules live in sim/*.mbt.
export async function install({read, command, save, load, paused, pose, readAgent, stepAgent, resetAgent, loadMaster, readMaster, readExperience}) {
  const masterResponse=await fetch('assets/master-data.json');
  if(!masterResponse.ok)throw Error('FATHOM master data could not be loaded');
  const masterError=loadMaster(await masterResponse.text());if(masterError)throw Error(masterError);
  // Fetch goes through the project's resource resolver in Studio as well as HTTP.
  const [artwork,theme]=await Promise.all([fetch('assets/party-atlas.png'),fetch('assets/style.css')]);
  if(!artwork.ok)throw Error(`FATHOM party atlas: ${artwork.status}`);
  if(!theme.ok)throw Error(`FATHOM theme: ${theme.status}`);
  const themeText=await theme.text();
  const partyUrl=URL.createObjectURL(await artwork.blob());
  const partyImage=new Image();partyImage.src=partyUrl;await partyImage.decode();
  window.addEventListener('pagehide',()=>URL.revokeObjectURL(partyUrl),{once:true});
  const canvas=document.querySelector('#app');
  const root=document.createElement('main');
  root.id='fathom'; root.dataset.kaguraGameSurface='true';
  root.style.setProperty('--party-art',`url("${partyUrl}")`);
  root.innerHTML=`<section id="game-screen" data-kagura-surface aria-label="FATHOM ゲーム画面">
    <div class="world" id="world"></div><div class="vignette" aria-hidden="true"></div>
    <header class="masthead"><div class="brand"><span class="sigil" aria-hidden="true">◇</span><div><h1>FATHOM</h1><p>灯の届かぬ迷宮</p></div></div><div class="quest"><small>EXPEDITION 01</small><span id="objective">地下2階の印章を持ち帰る</span></div><nav aria-label="ゲーム設定"><button id="atlas-toggle" aria-expanded="false" aria-controls="atlas" aria-haspopup="dialog">手帳 [M]</button><button id="sound" aria-pressed="false">音 OFF</button></nav></header>
    <div class="resources" id="resources"></div><div id="pause-notice" hidden>STUDIOで解析中 · 再開すると操作できます</div>
    <div class="scene-meta"><span id="scene-caption"></span><span id="location"></span></div>
    <div id="enemy-status"></div><section id="town" aria-label="灯台宿場"></section>
    <div class="dock"><section class="command-panel" aria-label="行動"><div id="command-title"></div><div id="commands"></div><p id="hint"></p><p id="notice" role="status"></p></section>
    <section class="party-section" aria-label="冒険者の隊列"><div class="section-heading"><h2>冒険者たち</h2><span id="party-tip">前衛 01–03 / 後衛 04–06</span></div><div id="party"></div></section></div>
    <dialog id="atlas" aria-labelledby="atlas-title"><header class="atlas-header"><h2 id="atlas-title">探索手帳</h2><button id="atlas-close">画面に戻る ×</button></header><div class="atlas-grid"><section class="map-panel"><div class="section-heading"><h3>踏査図</h3><span id="map-floor">B1</span></div><div id="map" role="img" aria-label="探索した場所の地図"></div><div class="map-key"><span>△ 現在地</span><span>↓ 階段</span><span>◇ 宝箱</span><span>✦ 祈り</span></div><p id="danger"></p></section><section class="journal"><div class="section-heading"><h3>探索記録</h3><span>JOURNAL</span></div><ol id="log" aria-live="polite" aria-relevant="additions text"></ol></section></div><footer><span>時間は、あなたの選択で進む。</span><span id="save-status">拠点で自動保存</span></footer></dialog>
    <div id="effects" aria-hidden="true"></div>
  </section>`;
  const stylesheet=document.createElement('style');stylesheet.textContent=themeText;
  root.querySelector('#world').append(canvas);canvas.tabIndex=-1;canvas.setAttribute('aria-label','一人称の迷宮と画面内のHUD。移動と行動は画面下部で操作できます');
  document.body.replaceChildren(stylesheet,root);document.title='FATHOM — 灯の届かぬ迷宮';
  const $=id=>root.querySelector(`#${id}`);
  const storageKey='kagura.fathom.town.v1';
  let lastCueId=0,menuCursor=0,atlasKeyboard=false;
  const motion=matchMedia('(prefers-reduced-motion: reduce)');
  const animations=new Set();
  let state,lastRevision=-1,lastPaused=null,enemy=0,target=0,pending='',message='',muted=true,audio,lastEvent=0,saveRevision=-1;
  const safe=string=>String(string).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  function button(action,label,arg=-1,{primary=false,disabled=false,key=action+arg}={}) {
    const hotkey=({enter:'1',rest:'2',buy:'3',formation:'4',attack:'1',guard:'2','pick-heal':'3',flame:'4','pick-potion':'5',flee:'6',interact:'Enter','field-heal':'H','field-potion':'I','recall-check':'R',resolve:'Enter',undo:'⌫',continue:'Enter',recall:'Enter','cancel-target':'Esc',challenge:'1',back:'Esc',loot:arg===0?'1':'2'})[action]??'';
    return `<button aria-label="${safe(label)}" data-key="${hotkey}" data-action="${action}" data-arg="${arg}" data-focus="${key}" ${primary?'class="primary"':''} ${disabled||paused()?'disabled':''}>${hotkey?`<kbd>${hotkey}</kbd>`:''}<span>${label}</span></button>`;
  }
  function initAudio(){if(muted)return;try{audio??=new AudioContext();audio.resume().catch(()=>{});}catch{muted=true;$('sound').textContent='音 利用不可';}}
  function tone(event){
    if(muted||!audio)return;
    const notes={step:[100,0.035],bump:[65,.06],door:[145,.1],battle:[130,.18],hurt:[85,.08],heal:[660,.2],spell:[330,.2],loot:[880,.2],victory:[523,.35],return:[440,.3],enter:[220,.2],stairs:[185,.12],defeat:[100,.4]};
    const [hz,duration]=notes[event]??[180,.05],t=audio.currentTime,o=audio.createOscillator(),v=audio.createGain();
    o.type=event==='hurt'?'triangle':'sine';o.frequency.setValueAtTime(hz,t);o.frequency.exponentialRampToValueAtTime(hz*(event==='victory'?1.5:.75),t+duration);
    v.gain.setValueAtTime(.055,t);v.gain.exponentialRampToValueAtTime(.001,t+duration);o.connect(v);v.connect(audio.destination);o.start(t);o.stop(t+duration);o.onended=()=>{o.disconnect();v.disconnect()};
  }
  function act(action,arg=-1){
    if(!Number.isInteger(arg))return '対象が不正です';
    if(paused())return 'Studioで解析中です';
    finishEffects();
    closeAtlas();initAudio();message='';pending='';menuCursor=0;const error=command(action,arg);if(error)message=error.replace(/^Failure: /,'');
    render(true);return error;
  }
  const agent=Object.freeze({version:1,
    observe:()=>JSON.parse(readAgent()),
    step:({revision,choiceId})=>{
      if(!Number.isInteger(revision)||revision<0||revision>2147483647||typeof choiceId!=='string'||!choiceId)throw Error('invalid_input');
      const error=stepAgent(revision,choiceId);if(error)throw Error(error);
      finishEffects();pending='';message='';menuCursor=0;render(true);return JSON.parse(readAgent());
    },
    masterData:()=>JSON.parse(readMaster()),
    reset:(seed,balance={},masterData)=>{
      if(!Number.isInteger(seed)||seed < -2147483648||seed>2147483647)throw Error('invalid_input');
      const result=resetAgent(seed,JSON.stringify(balance),masterData===undefined?'':JSON.stringify(masterData));if(!result)throw Error('paused');if(['invalid_balance','invalid_master_data'].includes(result))throw Error(result);
      finishEffects();closeAtlas();state=undefined;lastCueId=0;lastEvent=0;saveRevision=-1;pending='';message='';menuCursor=0;render(true);return JSON.parse(result);
    },
  });
  const experience=Object.freeze({version:1,read(after=0){if(!Number.isInteger(after)||after<0||after>2147483647)throw Error('invalid_input');return JSON.parse(readExperience(after));}});
  globalThis.fathom=Object.freeze({agent,experience,read:()=>read(),command:(action,arg=-1)=>act(action,arg),presentation:()=>({active:animations.size,reducedMotion:motion.matches,lastCueId})});
  try {const source=localStorage.getItem(storageKey);if(source){const error=load(source);if(error)message='保存記録を読み込めませんでした。新しい隊列で開始します。';}}
  catch {message='保存領域を使えません。この画面を開いている間は遊べます。';}
  $('sound').onclick=()=>{muted=!muted;$('sound').textContent=muted?'音 OFF':'音 ON';$('sound').setAttribute('aria-pressed',String(!muted));initAudio();};
  root.addEventListener('click',event=>{
    const b=event.target.closest('button[data-action]');if(!b||b.disabled)return;
    const action=b.dataset.action,arg=Number(b.dataset.arg);
    if(action==='formation'){beginFormation();return;}
    if(action==='enemy'){enemy=arg;render(true);return;}
    if(action==='target'){
      target=arg;
      if(pending){const next=pending;pending='';act(next,arg);}else render(true);
      return;
    }
    if(action==='pick-heal'||action==='pick-potion'||action==='field-heal'||action==='field-potion'){
      pending=action==='pick-heal'?'heal':action==='pick-potion'?'potion':action;choosePartyTarget();message='';render(true);return;
    }
    if(action==='cancel-target'){if(pending==='formation'&&state.selected>=0)act('swap',state.selected);pending='';message='';render(true);return;}
    if(action==='recall-check'){pending='recall';message='帰還の鐘を使うと戦利金が半分になります。';render(true);return;}
    act(action,arg);
  });
  function closeAtlas(){if($('atlas').open)$('atlas').close();}
  function toggleAtlas(keyboard=false){
    atlasKeyboard=keyboard===true;
    if($('atlas').open){closeAtlas();return;}
    $('atlas-toggle').setAttribute('aria-expanded','true');$('atlas').showModal();
    $('log').scrollTop=$('log').scrollHeight;
  }
  $('atlas-toggle').onclick=()=>toggleAtlas(false);$('atlas-close').onclick=closeAtlas;
  $('atlas').addEventListener('close',()=>{$('atlas-toggle').setAttribute('aria-expanded','false');(atlasKeyboard?canvas:$('atlas-toggle')).focus({preventScroll:true});});
  $('atlas').addEventListener('click',event=>{if(event.target===$('atlas')){const r=event.target.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)closeAtlas();}});
  function finishEffects(){
    for(const animation of animations)animation.cancel();animations.clear();$('effects').replaceChildren();delete root.dataset.transition;
  }
  function animate(element,frames,options,remove=false){
    const animation=element.animate(frames,{easing:'ease-out',...options});animations.add(animation);
    animation.onfinish=()=>{animations.delete(animation);if(remove)element.remove();};
    animation.oncancel=()=>{animations.delete(animation);if(remove)element.remove();};
    if(paused())animation.pause();return animation;
  }
  function playEffects(plan){
    const screen=$('game-screen'),screenRect=screen.getBoundingClientRect();
    const layer=$('effects');
    if(plan.transition){
      const {kind,duration,direction}=plan.transition;
      if(['step','turn'].includes(kind)){
        if(!motion.matches)animate($('world'),kind==='step'?[{transform:'scale(1.035)',opacity:.85},{transform:'scale(1)',opacity:1}]:[{transform:`translateX(${-12*direction}px)`,opacity:.82},{transform:'translateX(0)',opacity:1}],{duration});
      }else{
        root.dataset.transition=kind;
        const veil=document.createElement('div');veil.className=`scene-transition ${kind}`;veil.dataset.effect='transition';
        const title=({enter:'迷宮へ',stairs:`地下${state.floor+1}階`,battle:'遭 遇',return:state.mode==='cleared'?'灯を、持ち帰る。':'宿場へ帰還',defeat:'救護隊が到着した',victory:'勝 利'})[kind];
        veil.textContent=title;layer.append(veil);
        const animation=animate(veil,[{opacity:.96},{opacity:.8,offset:.3},{opacity:0}],{duration},true);
        animation.finished.then(()=>{if(root.dataset.transition===kind)delete root.dataset.transition;}).catch(()=>{});
      }
    }
    let wash=false;
    for(const cue of plan.cues){
      const heal=cue.kind==='heal',guard=cue.kind==='guard';
      let x,y,targetElement;
      if(cue.team==='party'){
        targetElement=root.querySelector(`[data-hero-id="${cue.target}"]`);
        if(!targetElement)continue;
        const r=targetElement.getBoundingClientRect();x=r.x+r.width/2-screenRect.x;y=r.y+r.height/2-screenRect.y;
        animate(targetElement,[{filter:`brightness(${heal?1.6:2.2})`,borderColor:heal?'#a9e8bf':guard?'#abcad8':'#e79b88'},{filter:'brightness(1)',borderColor:'var(--line)'}],{duration:cue.duration,delay:cue.delay});
        if(!heal&&!wash){
          wash=true;const tint=document.createElement('div');tint.className=`damage-wash ${guard?'guarded':''}`;tint.dataset.effect='hurt';layer.append(tint);
          animate(tint,[{opacity:0},{opacity:guard?.22:.55,offset:.2},{opacity:0}],{duration:motion.matches?140:260,delay:cue.delay},true);
          if(plan.shake)animate($('world'),[{transform:'translate(0,0)'},{transform:'translate(-4px,2px)',offset:.2},{transform:'translate(3px,-2px)',offset:.5},{transform:'translate(0,0)'}],{duration:190,delay:cue.delay});
        }
      }else{
        const foes=state.battle?.foes;if(!foes?.[cue.target])continue;
        const location=pose(foes[cue.target].kind,foes.length,cue.target);
        x=location.centerX;y=location.centerY;
      }
      // Keep feedback within the same render surface, even beside the outer heroes.
      x=Math.max(35,Math.min(screenRect.width-35,x));y=Math.max(95,Math.min(screenRect.height-35,y));
      const number=document.createElement('div');number.className=`damage-number ${heal?'healing':guard?'guarding':cue.kind==='fire'?'burning':''}`;
      number.dataset.effect=heal?'heal':'damage';number.dataset.target=`${cue.team}:${cue.target}`;
      const rows=Math.min(3,cue.groupSize??1),columns=Math.ceil((cue.groupSize??1)/3),stack=cue.stack??0;
      const column=Math.floor(stack/3),row=stack%3;
      number.style.left=`${Math.max(35,Math.min(screenRect.width-35,x+(column-(columns-1)/2)*70))}px`;
      number.style.top=`${y+(row-(rows-1)/2)*54}px`;number.innerHTML=`${heal?'+':'−'}${cue.amount}${guard?'<small>GUARD</small>':''}`;layer.append(number);
      animate(number,motion.matches?[{opacity:1},{opacity:0}]:[{opacity:0,transform:'translate(-50%,-30%) scale(.75)'},{opacity:1,transform:'translate(-50%,-70%) scale(1.1)',offset:.2},{opacity:1,transform:'translate(-50%,-100%) scale(1)',offset:.65},{opacity:0,transform:'translate(-50%,-150%) scale(1)'}],{duration:cue.duration,delay:cue.delay,fill:'backwards'},true);
      if(!motion.matches&&cue.team==='enemy'){
        const mark=document.createElement('div');mark.className=`hit-mark ${cue.kind==='fire'?'fire':''}`;mark.style.left=`${x}px`;mark.style.top=`${y}px`;mark.dataset.effect='impact';
        mark.innerHTML='<svg viewBox="0 0 100 100"><path d="M14 80L81 13M28 15L71 78M7 45L31 49M72 50L96 44"/></svg>';layer.append(mark);
        animate(mark,[{opacity:1,transform:'translate(-50%,-50%) scale(.45) rotate(-12deg)'},{opacity:.9,transform:'translate(-50%,-50%) scale(1.15) rotate(6deg)',offset:.3},{opacity:0,transform:'translate(-50%,-50%) scale(1.4) rotate(8deg)'}],{duration:260,delay:cue.delay,fill:'backwards'},true);
      }
    }
  }
  motion.addEventListener('change',finishEffects);
  window.addEventListener('pagehide',finishEffects,{once:true});

  function partyMarkup(s){
    const active=s.battle?.active??-1;
    return s.party.map((h,i)=>{
      const targeted=['heal','potion','field-heal','field-potion','formation'].includes(pending)&&target===i;
      const selectable=['town','cleared'].includes(s.mode)||(['heal','potion','field-heal','field-potion'].includes(pending)&&h.hp>0);
      const order=s.battle?.orders.find(o=>o.actor===i);
      return `<button data-hero-id="${h.id}" class="hero ${i>=3?'back-rank':''} ${h.hp===0?'fallen':''} ${active===i?'active':''} ${targeted?'targeted':''} ${s.selected===i?'selected':''}" data-action="${['town','cleared'].includes(s.mode)?'swap':'target'}" data-arg="${i}" data-focus="hero${i}" ${selectable&&!paused()?'':'disabled'} aria-label="${h.name} ${h.job} HP ${h.hp}/${h.maxHp}${selectable?' 選択':''}"><span class="adventurer-art" style="background-position:${h.id*20}% bottom" aria-hidden="true"></span><span class="hero-info"><span class="hero-name"><strong>${h.name}</strong><small>${i<3?'前':'後'}${i+1} · ${h.job}</small></span><span class="vital">HP <b>${h.hp}</b><small>/${h.maxHp}</small><i class="hp-track"><i style="width:${h.hp/h.maxHp*100}%"></i></i></span><span class="hero-bottom"><span>${h.maxMp?`MP ${h.mp}/${h.maxMp}`:`Lv.${h.level}`}</span><em>${order?safe(order.action):active===i?'行動選択':targeted?'対象':h.hp===0?'戦闘不能':''}</em></span></span></button>`;
    }).join('');
  }
  function render(force=false){
    const previous=state;
    const next=read(),isPaused=paused();if(!force&&next.revision===lastRevision&&isPaused===lastPaused)return;
    state=next;lastRevision=state.revision;lastPaused=isPaused;
    const focus=document.activeElement?.dataset.focus,s=state,b=s.battle,town=['town','cleared'].includes(s.mode);
    root.dataset.mode=s.mode;$('pause-notice').hidden=!isPaused;
    for(const animation of animations){if(isPaused)animation.pause();else if(animation.playState==='paused')animation.play();}
    $('objective').textContent=s.mode==='cleared'?'遠征達成 · 灯火の印章を持ち帰った':s.relic?'灯火の印章を地上へ持ち帰る':'地下2階の印章を持ち帰る';
    $('resources').innerHTML=`<span><small>灯り</small><strong>${s.light}</strong><small>/ 70歩</small></span><span><small>回復薬</small><strong>${s.potions}</strong><small>個</small></span><span><small>所持金</small><strong>${s.gold}</strong><small>G</small></span><span class="carried"><small>戦利金</small><strong>${s.carriedGold}</strong><small>G · 帰還で確保</small></span><span class="bell"><small>帰還の鐘</small><strong>${s.bell}</strong><small>回</small></span>`;
    $('location').textContent=town?'灯台宿場 / THE LAST LIGHT':`地下${s.floor+1}階 · E ${s.x} / N ${s.z} · ${['北','東','南','西'][s.facing]}向き`;
    $('scene-caption').textContent=town?'':b?`ENCOUNTER / ROUND ${String(b.round).padStart(2,'0')}`:s.mode==='warning'?'THE SEALED CHAMBER':`THE FORGOTTEN PASSAGES / B${s.floor+1}`;
    $('town').hidden=!town;
    if(town)$('town').innerHTML=`<small>${s.mode==='cleared'?'EXPEDITION COMPLETE':'THE LAST LIGHT'}</small><h2>${s.mode==='cleared'?'灯を、持ち帰る。':'この先に、<br>灯はあるか。'}</h2><p>${s.mode==='cleared'?'6人は宿場に印章を届けた。<br>迷宮は、再びあなたを待っている。':'六人の冒険者と、忘れられた地下迷宮。<br>方眼を埋め、守護者の印章を探す。<br>そして、全員で帰ってくる。'}</p><span class="town-note">2層の迷宮 / コマンド式の戦闘</span>`;
    $('enemy-status').hidden=!b;
    if(b){
      if(!b.foes[enemy]||b.foes[enemy].hp===0)enemy=Math.max(0,b.foes.findIndex(f=>f.hp>0));
      $('enemy-status').innerHTML=b.foes.map((f,i)=>`<button data-action="enemy" data-arg="${i}" data-focus="enemy${i}" style="left:${pose(f.kind,b.foes.length,i).centerX}px;top:${pose(f.kind,b.foes.length,i).labelY}px" class="enemy ${i===enemy?'chosen':''}" ${f.hp===0||isPaused?'disabled':''} aria-pressed="${i===enemy}"><strong>${safe(f.name)}</strong><span>${f.hp===0?'討伐':`HP ${f.hp} / ${f.maxHp}`}</span><i style="--health:${f.hp/f.maxHp*100}%"></i><small>${f.hp>0?safe(f.intent):'—'}</small></button>`).join('');
    }
    let title='',controls='',hint='';
    if(town){title='出発の支度';controls=button('enter',s.mode==='cleared'?'もう一度、迷宮へ →':'迷宮へ入る →',-1,{primary:true})+button('rest','宿で休む · 最大8G')+button('buy','回復薬を買う · 6G',-1,{disabled:s.gold<6||s.potions>=99})+button('formation','隊列を入れ替える');hint='↑↓ 選ぶ / Enter 決定 / G 隊列 / M 手帳';}
    else if(s.mode==='chest'){title='罠の気配がする。';controls=button('loot','盗賊に罠を外させる',0,{primary:true,disabled:!s.party.some(h=>h.jobCode===2&&h.hp>0)})+button('loot','そのまま開ける · 3ダメージ',1)+button('back','今は立ち去る');hint='宝箱には銀貨・回復薬・灯油。罠を外せば無傷で回収できます。';}
    else if(s.mode==='warning'){title='封印の向こうに、守護者がいる。';controls=button('challenge','守護者に挑む',-1,{primary:true})+button('back','一歩引いて準備する');hint='戦闘からは逃走できません。HP・MPと回復薬を確かめてください。';}
    else if(b){
      if(b.phase==='planning'){
        const actor=s.party[b.active];title=`${actor.name} · ${actor.job}の行動`;
        controls=button('attack','攻撃',enemy,{primary:true})+button('guard','防御')+button('pick-heal','治癒 · MP2',-1,{disabled:actor.jobCode!==3||actor.mp<2})+button('flame','火炎 · MP3',-1,{disabled:actor.jobCode!==4||actor.mp<3})+button('pick-potion','回復薬',-1,{disabled:s.potions<=b.orders.filter(o=>o.action==='回復薬').length})+button('undo','ひとつ戻す',-1,{disabled:b.orders.length===0})+button('flee','逃走 · 失敗すると被弾',-1,{disabled:b.boss});
        hint='↑↓ 選ぶ / Enter 決定 / F 全員攻撃 / Backspace 取消';
      }else if(b.phase==='review'){title='全員の行動が決まりました。';controls=button('resolve','この行動で戦う',-1,{primary:true})+button('undo','ひとつ戻す');hint=b.orders.map(o=>`${s.party[o.actor].name}：${o.action}`).join(' / ');}
      else {title=b.phase==='won'?(s.relic?'印章を手に入れた。地上へ帰ろう。':`勝利 · 戦利金 ${b.reward}G`):`ROUND ${b.round} · 結果を確認`;controls=button('continue',b.phase==='won'?'探索を続ける →':'次のラウンドへ →',-1,{primary:true});hint='探索手帳 [M] で、このラウンドの記録を確認できます。';}
    }else {
      title=({exit:'宿場への出口',down:'下の階へ続く階段',up:'上の階へ続く階段',chest:'古い宝箱',shrine:'祈りの灯',guardian:s.relic?'静まり返った封印の間':'封印の間'})[s.tile]??'迷宮を探索する';
      controls=`<div class="touch-movement">${button('left','↶ 左を向く')}${button('forward','↑ 前へ',-1,{primary:true})}${button('right','右を向く ↷')}${button('strafe-left','← 左へ')}${button('backward','↓ 後ろへ')}${button('strafe-right','右へ →')}</div><div class="field-actions">${button('interact','調べる [Enter]',-1,{primary:true})}${button('field-heal','治癒 · MP2',-1,{disabled:!s.party.some(h=>h.jobCode===3&&h.hp>0&&h.mp>=2)})}${button('field-potion','回復薬',-1,{disabled:s.potions===0})}${button('recall-check','帰還の鐘',-1,{disabled:s.bell===0})}</div>`;
      hint='WASD 移動・旋回 / QE 平行移動 / M 手帳';
    }
    if(pending==='recall'){title='帰還しますか？';controls=button('recall','戦利金を半分にして帰還',-1,{primary:true})+button('cancel-target','探索を続ける');}
    else if(pending){controls=button('cancel-target','対象選択をやめる');title=pending==='formation'?'隊列を入れ替える':pending==='attack'?'攻撃する敵を選ぶ':'回復する仲間を選ぶ';hint='← → 対象 / Enter 決定 / Esc 戻る';}
    $('command-title').textContent=title;$('commands').innerHTML=controls;$('hint').textContent=hint;$('notice').textContent=message;
    const choices=menuButtons();menuCursor=Math.min(menuCursor,Math.max(0,choices.length-1));choices[menuCursor]?.classList.add('cursor');
    $('party-tip').textContent=pending&&pending!=='recall'?'回復する仲間を選んでください':town?'G: 隊列':'前衛 / 後衛';
    $('party').innerHTML=partyMarkup(s);
    const glyph={wall:'',unknown:'',floor:'',exit:'⌂',down:'↓',up:'↑',chest:'◇',shrine:'✦',door:'╫',guardian:'◆'};
    $('map').innerHTML=s.cells.map(c=>`<span class="cell ${c.kind} ${c.visited?'visited':''} ${c.used?'used':''} ${c.open?'open':''} ${s.x===c.x&&s.z===c.z?'here':''}" title="${c.x},${c.z}">${s.x===c.x&&s.z===c.z?['△','▷','▽','◁'][s.facing]:glyph[c.kind]}</span>`).join('');
    $('map-floor').textContent=`B${s.floor+1} / 09 × 09`;
    $('danger').innerHTML=`<span>${s.light===0?'灯りが消えた · 遭遇が早まる':'周囲の気配'}</span><span>${s.danger} / ${s.dangerMax}歩</span><i style="width:${s.danger/s.dangerMax*100}%"></i>`;
    $('log').innerHTML=s.log.slice(-7).map((line,i,a)=>`<li class="${i===a.length-1?'latest':''}">${safe(line)}</li>`).join('');
    $('log').scrollTop=$('log').scrollHeight;
    if(s.eventId!==lastEvent){lastEvent=s.eventId;tone(s.event);}
    if(town&&s.revision!==saveRevision){saveRevision=s.revision;try{const source=save();if(source){localStorage.setItem(storageKey,source);$('save-status').textContent='宿場の記録を保存済み';}}catch{$('save-status').textContent='保存できません · この画面内でプレイ可能';}}
    const plan=planPresentation(previous,s,{lastCueId,reducedMotion:motion.matches});lastCueId=plan.lastCueId;playEffects(plan);
    if(focus)root.querySelector(`[data-focus="${CSS.escape(focus)}"]:not(:disabled)`)?.focus({preventScroll:true});
  }
  function choosePartyTarget(){
    const living=state.party.map((h,i)=>({...h,i})).filter(h=>h.hp>0);
    target=(living.sort((a,b)=>a.hp/a.maxHp-b.hp/b.maxHp)[0]?.i)??0;
  }
  function beginFormation(){pending='formation';target=0;message='';render(true);canvas.focus({preventScroll:true});}
  function menuButtons(){return [...$('commands').querySelectorAll('button[data-action]:not(:disabled)')].filter(b=>b.checkVisibility()&&!b.closest('.touch-movement'));}
  function activateKeyboardButton(button){
    if(!button)return;
    if(button.dataset.action==='attack'){pending='attack';message='';render(true);return;}
    button.click();
  }
  function confirmTarget(){
    if(pending==='attack'){act('attack',enemy);return;}
    if(pending==='formation'){
      const cursor=target;act('swap',cursor);pending='formation';target=cursor;render(true);return;
    }
    const action=pending;act(action,target);
  }
  function moveTarget(delta){
    if(pending==='attack'){
      const alive=state.battle.foes.map((f,i)=>f.hp>0?i:-1).filter(i=>i>=0);
      enemy=alive[(alive.indexOf(enemy)+delta+alive.length)%alive.length];
    }else{
      const alive=state.party.map((h,i)=>(pending==='formation'||h.hp>0)?i:-1).filter(i=>i>=0);
      target=alive[(alive.indexOf(target)+delta+alive.length)%alive.length];
    }
    render(true);canvas.focus({preventScroll:true});
  }
  window.addEventListener('keydown',event=>{
    if(event.repeat||event.ctrlKey||event.metaKey||event.altKey||['INPUT','TEXTAREA','SELECT'].includes(event.target.tagName))return;
    const code=event.code,mode=state?.mode;
    if(code==='KeyM'){event.preventDefault();toggleAtlas(true);return;}
    if($('atlas').open)return;
    if(code==='KeyV'){event.preventDefault();$('sound').click();return;}
    if(paused())return;
    if((code==='Enter'||code==='Space')&&event.target.tagName==='BUTTON')return;
    const arrows={ArrowLeft:-1,ArrowUp:-1,ArrowRight:1,ArrowDown:1};
    if(code==='Escape'){
      event.preventDefault();
      if(pending){if(pending==='formation'&&state.selected>=0)act('swap',state.selected);pending='';message='';render(true);}
      else if(['warning','chest'].includes(mode))act('back');
      else if(['town','cleared'].includes(mode)&&state.selected>=0)act('swap',state.selected);
      return;
    }
    if(['attack','heal','potion','field-heal','field-potion','formation'].includes(pending)){
      if(code in arrows){event.preventDefault();moveTarget(arrows[code]);return;}
      if(code==='Enter'||code==='Space'){event.preventDefault();confirmTarget();return;}
    }
    if(mode==='explore'&&!pending){
      const action=({KeyW:'forward',ArrowUp:'forward',KeyS:'backward',ArrowDown:'backward',KeyA:'left',ArrowLeft:'left',KeyD:'right',ArrowRight:'right',KeyQ:'strafe-left',KeyE:'strafe-right',Enter:'interact'})[code];
      if(action){event.preventDefault();act(action);return;}
      const actionButton=({KeyH:'field-heal',KeyI:'field-potion',KeyR:'recall-check'})[code];
      if(actionButton){event.preventDefault();$('commands').querySelector(`[data-action="${actionButton}"]:not(:disabled)`)?.click();return;}
    }
    if(mode==='battle'&&code==='KeyF'&&['planning','review'].includes(state.battle.phase)){event.preventDefault();act('all-attack');return;}
    if(mode==='battle'&&code==='Backspace'){event.preventDefault();act('undo');return;}
    if(['town','cleared'].includes(mode)&&code==='KeyG'){event.preventDefault();beginFormation();return;}
    if(code==='ArrowUp'||code==='ArrowDown'){
      const buttons=menuButtons();event.preventDefault();menuCursor=(menuCursor+(code==='ArrowDown'?1:-1)+buttons.length)%Math.max(1,buttons.length);render(true);canvas.focus({preventScroll:true});return;
    }
    const number=Number(code.replace('Digit',''));
    if(Number.isInteger(number)&&number>=1&&number<=6){
      const button=$('commands').querySelector(`[data-key="${number}"]:not(:disabled)`);
      if(button){event.preventDefault();activateKeyboardButton(button);}return;
    }
    if(code==='Enter'||code==='Space'){
      if(['atlas-toggle','sound','atlas-close'].includes(event.target.id))return;
      event.preventDefault();activateKeyboardButton(menuButtons()[menuCursor]??menuButtons()[0]);
    }
  });
  window.addEventListener('resize',()=>render(true));
  render(true);const timer=setInterval(()=>render(),100);window.addEventListener('pagehide',()=>clearInterval(timer),{once:true});
}
