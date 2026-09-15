// Browser adapter only: all combat, formations, aiming and progression live in sim/*.mbt.
export function install({ input, command }) {
  const canvas = document.querySelector("#app");
  const surface = document.createElement("main");
  surface.id = "game-surface";
  surface.dataset.kaguraGameSurface = "true";
  surface.innerHTML = `
    <canvas id="flight-hud" aria-hidden="true"></canvas>
    <header><div class="brand"><span class="crest">✦</span> EMBERWING <small>空の厨房</small></div>
      <nav><button id="sound" aria-label="音を切り替える" title="音を切り替える (M)">音 ON</button><button id="pause" aria-label="一時停止">Ⅱ <span>ESC</span></button></nav>
    </header>
    <div id="telemetry"><div class="vital"><small>DRAGON</small><div id="health"></div></div>
      <div class="score"><small>ごちそう SCORE</small><strong id="score">000000</strong><span id="dishes">0 杯</span></div>
      <div class="route"><small>01 / THE SUNKEN ARCHIPELAGO</small><div><i id="progress"></i></div><span id="time">84s → BOSS</span></div>
    </div>
    <section id="boss-status" hidden><div><span>大群主 KAWAIKO</span><small id="boss-phase">PHASE 01</small></div><div class="boss-track"><i id="boss-health"></i></div><p>6か所をロック / ビームの予告線から離れろ</p></section>
    <div id="announcement" aria-live="polite"></div>
    <section id="menu"><div class="eyebrow">KAGURA FLIGHT ARCADE · 01</div><h1>EMBER<br><em>WING</em></h1>
      <p class="tagline">空の群れを、召し上がれ。</p><p class="description">翼を広げ、海上遺跡の向こうへ。<br>増え続ける群れ、弾幕、飛来する岩。<br>巨大 kawaiko を倒して、空を切り開け。</p>
      <div class="instructions"><div><b>L</b><span>長押しでマルチロック<br><strong>離して、追尾火球</strong></span></div><div><b>R</b><span>狙いを定めて長押し<br><strong>火線を吐く</strong></span></div></div>
      <button class="primary" id="start">飛び立つ <span>↗</span></button><button class="practice" id="practice">巨大 kawaiko 戦を練習 →</button><small class="hint">マウスで照準・移動 / WASD・矢印で回避 / ESC で一時停止</small>
    </section>
    <section id="dialog" hidden><small id="dialog-label">FLIGHT PAUSED</small><h2 id="dialog-title">ひと休み。</h2><p id="result"></p><button class="primary" id="continue">飛行を続ける ↗</button><button class="secondary" id="return">タイトルへ</button></section>
    <footer id="weapons"><div class="weapon lock"><b>L</b><div><small>HOMING FIREBALL</small><strong id="locks">MULTI LOCK <em>00 / 12</em></strong><span>長押しで捕捉 → 離して一斉射撃</span></div><div id="lock-pips"></div></div>
      <div class="weapon breath"><b>R</b><div><small>DRAGON BREATH</small><strong id="flame-label">火線 <em>READY</em></strong><span>長押しで照射 / 熱が冷めるまで休息</span><div class="heat"><i id="heat"></i></div></div></div></footer>
    <div id="touch"><button id="touch-lock">ロック<br>離して発射</button><button id="touch-fire">火線</button></div>
    <div id="credit">KAGURA ENGINE <span>◆</span> KAWAIKO / CHIBIVUE</div>`;
  const style = document.createElement("style");
  style.textContent = `
    *{box-sizing:border-box}html,body{width:100%;height:100%;margin:0;overflow:hidden;background:#345e67;color:#fff4da;font-family:Inter,"Helvetica Neue","Noto Sans JP",sans-serif}
    #game-surface{position:fixed;inset:0;overflow:hidden;isolation:isolate;touch-action:none}#app,#flight-hud{position:absolute!important;inset:0;width:100%!important;height:100%!important;display:block;border:0!important;border-radius:0!important;max-width:none!important;max-height:none!important}#app{z-index:-2}#flight-hud{z-index:1;pointer-events:none}
    #game-surface:after{content:"";position:absolute;inset:0;z-index:-1;pointer-events:none;background:linear-gradient(90deg,#0c323ce8 0%,#113a4850 40%,transparent 70%),linear-gradient(0deg,#173f4560,transparent 24%)}
    #game-surface.playing:after,#game-surface.paused:after,#game-surface.won:after,#game-surface.lost:after{background:linear-gradient(0deg,#1131399c,transparent 25%,transparent 78%,#24424c75)}
    button{font:inherit;cursor:pointer;color:inherit;border:1px solid #f4e5bd45;background:#173e4759;border-radius:4px;touch-action:none}button:hover{background:#fff0cc25;border-color:#ffe0a9}button:focus-visible{outline:3px solid #ffe4a2;outline-offset:4px}
    header{position:absolute;inset:24px 32px auto;display:flex;align-items:center;justify-content:space-between;z-index:3}.brand{font-weight:800;font-size:17px;letter-spacing:3px}.brand small{font-size:10px;letter-spacing:2px;font-weight:400;margin-left:14px;opacity:.65}.crest{color:#ffbf75;font-size:25px;vertical-align:middle;margin-right:10px}nav{display:flex;gap:8px}nav button{height:34px;min-width:46px;font-size:11px;padding:0 12px}nav span{font-size:9px;opacity:.6;margin-left:7px}
    #menu{position:absolute;left:7%;top:18%;z-index:3}.eyebrow{font-size:10px;letter-spacing:3.5px;color:#e6cc95}h1{font-family:Georgia,"Times New Roman",serif;letter-spacing:-5px;line-height:.8;font-size:clamp(66px,8.5vw,122px);font-weight:400;margin:28px 0 25px}h1 em{font-style:normal;color:#ffc987;margin-left:49px}.tagline{font-size:19px;letter-spacing:3px;margin-bottom:15px}.description{font-size:12px;line-height:1.95;color:#d4e0d6}.instructions{display:flex;gap:25px;margin:26px 0}.instructions>div{display:flex;align-items:center;gap:10px}.instructions b,.weapon>b{display:grid;place-items:center;font:12px Georgia;border:1px solid #eadcb978;border-radius:10px 10px 5px 5px;width:26px;height:34px}.instructions span{font-size:10px;color:#c5d4cd;line-height:1.75}.instructions strong{color:#fff2d7;font-size:12px;font-weight:500}.primary{display:block;background:#f4cb89;color:#263e40;font-weight:700;border:0;padding:16px 22px;min-width:240px;letter-spacing:2px;font-size:14px}.primary:hover{background:#ffe5af}.primary span{float:right;font-size:22px;line-height:17px}.hint{display:block;font-size:9px;letter-spacing:.6px;color:#c0d1c9;margin-top:15px}
    #credit{position:absolute;bottom:24px;left:32px;font-size:8px;letter-spacing:2px;color:#e4e5cb90;pointer-events:none}#credit span{margin:0 12px;color:#e8c48c}
    #telemetry{position:absolute;top:94px;left:34px;right:34px;display:none;pointer-events:none;z-index:2}#telemetry small,.weapon small{font-size:9px;letter-spacing:2px;color:#dce8d2b8}.vital{float:left}#health{display:flex;gap:5px;margin-top:9px}#health i{height:7px;width:27px;background:#ffdda0;transform:skew(-22deg)}#health i.empty{background:#183c4d70;border:1px solid #fbe4aa44}.score{float:right;text-align:right;display:flex;flex-direction:column;gap:3px}.score strong{font-size:32px;letter-spacing:2px;font-weight:500;font-variant-numeric:tabular-nums}.score span{font-size:11px;color:#ffdc9f}.route{position:absolute;top:0;left:50%;transform:translateX(-50%);text-align:center;min-width:250px}.route>div{height:2px;background:#ecedcb33;margin-top:12px}.route i{display:block;background:#f5cc86;height:2px;width:0}.route span{font-size:9px;display:block;margin:8px;letter-spacing:2px}
    #weapons{position:absolute;bottom:32px;left:34px;right:34px;display:none;justify-content:space-between;pointer-events:none;z-index:2}.weapon{display:flex;gap:13px;align-items:center}.weapon>b{width:30px;height:40px;border-color:#e9d4ae78}.weapon strong{display:block;font-weight:500;font-size:16px;letter-spacing:1px;margin:5px 0}.weapon em{font-size:11px;font-style:normal;color:#ffd18a;margin-left:14px}.weapon span{font-size:9px;color:#c6d6cc}.heat{height:3px;width:210px;background:#ffffee24;margin-top:10px}.heat i{display:block;height:100%;background:#ffbe76;width:0;transition:width .06s linear}#lock-pips{display:flex;gap:3px;align-self:flex-start;margin-top:23px}#lock-pips i{width:4px;height:13px;background:#e0e7c72b;transform:skew(-15deg)}#lock-pips i.on{background:#ffe3a0;box-shadow:0 0 8px #ffbe5f78}
    #announcement{position:absolute;left:50%;top:26%;transform:translateX(-50%);font-size:12px;letter-spacing:4px;z-index:2;pointer-events:none;color:#fff2d2;text-shadow:0 2px 8px #224453}
    #dialog{position:absolute;z-index:5;left:50%;top:50%;transform:translate(-50%,-50%);background:#163a44ed;border:1px solid #d6c99a5c;padding:38px 45px;min-width:360px;box-shadow:0 20px 80px #183c4a55;text-align:center}#dialog small{letter-spacing:3px;font-size:10px;color:#e9c891}h2{font-size:30px;font-weight:400;letter-spacing:3px;margin:24px 0}#result{font-size:13px;line-height:2;color:#e7dcc1}#dialog button{margin:13px auto 0;width:100%}.secondary{padding:12px;border:0;background:transparent;font-size:12px;color:#d6d6bf}
    #touch{display:none}.playing #telemetry,.paused #telemetry,.won #telemetry,.lost #telemetry{display:block}.playing #weapons,.paused #weapons{display:flex}.playing #credit,.paused #credit,.won #credit,.lost #credit{display:none}#pause:disabled{opacity:.35;cursor:default}
    @media(max-height:700px) and (min-width:700px){#menu{top:15%}h1{font-size:80px;margin:20px 0}.description{font-size:11px}.instructions{margin:17px 0}.tagline{margin-bottom:10px}}
    @media(max-width:700px){header{inset:18px 18px auto}.brand{font-size:13px;letter-spacing:2px}.brand small{display:none}nav button{padding:0 8px}#menu{left:8%;top:15%;right:8%}h1{font-size:85px}.tagline{font-size:16px}.description{font-size:11px}.instructions{gap:18px;margin:22px 0}.hint{font-size:8px;max-width:275px;line-height:1.8}#credit{left:8%;bottom:18px;font-size:7px;letter-spacing:1px}#telemetry{top:80px;left:20px;right:20px}.route{top:90px;min-width:200px}.route small{font-size:7px}.score strong{font-size:24px}#health i{width:18px}#weapons{left:20px;right:20px;bottom:22px}.weapon>b,.weapon span,#lock-pips{display:none}.weapon strong{font-size:11px}.weapon small{font-size:7px;letter-spacing:1px}.weapon em{font-size:9px;margin-left:4px}.heat{width:125px}#dialog{min-width:300px;padding:30px}#announcement{top:30%;white-space:nowrap;font-size:9px}}
    @media(pointer:coarse){.playing #touch{display:flex;position:absolute;bottom:100px;right:20px;left:20px;justify-content:space-between;z-index:4}#touch button{width:76px;height:76px;border-radius:50%;background:#183d4670;border:1px solid #ffe2aa8c;font-size:11px}.hint{font-size:0}.hint:after{content:"画面をなぞって照準 / 左ボタンでロック / 右ボタンで火線";font-size:9px}}
    #boss-status{position:absolute;top:153px;left:50%;transform:translateX(-50%);width:min(440px,80%);padding:9px 12px;background:#24414a9c;border-radius:4px;z-index:2;pointer-events:none}#boss-status>div:first-child{display:flex;justify-content:space-between;font-size:11px;letter-spacing:2px;color:#fff1da;text-shadow:0 1px 4px #263c48}#boss-phase{color:#ffacce;font-size:9px}.boss-track{height:7px;background:#3d204c8c;border:1px solid #fba4cf70;margin-top:9px}.boss-track i{display:block;height:100%;background:linear-gradient(90deg,#d862a7,#ffc7d2);width:100%;transition:width .12s linear}#boss-status p{font-size:9px;text-align:center;letter-spacing:1px;color:#eecbd1;margin:7px 0}.practice{display:block;font-size:11px;border:0;border-bottom:1px solid #eed7aa50;border-radius:0;background:transparent;padding:10px 0;margin-top:10px;color:#efdfbc}.practice:hover{background:transparent;color:#fff1d0}
    @media(max-width:700px){.boss-battle .route{display:none}#boss-status{top:158px;width:calc(100% - 48px)}#boss-status>div:first-child{font-size:10px}.boss-track{height:6px}#boss-status p{font-size:8px}.boss-battle #announcement{top:246px}}
    @media(max-height:680px) and (max-width:700px){#menu{top:12%}h1{font-size:60px;margin:18px 0}.tagline{font-size:14px;margin:10px 0}.description{font-size:10px;line-height:1.7}.instructions{margin:14px 0}.primary{padding:13px 18px}.practice{margin-top:4px}.hint{margin-top:8px}}
    @media(prefers-reduced-motion:reduce){*{transition:none!important}}
  `;
  surface.prepend(canvas);
  document.body.replaceChildren(style, surface);
  document.title = "EMBERWING — 空の厨房";
  const $ = (id) => surface.querySelector(`#${id}`);
  const hud = $("flight-hud"), context = hud.getContext("2d");
  let width = 0, height = 0, state, mode = "title", x = 0, y = 0, lock = false, flame = false;
  let muted = false, audio, master, breath, lastWave = 0, announceUntil = 0;
  let lastEvents = { volley_event: 0, hit_event: 0, lock_event: 0, kills: 0, beam_event: 0 }, lastScore = -1, lastHealth = -1, lastLocks = -1;
  let lastFlame = "", lastTime = "", lastBossPhase = 0;
  const encounter = new URLSearchParams(location.search).get("encounter");
  const initialAction = encounter === "boss" ? "practice-boss" : encounter === "swarm" ? "practice-swarm" : "start";
  let flightAction = initialAction;
  const keys = new Set();
  const send = () => input(x, y, Number(keys.has("KeyD") || keys.has("ArrowRight")) - Number(keys.has("KeyA") || keys.has("ArrowLeft")), Number(keys.has("KeyW") || keys.has("ArrowUp")) - Number(keys.has("KeyS") || keys.has("ArrowDown")), lock, flame);
  const reset = () => { keys.clear(); lock = false; flame = false; send(); };
  const act = (action) => { reset(); command(action); };
  const pause = () => { if (mode === "playing") act("pause"); else if (mode === "paused") act("resume"); };
  function soundReady() {
    if (!audio) {
      audio = new AudioContext(); master = audio.createGain(); master.gain.value = muted ? 0 : 0.24; master.connect(audio.destination);
      const buffer = audio.createBuffer(1, audio.sampleRate * 2, audio.sampleRate);
      const samples = buffer.getChannelData(0);
      for (let i = 0; i < samples.length; i++) samples[i] = Math.random() * 2 - 1;
      const source = audio.createBufferSource(), filter = audio.createBiquadFilter();
      source.buffer = buffer; source.loop = true; filter.type = "lowpass"; filter.frequency.value = 750;
      breath = audio.createGain(); breath.gain.value = 0; source.connect(filter); filter.connect(breath); breath.connect(master); source.start();
    }
    audio.resume().catch(() => {});
  }
  function tone(frequency, end, duration, gain, type = "sine") {
    if (!audio || muted) return;
    const oscillator = audio.createOscillator(), envelope = audio.createGain(), t = audio.currentTime;
    oscillator.type = type; oscillator.frequency.setValueAtTime(frequency, t); oscillator.frequency.exponentialRampToValueAtTime(end, t + duration);
    envelope.gain.setValueAtTime(0, t); envelope.gain.linearRampToValueAtTime(gain, t + 0.008); envelope.gain.exponentialRampToValueAtTime(0.001, t + duration);
    oscillator.connect(envelope); envelope.connect(master); oscillator.start(t); oscillator.stop(t + duration + 0.03);
    oscillator.onended = () => { oscillator.disconnect(); envelope.disconnect(); };
  }
  $("start").onclick = () => { soundReady(); lastWave = 0; lastBossPhase=0; flightAction=initialAction; act(flightAction); };
  $("practice").onclick = () => { soundReady(); lastBossPhase=0; flightAction="practice-boss"; act(flightAction); };
  $("continue").onclick = () => { soundReady(); act(mode === "paused" ? "resume" : flightAction); };
  $("return").onclick = () => act("title");
  $("pause").onclick = pause;
  $("sound").onclick = () => { muted = !muted; soundReady(); master.gain.setTargetAtTime(muted ? 0 : 0.24, audio.currentTime, 0.04); $("sound").textContent = muted ? "音 OFF" : "音 ON"; };
  const syncMouseButtons = (event) => {
    // A chord changes via pointermove; pointerup arrives only after the last button is released.
    // Touch aim must preserve the independent on-screen weapon buttons.
    if (event.pointerType === "touch") return;
    lock = mode === "playing" && (event.buttons & 1) !== 0;
    flame = mode === "playing" && (event.buttons & 2) !== 0;
  };
  const move = (event) => { const r = surface.getBoundingClientRect(); x = Math.max(-1, Math.min(1, (event.clientX-r.left)/r.width*2-1)); y = Math.max(-1, Math.min(1, 1-(event.clientY-r.top)/r.height*2)); syncMouseButtons(event); send(); };
  canvas.addEventListener("pointermove", move);
  canvas.addEventListener("pointerdown", (event) => { if (mode !== "playing") return; event.preventDefault(); soundReady(); canvas.setPointerCapture(event.pointerId); move(event); });
  window.addEventListener("pointerup", (event) => { if (event.pointerType === "touch") return; syncMouseButtons(event); send(); });
  window.addEventListener("pointercancel", reset);
  canvas.addEventListener("contextmenu", (event) => event.preventDefault());
  for (const [id, weapon] of [["touch-lock", "lock"], ["touch-fire", "flame"]]) {
    const button = $(id);
    button.onpointerdown = (event) => { event.preventDefault(); event.stopPropagation(); soundReady(); button.setPointerCapture(event.pointerId); if (weapon === "lock") lock = true; else flame = true; send(); };
    button.onpointerup = (event) => { event.stopPropagation(); if (weapon === "lock") lock = false; else flame = false; send(); };
    button.onpointercancel = reset;
  }
  window.addEventListener("keydown", (event) => {
    if (["Space","Escape","KeyW","KeyA","KeyS","KeyD","ArrowUp","ArrowDown","ArrowLeft","ArrowRight","KeyM"].includes(event.code)) event.preventDefault(); else return;
    if (!event.repeat && event.code === "Escape") pause();
    if (!event.repeat && event.code === "Space" && mode !== "playing") { soundReady(); act(mode === "paused" ? "resume" : mode === "title" ? initialAction : flightAction); }
    if (!event.repeat && event.code === "KeyM") $("sound").click();
    keys.add(event.code); send();
  });
  window.addEventListener("keyup", (event) => { keys.delete(event.code); send(); });
  window.addEventListener("blur", () => { reset(); if (mode === "playing") act("pause"); });
  document.addEventListener("visibilitychange", () => { if (document.hidden && mode === "playing") act("pause"); });
  function drawHud(s) {
    const w = surface.clientWidth, h = surface.clientHeight, ratio = Math.min(devicePixelRatio, 1.5);
    if (width !== w || height !== h || hud.width !== Math.round(w*ratio)) { width = w; height = h; hud.width = Math.round(w*ratio); hud.height = Math.round(h*ratio); }
    const c = context; c.setTransform(ratio,0,0,ratio,0,0); c.clearRect(0,0,w,h);
    if (s.mode !== "playing") return;
    if (s.hit_timer > 1) { c.fillStyle = `rgba(222,74,62,${(s.hit_timer-1)*0.5})`; c.fillRect(0,0,w,h); }
    const playerX=(s.player_screen_x+1)*w/2, playerY=(1-s.player_screen_y)*h/2;
    c.strokeStyle="#bff7e5"; c.lineWidth=1.3; c.beginPath();c.arc(playerX,playerY,Math.max(6,s.player_radius*h/2),0,Math.PI*2);c.stroke();
    c.fillStyle="#e4fff4";c.fillRect(playerX-1.5,playerY-1.5,3,3);
    for (const danger of s.dangers) {
      const dx=(danger.x+1)*w/2, dy=(1-danger.y)*h/2, fx=(danger.from_x+1)*w/2, fy=(1-danger.from_y)*h/2;
      const radius=Math.max(15,Math.min(150,danger.radius*h/2));
      const beam=danger.kind==="beam";
      c.strokeStyle=beam?"#fa99e4":"#ffd495";c.fillStyle=beam?"#ed64c016":"#ffc28412";c.lineWidth=1.5;
      c.setLineDash(beam?[6,6]:[3,7]);c.beginPath();c.moveTo(fx,fy);c.lineTo(dx,dy);c.stroke();
      c.beginPath();c.arc(dx,dy,radius,0,Math.PI*2);c.fill();c.stroke();c.setLineDash([]);
      c.lineWidth=3;c.beginPath();c.arc(dx,dy,radius+4,-Math.PI/2,-Math.PI/2+Math.PI*2*danger.progress);c.stroke();
      c.font="600 10px sans-serif";c.textAlign="center";
      const label=`${beam?"ビーム":"岩"} ${Math.max(0,danger.remaining).toFixed(1)}s`, labelWidth=c.measureText(label).width;
      c.fillStyle="#293747de";c.fillRect(dx-labelWidth/2-5,dy-radius-22,labelWidth+10,17);
      c.fillStyle=beam?"#ffe0fa":"#ffe1b6";c.fillText(label,dx,dy-radius-10);
    }
    const px = (s.aim_x+1)*w/2, py = (1-s.aim_y)*h/2;
    c.strokeStyle = s.overheated ? "#ff805e" : "#ffe8ae"; c.lineWidth = 1.5;
    c.beginPath(); c.arc(px,py,s.breathing ? 8 : 13,0,Math.PI*2); c.stroke();
    for (let k=0;k<4;k++) { const a=k*Math.PI/2; c.beginPath(); c.moveTo(px+Math.cos(a)*18,py+Math.sin(a)*18); c.lineTo(px+Math.cos(a)*25,py+Math.sin(a)*25); c.stroke(); }
    if (s.aiming) { c.strokeStyle="#ffe6a366"; c.setLineDash([5,7]); c.beginPath(); c.arc(px,py,h*0.11,0,Math.PI*2); c.stroke(); c.setLineDash([]); }
    for (const target of s.targets) {
      if (target.depth < 4 || Math.abs(target.x)>1.15 || Math.abs(target.y)>1.15) continue;
      const tx = (target.x+1)*w/2, ty=(1-target.y)*h/2, radius=Math.max(12,Math.min(38,h/target.depth*0.75));
      if (target.locked) {
        c.strokeStyle="#ffdf85"; c.fillStyle="#ffdf85"; c.lineWidth=1.6;
        c.beginPath(); c.arc(tx,ty,radius,0,Math.PI*2); c.stroke();
        for (let k=0;k<4;k++) {const a=Math.PI/4+k*Math.PI/2; c.beginPath(); c.moveTo(tx+Math.cos(a)*(radius+3),ty+Math.sin(a)*(radius+3)); c.lineTo(tx+Math.cos(a)*(radius+9),ty+Math.sin(a)*(radius+9)); c.stroke();}
        c.font="8px monospace";c.textAlign="center";c.fillText("LOCK",tx,ty-radius-8);
      } else if (target.elite || target.boss) { c.fillStyle="#ffb182";c.font="10px sans-serif";c.textAlign="center";c.fillText("◆",tx,ty-radius-4); }
    }
    for (const dish of s.dishes) {
      if (dish.age>1.4) continue;
      c.globalAlpha=Math.min(1,(1.4-dish.age)*2);c.fillStyle="#fff3c1";c.font="600 11px sans-serif";c.textAlign="center";
      c.fillText(`鴨南蛮 +${dish.points}`,(dish.x+1)*w/2,(1-dish.y)*h/2-dish.age*20);c.globalAlpha=1;
    }
  }
  globalThis.__emberwingFrame = (s) => {
    state = s;
    if (mode !== s.mode || !surface.className) {
      mode = s.mode; surface.className = mode;
      $("menu").hidden = mode !== "title";
      $("dialog").hidden = !["paused","won","lost"].includes(mode);
      $("pause").disabled = !["playing","paused"].includes(mode);
      $("dialog-label").textContent = mode === "won" ? "FLIGHT COMPLETE" : mode === "lost" ? "FLIGHT ENDED" : "FLIGHT PAUSED";
      $("dialog-title").textContent = mode === "won" ? "ごちそうさまでした。" : mode === "lost" ? "翼を休めて、もう一度。" : "ひと休み。";
      $("continue").textContent = mode === "paused" ? "飛行を続ける ↗" : "もう一度飛ぶ ↗";
      $("result").textContent = mode === "paused" ? "海風と、あたたかい一杯。" : `${s.kills} 杯の鴨南蛮 / ${s.score.toLocaleString()} 点 / 最大 ${s.best_chain} ロック`;
      if (mode === "title") lastWave = 0;
    }
    if (lastScore !== s.score) { lastScore=s.score; $("score").textContent=String(s.score).padStart(6,"0"); $("dishes").textContent=`鴨南蛮 ${s.kills} 杯`; }
    if (lastHealth !== s.hp) { lastHealth=s.hp; $("health").innerHTML=Array.from({length:6},(_,i)=>`<i class="${i<s.hp?"":"empty"}"></i>`).join(""); $("health").ariaLabel=`体力 ${s.hp} / 6`; }
    if (lastLocks !== s.locks) { lastLocks=s.locks; $("locks").innerHTML=`MULTI LOCK <em>${String(s.locks).padStart(2,"0")} / 12</em>`; $("lock-pips").innerHTML=Array.from({length:12},(_,i)=>`<i class="${i<s.locks?"on":""}"></i>`).join(""); }
    $("heat").style.width=`${s.heat*100}%`;
    const flameLabel=s.overheated?"COOLING":s.breathing?"FIRING":"READY";
    if (lastFlame !== flameLabel) { lastFlame=flameLabel; $("flame-label").innerHTML=`火線 <em>${flameLabel}</em>`; }
    $("progress").style.width=`${Math.min(100,s.time/84*100)}%`;
    $("boss-status").hidden=!s.boss_active;
    surface.classList.toggle("boss-battle",s.boss_active);
    if(s.boss_active){$("boss-health").style.width=`${Math.max(0,s.boss_hp/s.boss_max_hp*100)}%`;$("boss-phase").textContent=`PHASE 0${s.boss_phase}`;}
    const timeLabel=s.boss_defeated?"大群主 撃破":s.boss_active?"FINAL ENCOUNTER · 大群主":`WAVE ${String(s.wave).padStart(2,"0")} / 09 · ${Math.ceil(Math.max(0,84-s.time))}s → BOSS`;
    if (lastTime !== timeLabel) {lastTime=timeLabel;$("time").textContent=timeLabel;}
    if (s.mode === "playing" && !s.boss_active && !s.boss_defeated && s.wave !== lastWave) { lastWave=s.wave; announceUntil=s.time+2.5; $("announcement").textContent=s.wave===1?"群れを捕捉せよ · HOLD & RELEASE":`WAVE ${String(s.wave).padStart(2,"0")} / 群れが接近`; }
    if (s.mode === "playing" && s.boss_active && s.boss_phase !== lastBossPhase) {
      lastBossPhase=s.boss_phase;announceUntil=s.time+2.8;
      $("announcement").textContent=s.boss_phase===1?"大群主、飛来 / BEAM WARNING":"PHASE 02 / 三連ビームは上下へ回避";
      tone(390,180,0.5,0.22,"triangle");
    }
    if (s.mode === "title") lastBossPhase=0;
    if (s.time > announceUntil || s.mode !== "playing") $("announcement").textContent="";
    if (audio) {
      breath.gain.setTargetAtTime(s.breathing && s.mode === "playing" ? 0.3 : 0, audio.currentTime, 0.06);
      if (s.lock_event>lastEvents.lock_event) tone(650+s.locks*45,950+s.locks*35,0.09,0.15);
      if (s.volley_event>lastEvents.volley_event) tone(230,65,0.3,0.4,"triangle");
      if (s.kills>lastEvents.kills) tone(460,850,0.16,0.24,"sine");
      if (s.beam_event>lastEvents.beam_event) tone(1200,85,0.3,0.3,"sawtooth");
      if (s.hit_event>lastEvents.hit_event) tone(150,55,0.28,0.4,"triangle");
    }
    lastEvents=s;
    drawHud(s);
  };
  globalThis.emberwing = Object.freeze({ snapshot: () => state && structuredClone(state), command: act });
  send();
}
