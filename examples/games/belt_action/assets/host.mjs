/** Browser presentation only. Combat, input interpretation and progression live in MoonBit. */
export function install({snapshot, input, command}) {
  const canvas = document.querySelector('#app');
  canvas.setAttribute('role','application');
  const root = document.createElement('aside');
  root.id = 'aftershift-controls';
  root.dataset.kaguraOverlay = '';
  root.setAttribute('aria-label', 'ゲーム操作');
  root.innerHTML = `
    <style>
      #aftershift-controls {color:#f8e8c3;font:600 13px/1.2 system-ui,sans-serif}
      #aftershift-controls button {font:inherit;min-width:44px;min-height:44px;border:1px solid #637e80;
        color:#f8e8c3;background:#162b34;border-radius:6px;padding:10px 13px;cursor:pointer;touch-action:none}
      #aftershift-controls button:focus-visible {outline:3px solid #ffc568;outline-offset:3px}
      #aftershift-controls button:active,#aftershift-controls button[data-held=true] {background:#ffc568;color:#101b25}
      #aftershift-controls [hidden] {display:none!important}
      #aftershift-controls .tools {position:fixed;z-index:11;top:2px;right:240px;display:flex;gap:6px}
      #aftershift-controls .tools button {min-height:44px;padding:6px 12px}
      #aftershift-controls .touch {display:none;position:fixed;z-index:9;inset:auto 16px max(16px,env(safe-area-inset-bottom));
        align-items:end;justify-content:space-between;pointer-events:none;gap:16px}
      #aftershift-controls .touch button {pointer-events:auto;user-select:none;-webkit-user-select:none;box-shadow:0 3px 0 #08151d}
      #aftershift-controls .pad {display:grid;grid-template:repeat(3,46px)/repeat(3,46px);gap:3px}
      #aftershift-controls [data-action=up] {grid-area:1/2}
      #aftershift-controls [data-action=left] {grid-area:2/1}
      #aftershift-controls [data-action=right] {grid-area:2/3}
      #aftershift-controls [data-action=down] {grid-area:3/2}
      #aftershift-controls .actions {display:flex;gap:8px;align-items:end}
      #aftershift-controls .actions button {width:64px;height:64px;border-radius:50%;font-size:12px}
      #aftershift-controls [data-action=strike] {width:76px;height:76px;border-color:#ffc568;color:#ffc568}
      #aftershift-controls [data-action=breaker] {border-color:#83d9ce;color:#83d9ce}
      @media (pointer:coarse),(max-width:720px) {
        #aftershift-controls .touch {display:flex}
        #aftershift-controls .tools {top:54px;right:12px}
      }
      @media (max-width:380px) {
        #aftershift-controls .touch {left:8px;right:8px;gap:8px}
        #aftershift-controls .pad {grid-template:repeat(3,44px)/repeat(3,44px)}
        #aftershift-controls .actions {gap:5px}
        #aftershift-controls .actions button {width:52px;height:52px;padding:4px}
        #aftershift-controls [data-action=strike] {width:60px;height:60px}
      }
    </style>
    <div class="tools">
      <button type="button" id="shift-start">プレイ</button>
      <button type="button" id="shift-pause" hidden>一時停止</button>
      <button type="button" id="shift-sound" aria-pressed="false" aria-label="効果音をミュート">音あり</button>
    </div>
    <div class="touch" aria-label="タッチ操作">
      <div class="pad" role="group" aria-label="移動">
        <button type="button" data-action="up" aria-label="奥へ移動">↑</button>
        <button type="button" data-action="left" aria-label="左へ移動">←</button>
        <button type="button" data-action="right" aria-label="右へ移動">→</button>
        <button type="button" data-action="down" aria-label="手前へ移動">↓</button>
      </div>
      <div class="actions" role="group" aria-label="アクション">
        <button type="button" data-action="evade" aria-label="回避">回避</button>
        <button type="button" data-action="breaker" aria-label="ガード崩し">崩し</button>
        <button type="button" data-action="strike" aria-label="連撃">連撃</button>
      </div>
    </div>`;
  document.body.append(root);
  const held = new Map();
  let audio, muted = false, seenSound = -1, lastMode = '', lastLabel = '';
  const push = () => {
    const has = name => [...held.values()].includes(name);
    input(Number(has('right')) - Number(has('left')), Number(has('down')) - Number(has('up')),
      has('strike'), has('breaker'), has('evade'));
  };
  const clear = () => {
    held.clear(); push();
    root.querySelectorAll('[data-held]').forEach(b => delete b.dataset.held);
  };
  const unlock = () => {
    audio ??= new (window.AudioContext || window.webkitAudioContext)();
    if (audio.state === 'suspended') void audio.resume();
  };
  const sound = kind => {
    if (!audio || muted || audio.state !== 'running') return;
    const presets = {hit:[220,75,.10], heavy:[130,35,.18], break:[440,85,.18],
      block:[720,260,.07], hurt:[90,32,.16], evade:[420,180,.06], gate:[440,660,.14], clear:[520,1040,.35]};
    const [from,to,length] = presets[kind] || presets.hit;
    const oscillator = audio.createOscillator(), gain = audio.createGain(), t = audio.currentTime;
    oscillator.type = kind === 'block' ? 'triangle' : 'square';
    oscillator.frequency.setValueAtTime(from,t);
    oscillator.frequency.exponentialRampToValueAtTime(to,t+length);
    gain.gain.setValueAtTime(.0001,t);
    gain.gain.exponentialRampToValueAtTime(.045,t+.005);
    gain.gain.exponentialRampToValueAtTime(.0001,t+length);
    oscillator.connect(gain);gain.connect(audio.destination);
    oscillator.start(t);oscillator.stop(t+length+.01);
    oscillator.onended = () => {oscillator.disconnect();gain.disconnect();};
  };
  for (const button of root.querySelectorAll('[data-action]')) {
    const action = button.dataset.action;
    const set = (id, active) => {
      if (active) held.set(id, action); else held.delete(id);
      button.dataset.held = String([...held.values()].includes(action)); push();
    };
    button.addEventListener('pointerdown', e => {
      if (e.button !== 0) return;
      e.preventDefault(); unlock(); button.setPointerCapture(e.pointerId); set(e.pointerId,true);
    });
    for (const name of ['pointerup','pointercancel','lostpointercapture']) {
      button.addEventListener(name, e => set(e.pointerId,false));
    }
    button.addEventListener('keydown', e => {
      if (e.code === 'Space' || e.code === 'Enter') {e.preventDefault();e.stopPropagation();unlock();set(`key:${action}`,true);}
    });
    button.addEventListener('keyup', e => {
      if (e.code === 'Space' || e.code === 'Enter') {e.preventDefault();e.stopPropagation();set(`key:${action}`,false);}
    });
    button.addEventListener('blur', () => set(`key:${action}`,false));
    button.addEventListener('click', e => {
      if (e.detail !== 0) return;
      unlock();set(`click:${action}`,true);setTimeout(() => set(`click:${action}`,false),140);
    });
  }
  const start = root.querySelector('#shift-start'), pause = root.querySelector('#shift-pause');
  start.addEventListener('click', () => {unlock();clear();command('start');canvas.focus();});
  pause.addEventListener('click', () => {clear();command('toggle-pause');canvas.focus();});
  const soundButton = root.querySelector('#shift-sound');
  soundButton.addEventListener('click', () => {
    unlock();muted = !muted;
    soundButton.textContent = muted ? '音なし' : '音あり';
    soundButton.setAttribute('aria-pressed',String(muted));
    soundButton.setAttribute('aria-label',muted ? '効果音を有効にする' : '効果音をミュート');
  });
  canvas.addEventListener('pointerdown', e => {
    if (e.button !== 0) return;
    unlock();canvas.focus();
    if (snapshot().mode !== 'playing') command('start');
  });
  const actionKeys = {KeyJ:'strike',KeyK:'breaker',Space:'evade'};
  const keydown = e => {
    if(e.ctrlKey||e.metaKey||e.altKey||e.target?.closest?.('button,input,textarea,select,[contenteditable=true]'))return;
    const action=actionKeys[e.code];
    if(!action&&!['Enter','Escape','KeyR'].includes(e.code))return;
    e.preventDefault();e.stopImmediatePropagation();
    if(e.repeat)return;
    unlock();
    if(action){held.set(`keyboard:${e.code}`,action);push();}
    else {clear();command(e.code==='Enter'?'start':e.code==='Escape'?'toggle-pause':'retry');}
  };
  canvas.addEventListener('keydown',keydown);
  window.addEventListener('keydown',e=>{if(e.target!==canvas)keydown(e);},true);
  window.addEventListener('keyup', e => {
    if(!held.has(`keyboard:${e.code}`))return;
    held.delete(`keyboard:${e.code}`);push();
    e.preventDefault();e.stopImmediatePropagation();
  },true);
  window.addEventListener('blur', () => {clear();if (window.parent === window) command('pause');});
  document.addEventListener('visibilitychange', () => {if (document.hidden) {clear();if(window.parent===window)command('pause');}});
  window.addEventListener('pagehide', () => {clear();void audio?.close();});
  globalThis.aftershift = Object.freeze({snapshot,command});
  function frame() {
    if (!root.isConnected) return;
    const s = snapshot();
    if (s.mode !== lastMode) {
      lastMode = s.mode;
      start.hidden = s.mode === 'playing';
      start.textContent = s.mode === 'paused' ? '再開' : s.mode === 'title' ? 'プレイ' : 'もう一度';
      pause.hidden = s.mode !== 'playing';
    }
    const label=`AFTERSHIFT: ${s.mode}, sector ${s.stage+1}, health ${s.hp}/6`;
    if(label!==lastLabel){canvas.setAttribute('aria-label',label);lastLabel=label;}
    if (s.soundId !== seenSound) {if (seenSound >= 0) sound(s.sound);seenSound = s.soundId;}
    requestAnimationFrame(frame);
  }
  frame();
}
