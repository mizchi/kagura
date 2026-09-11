/** DOM adapter only. Game state remains in MoonBit; UI derives a fresh view of it. */
export function createGameUI({game, controls, reset}) {
  const $ = id => document.getElementById(id);
  const menu = $('menu');
  const setText = (id, value) => { if ($(id).textContent !== value) $(id).textContent = value; };
  let ready = false, lastPhase = '', lastUpdate = -Infinity, starting = false;
  const targets = new Map();
  menu.showModal();
  menu.addEventListener('cancel', event => event.preventDefault());
  if (document.documentElement.dataset.editor === 'true') {
    const exit = document.createElement('button'); exit.type = 'button'; exit.textContent = '編集に戻る';
    exit.onclick = () => { controls.pause(); parent.postMessage({type:'kagura:game-exit',version:1},location.origin); };
    menu.querySelector('.menu-footer').append(exit);
  }
  $('deploy').onclick = async () => {
    if (!ready) return;
    starting = true;
    if (['won', 'lost'].includes(JSON.parse(game.snapshot()).phase)) reset();
    menu.close();
    $('app').focus({preventScroll: true});
    try { await controls.start(); } finally { starting = false; }
  };
  $('reset').onclick = () => reset();
  $('mode').onchange = () => reset($('mode').value);
  $('pause').onclick = () => controls.pause();
  let muted = false;
  $('mute').onclick = () => {
    muted = !muted;
    game.set_muted(muted);
    $('mute').setAttribute('aria-pressed', String(muted));
    setText('mute', muted ? '音声を有効にする' : '音声をミュート');
  };
  for (const id of ['music-volume', 'effects-volume']) $(id).oninput = () => {
    game.set_volumes(Number($('music-volume').value), Number($('effects-volume').value));
  };

  function render(state, projection) {
    const active = state.phase === 'playing';
    const phaseChanged = state.phase !== lastPhase;
    const won = state.phase === 'won', lost = state.phase === 'lost';
    if ((won || lost) && phaseChanged) controls.pause();
    if (active && menu.open) menu.close();
    if (!active && !menu.open && !starting) {
      menu.showModal();
      $('deploy').focus({preventScroll: true});
    }
    $('pause').hidden = !active;
    $('fallback-note').hidden = !active || controls.locked;
    $('damage').hidden = !active || state.damageFlash <= 0;
    $('damage').style.opacity = String(Math.min(1, state.damageFlash * 3));
    const time = performance.now();
    if (!phaseChanged && time - lastUpdate < 100) return;
    lastPhase = state.phase;
    lastUpdate = time;
    const total = state.mission?.total ?? (state.ai ? 9 : 3);
    const waveCount = state.mission?.waves ?? 3, timeLimit = state.mission?.timeLimit ?? 180;
    const p = state.pilot, speed = Math.hypot(p.velocity[0], p.velocity[2]);
    const action = won ? 'もう一度出撃する' : lost ? '再出撃する' : state.phase === 'paused' ? '操作を再開' : '出撃する';
    setText('deploy-label', ready ? action : '機体を読み込み中…');
    $('deploy').setAttribute('aria-label', action);
    $('deploy').disabled = !ready;
    menu.classList.toggle('resuming', state.phase === 'paused');
    $('reset').hidden = state.phase === 'ready';
    setText('menu-title', won ? 'MISSION COMPLETE' : lost ? 'UNIT LOST' : state.phase === 'paused' ? 'SYSTEM PAUSED' : 'IRON YARD');
    if (ready) setText('message', won ? `${state.kills}機撃破 · ${state.elapsed.toFixed(1)}秒で防衛成功` : lost ? state.hp <= 0 ? '機体が撃破されました。再出撃で全機をリセット' : '制限時間を超過しました' : state.phase === 'paused' ? '操作を再開してください' : '工業区画・境界線防衛');
    setText('brief-title', state.ai ? 'DEFENSE MISSION' : 'TARGET PRACTICE');
    setText('brief-mission', state.ai ? `${timeLimit}秒以内に${waveCount}波・${total}機を撃破。波の突破でAPを200回復。` : '最初の波の静止標的で練習。');
    setText('uplink', active ? 'UPLINK ACTIVE' : 'STANDBY');
    const heading = ((p.yaw * 180 / Math.PI) % 360 + 360) % 360;
    setText('heading', `${Math.round(heading).toString().padStart(3, '0')}°`);
    setText('speed', (speed * 3.6).toFixed(1));
    $('speed-bar').style.width = `${Math.min(100, speed / 14.4 * 100)}%`;
    setText('motion', !p.grounded ? p.boost > .25 ? 'BOOST / ASCEND' : 'AIRBORNE' : p.boost > .25 ? 'BOOST / GLIDE' : speed > .1 ? 'LOCOMOTION / WALK' : 'LOCOMOTION / IDLE');
    setText('position', `ALT ${p.position[1].toFixed(1)}m　X ${p.position[0].toFixed(1)}　Z ${p.position[2].toFixed(1)}`);
    setText('ap', Math.ceil(state.hp).toString().padStart(4, '0'));
    $('armor-bar').style.width = `${Math.max(0, state.hp) / 10}%`;
    setText('mission', state.ai ? `WAVE ${state.wave} / ${waveCount}` : 'TRAINING');
    setText('objective', won ? 'MISSION COMPLETE' : lost ? 'UNIT LOST' : state.ai ? '敵機を撃破せよ' : '射撃演習');
    setText('remaining', state.ai ? `残り ${Math.max(0, Math.ceil(timeLimit - state.elapsed))} 秒 · 遮蔽物を使って回避` : '射撃とマルチロックを確認');
    setText('kills', `撃破 ${state.kills} / ${total}`);
    setText('weapons', state.missileCooldown > .01 ? `MISSILE RELOAD ${state.missileCooldown.toFixed(1)}s` : `MULTI LOCK ${state.units.filter(e => e.lock >= 1).length} / 3`);
    setText('weapon-hint', controls.weapons().lock ? 'Eを離して斉射' : '左クリック：射撃　E長押し→離す：ミサイル');
    setText('scores', `HIT ${state.hits}　DESTROYED ${state.kills} / ${total}`);
    $('telemetry').value = `${active ? '操作中' : '一時停止'} / 速度 ${(speed * 3.6).toFixed(1)} km/h / AP ${Math.ceil(state.hp)} / 撃破 ${state.kills}機`;
    const live = new Set();
    for (const projected of projection.targets) {
      const unit = state.units.find(e => e.id === projected.id);
      if (!unit || !projected.visible || unit.hp <= 0 || Math.abs(projected.x) > 1 || Math.abs(projected.y) > 1) continue;
      live.add(unit.id);
      if (!targets.has(unit.id)) {
        const node = document.createElement('div');
        const label = document.createElement('span'), brackets = document.createElement('div');
        const health = document.createElement('div'), bar = document.createElement('i'), detail = document.createElement('small');
        health.className = 'target-health'; health.append(bar); node.append(label, brackets, health, detail);
        node.dataset.target = unit.name ?? `B-${String(unit.id + 1).padStart(2, '0')}`;
        $('targets').append(node); targets.set(unit.id, {node, label, brackets, bar, detail});
      }
      const t = targets.get(unit.id);
      t.node.className = `target-marker${unit.lock >= 1 ? ' locked' : ''}`;
      t.node.style.left = `${(projected.x + 1) * 50}%`; t.node.style.top = `${(1 - projected.y) * 50}%`;
      t.label.textContent = `${t.node.dataset.target} · ${Math.round(projected.distance)}m`;
      t.brackets.className = `target-brackets${unit.warning > 0 ? ' hostile-warning' : ''}`;
      t.bar.style.width = `${Math.max(0, unit.hp) / 180 * 100}%`;
      t.detail.textContent = unit.warning > 0 ? '⚠ INCOMING' : unit.lock >= 1 ? 'LOCKED' : unit.lock > 0 ? `ACQUIRING ${Math.floor(unit.lock * 100)}%` : `AP ${Math.ceil(unit.hp)}`;
    }
    for (const [id, target] of targets) if (!live.has(id)) { target.node.remove(); targets.delete(id); }
  }
  return {
    render,
    play() {
      if (!ready) return;
      if (['won', 'lost'].includes(JSON.parse(game.snapshot()).phase)) reset();
      // Close the modal before focusing: a canvas outside an open dialog is inert.
      menu.close();
      controls.play();
      $('app').focus({preventScroll: true});
    },
    setReady() { ready = true; lastPhase = ''; $('deploy').disabled = false; $('deploy').focus({preventScroll: true}); },
    showError(error) { ready = false; $('deploy').disabled = true; setText('message', error.message); $('message').setAttribute('role', 'alert'); if (!menu.open) menu.showModal(); },
  };
}
