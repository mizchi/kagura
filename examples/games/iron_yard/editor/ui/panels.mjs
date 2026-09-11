import { createIronYardSceneView } from './scene-view.mjs';
import { soundFiles } from '../scene/runtime.mjs';
import { downloadBlob } from '../../../../../editor/studio/web/storage.mjs';

/** Editor panels project one canonical scene resource; trial runs receive a detached copy. */
export function createIronYardAuthoring({ container, invoke, onStatus, play, resourceAssets, projectSettings, runtimeURL }) {
  const lifetime = new AbortController(),
    signal = lifetime.signal;
  let doc,
    selected = 'spawn',
    wave = 0,
    mode = 'scene',
    view,
    running = false,
    tick,
    time = 0,
    replay,
    previousHits = 0,
    playVersion = 0;
  const occupied = [];
  function occupy(selector) {
    const host = globalThis.document.querySelector(selector),
      original = globalThis.document.createElement('div'),
      panel = globalThis.document.createElement('div');
    original.hidden = true;
    original.append(...host.childNodes);
    panel.className = 'iron-editor-panel';
    host.append(original, panel);
    occupied.push({ host, original, panel });
    return panel;
  }
  const tree = occupy('.hierarchy'),
    inspector = occupy('.inspector'),
    timeline = occupy('.timeline'),
    assetsPanel = occupy('.assets');
  container.classList.add('iron-authoring');
  const make = (tag, text) => {
    const node = document.createElement(tag);
    if (text !== undefined) node.textContent = text;
    return node;
  };
  const studio = document.querySelector('.studio');
  studio.classList.add('editing-iron-yard');
  const glbButton = [...document.querySelectorAll('.toolbar button')].find(
    (node) => node.textContent === 'Export GLB',
  );
  const glbDisplay = glbButton?.style.display;
  if (glbButton) glbButton.style.display = 'none';
  const title = make('div');
  title.className = 'project-title iron-project-title';
  document.querySelector('.toolbar .project-title').after(title);
  const info = make('span');
  info.className = 'workspace-info iron-workspace-info';
  document.querySelector('.workspace-info').after(info);
  function button(label, fn) {
    const node = make('button', label);
    node.type = 'button';
    node.addEventListener('click', fn);
    return node;
  }
  const error = make('p');
  error.setAttribute('role', 'alert');
  error.className = 'iron-editor-error';
  function fail(cause) {
    error.textContent = cause.message;
    onStatus('IRON YARD · ' + cause.message);
  }
  async function edit(id, changes) {
    try {
      await invoke('scene_edit', { id, changes });
      error.textContent = '';
    } catch (cause) {
      fail(cause);
      renderInspector();
    }
  }
  function select(id) {
    selected = id;
    const index = doc.mission.waves.findIndex((w) => w.targets.includes(id));
    if (index >= 0) wave = index;
    wavePicker.value = String(wave);
    renderTree();
    renderInspector();
    view.update(doc, selected, wave);
  }
  view = createIronYardSceneView(container, { onSelect: select, onError: fail, resourceAssets, projectSettings, runtimeURL });
  function field(parent, label, value, type, commit, options = {}) {
    const row = make('label'),
      caption = make('span', label),
      input = make(options.options ? 'select' : 'input');
    row.className = 'custom-field';
    input.setAttribute('aria-label', label);
    if (options.options)
      for (const [value, text] of options.options) {
        const option = make('option', text);
        option.value = String(value);
        input.append(option);
      }
    else {
      input.type = type;
      for (const key of ['min', 'max', 'step'])
        if (options[key] !== undefined) input[key] = String(options[key]);
      if (type === 'number') input.step = String(options.step ?? 0.5);
    }
    input.value = String(value);
    input.addEventListener('change', () => {
      const next = type === 'number' && !options.options ? input.valueAsNumber : input.value;
      if (type === 'number' && !Number.isFinite(Number(next))) {
        fail(Error('有限の数値を入力してください'));
        input.value = String(value);
        return;
      }
      commit(next);
    });
    row.append(caption, input);
    parent.append(row);
    return input;
  }
  function renderTree() {
    tree.replaceChildren(make('h2', 'IRON YARD / Hierarchy'));
    const entry = (id, label) => {
      const node = button(label, () => select(id));
      node.dataset.entity = id;
      node.className = 'iron-tree-entry';
      node.setAttribute('aria-pressed', String(id === selected));
      tree.append(node);
    };
    entry('spawn', '出撃地点 / STRIX');
    tree.append(make('h3', `環境 · ${doc.stage.solids.length}`));
    for (const s of doc.stage.solids) entry(s.id, s.id);
    for (const [index, w] of doc.mission.waves.entries()) {
      tree.append(make('h3', `WAVE ${index + 1}`));
      for (const id of w.targets) entry(id, id);
    }
  }
  async function add(kind) {
    try {
      const reply = await invoke('scene_add', { kind, wave });
      select(reply.result.id);
    } catch (cause) {
      fail(cause);
    }
  }
  assetsPanel.append(
    make('h2', 'Resources / IRON YARD'),
    make('p', 'STRIX · 出撃機'),
    make('p', 'BASTION · 敵機'),
    button('＋ コンテナ', () => add('container')),
    button('＋ 敵機', () => add('enemy')),
    button('Browse storage', () => globalThis.kaguraHost('storage', '')),
  );
  function renderInspector() {
    inspector.replaceChildren(
      make('h2', mode === 'action' ? 'ACTION / RIFLE' : 'IRON YARD / Inspector'),
      error,
    );
    if (mode === 'action') {
      for (const [key, label, min, max, step] of [
        ['cooldown', '連射間隔（秒）', 0.06, 1, 0.01],
        ['damage', 'ダメージ', 1, 180, 1],
        ['flashDuration', '閃光の長さ（秒）', 0.005, 0.15, 0.005],
        ['recoilDuration', '反動の長さ（秒）', 0.03, 0.5, 0.01],
        ['recoilStrength', '反動の強さ', 0, 0.3, 0.005],
      ])
        field(inspector, label, doc.action[key], 'number', (value) => edit('action', { [key]: value }), {
          min,
          max,
          step,
        });
      field(inspector, '閃光の色', doc.action.flashColor, 'color', (value) =>
        edit('action', { flashColor: value }),
      );
      for (const [key, label] of [
        ['shotSound', '発射音'],
        ['hitSound', '命中音'],
      ])
        field(inspector, label, doc.action[key], 'text', (value) => edit('action', { [key]: value }), {
          options: [
            ['sfx.blunt', '打撲'],
            ['sfx.sword', '剣ヒット'],
            ['sfx.explosion', '爆発'],
            ['sfx.confirm', '決定'],
            ['sfx.cancel', 'キャンセル'],
          ],
        });
      return;
    }
    const solid = doc.stage.solids.find((s) => s.id === selected),
      target = doc.stage.targets.find((t) => t.id === selected),
      position = solid?.center ?? target?.position ?? doc.stage.spawn;
    inspector.append(make('h3', selected === 'spawn' ? '出撃地点 / STRIX' : selected));
    for (const [i, axis] of ['X', 'Y', 'Z'].entries())
      field(
        inspector,
        `位置 ${axis}`,
        position[i],
        'number',
        (value) => {
          const next = [...position];
          next[i] = value;
          edit(selected, { [solid ? 'center' : 'position']: next });
        },
        { min: i === 1 && !solid ? 0 : undefined, max: i === 1 && !solid ? 0 : undefined },
      );
    if (solid) {
      for (const [i, axis] of ['X', 'Y', 'Z'].entries())
        field(
          inspector,
          `サイズ ${axis}`,
          solid.size[i],
          'number',
          (value) => {
            const size = [...solid.size];
            size[i] = value;
            edit(selected, { size });
          },
          { min: 0.2, max: 220 },
        );
      field(inspector, 'オブジェクトの色', solid.color, 'color', (color) => edit(selected, { color }));
      field(inspector, '構造物の種類', solid.kind, 'text', (kind) => edit(selected, { kind }), {
        options: [
          ['warehouse', '倉庫'],
          ['container', 'コンテナ'],
          ['barrier', '遮蔽物'],
          ['tower', 'タワー'],
          ['wall', '外壁'],
        ],
      });
    }
    if (target)
      field(
        inspector,
        '向き（度）',
        (target.yaw * 180) / Math.PI,
        'number',
        (value) => edit(selected, { yaw: (value * Math.PI) / 180 }),
        { min: -360, max: 360, step: 5 },
      );
    if (selected !== 'spawn')
      inspector.append(
        button('選択を削除', async () => {
          try {
            await invoke('scene_remove', { id: selected });
            select('spawn');
          } catch (cause) {
            fail(cause);
          }
        }),
      );
    inspector.append(make('hr'), make('h3', 'シーン・ミッション'));
    field(inspector, 'シーン名', doc.name, 'text', (name) => edit('scene', { name }));
    field(
      inspector,
      '制限時間（秒）',
      doc.mission.timeLimit,
      'number',
      (timeLimit) => edit('scene', { mission: { ...doc.mission, timeLimit } }),
      { min: 10, max: 600, step: 10 },
    );
    field(inspector, 'カメラ FOV', doc.camera.fov, 'number', (fov) => edit('scene', { camera: { fov } }), {
      min: 40,
      max: 85,
      step: 1,
    });
    field(inspector, '空の色', doc.lighting.skyColor, 'color', (skyColor) =>
      edit('scene', { lighting: { ...doc.lighting, skyColor } }),
    );
    field(
      inspector,
      '太陽光の強さ',
      doc.lighting.sunIntensity,
      'number',
      (sunIntensity) => edit('scene', { lighting: { ...doc.lighting, sunIntensity } }),
      { min: 0.1, max: 6, step: 0.1 },
    );
  }
  const bar = make('div');
  bar.className = 'game-transport';
  const sceneTab = button('シーン', () => setMode('scene')),
    actionTab = button('攻撃・エフェクト', () => setMode('action'));
  sceneTab.setAttribute('aria-pressed', 'true');
  actionTab.setAttribute('aria-pressed', 'false');
  const waveLabel = make('label', '表示する波'),
    wavePicker = make('select');
  wavePicker.setAttribute('aria-label', '表示する波');
  waveLabel.append(wavePicker);
  wavePicker.addEventListener(
    'change',
    () => {
      wave = Number(wavePicker.value);
      view.update(doc, selected, wave);
    },
    { signal },
  );
  bar.append(sceneTab, actionTab, waveLabel, button('試遊', play));
  const files = make('div');
  files.className = 'game-transport';
  const input = make('input');
  input.type = 'file';
  input.accept = '.json,application/json';
  input.setAttribute('aria-label', 'シーンJSONを読み込む');
  input.addEventListener(
    'change',
    async () => {
      const file = input.files[0];
      input.value = '';
      if (!file) return;
      const revisionGuard = invoke.capture();
      try {
        if (file.size > 1000000) throw Error('シーンJSONは1MB以下にしてください');
        await invoke('scene_load', { document: JSON.parse(await file.text()) }, revisionGuard);
        selected = 'spawn';
        wave = 0;
        onStatus('IRON YARD · シーンを読み込みました');
      } catch (cause) {
        fail(cause);
      }
    },
    { signal },
  );
  files.append(
    button('シーンJSON書出', () =>
      downloadBlob(
        new Blob([JSON.stringify(doc, null, 2)], { type: 'application/json' }),
        'iron-yard.scene.json',
      ),
    ),
    input,
  );
  const attack = make('div'),
    range = make('input'),
    result = make('output'),
    clock = make('output');
  range.type = 'range';
  range.min = 0;
  range.max = 1.5;
  range.step = 0.005;
  range.value = 0;
  range.disabled = true;
  range.setAttribute('aria-label', '攻撃の時間');
  result.dataset.testid = 'attack-result';
  attack.append(
    button('攻撃を再生', () => startAttack()),
    button('攻撃を停止', () => stop()),
    range,
    clock,
    result,
    make('p', 'シークは無音。試遊と同じMoonBitの弾道・命中判定を再計算します。'),
  );
  range.addEventListener(
    'input',
    () => {
      stop();
      sample(Number(range.value));
    },
    { signal },
  );
  timeline.append(make('h2', 'IRON YARD / Scene & Action'), bar, files, attack);
  let audio,
    buffers,
    playingSources = new Set();
  async function prepareAudio() {
    audio ??= new AudioContext();
    await audio.resume();
    if (!buffers) {
      const base = new URL('games/iron-yard/editor/audio.json', document.baseURI),
        response = await fetch(base, { signal });
      if (!response.ok) throw Error('効果音を読み込めません');
      const manifest = await response.json();
      const overrides = (await resourceAssets?.()) ?? {};
      buffers = new Map(
        await Promise.all(
          Object.entries(manifest).map(async ([key, path]) => {
            const r = await fetch(overrides['audio.' + key] ?? new URL(path, base), { signal });
            if (!r.ok) throw Error('効果音を読み込めません');
            return [key, await audio.decodeAudioData(await r.arrayBuffer())];
          }),
        ),
      );
    }
  }
  function sound(id) {
    const buffer = buffers?.get(soundFiles[id]);
    if (!buffer || !audio) return;
    const source = audio.createBufferSource(),
      gain = audio.createGain();
    gain.gain.value = 0.4;
    source.buffer = buffer;
    source.connect(gain).connect(audio.destination);
    playingSources.add(source);
    source.onended = () => {
      playingSources.delete(source);
      source.disconnect();
      gain.disconnect();
    };
    source.start();
  }
  function stop() {
    playVersion++;
    running = false;
    cancelAnimationFrame(tick);
    for (const source of playingSources) source.stop();
    playingSources.clear();
  }
  function sample(value) {
    if (!replay || signal.aborted) return;
    time = value;
    const state = replay(doc.action, time);
    view.sampleAttack(doc.action, time, state);
    range.value = String(time);
    clock.value = `${time.toFixed(3)}s`;
    result.dataset.shots = String(state.shots);
    result.dataset.hits = String(state.hits);
    result.dataset.hp = String(state.units[0].hp);
    result.value = `発射 ${state.shots} / 命中 ${state.hits} / 標的HP ${state.units[0].hp}`;
    if (running && state.hits > previousHits)
      sound(state.units[0].hp === 0 ? 'sfx.explosion' : doc.action.hitSound);
    previousHits = state.hits;
  }
  async function startAttack() {
    stop();
    const version = playVersion,
      actionSignature = JSON.stringify(doc.action);
    try {
      await prepareAudio();
      if (
        signal.aborted ||
        version !== playVersion ||
        mode !== 'action' ||
        actionSignature !== JSON.stringify(doc.action)
      )
        return;
      sample(0);
      previousHits = 0;
      running = true;
      sound(doc.action.shotSound);
      let previous = performance.now();
      const advance = (now) => {
        if (!running) return;
        sample(Math.min(1.5, time + Math.min(0.1, (now - previous) / 1000)));
        previous = now;
        if (time < 1.5) tick = requestAnimationFrame(advance);
        else running = false;
      };
      tick = requestAnimationFrame(advance);
    } catch (cause) {
      if (!signal.aborted) fail(cause);
    }
  }
  async function setMode(next) {
    stop();
    mode = next;
    sceneTab.setAttribute('aria-pressed', String(mode === 'scene'));
    actionTab.setAttribute('aria-pressed', String(mode === 'action'));
    waveLabel.hidden = mode !== 'scene';
    attack.hidden = mode !== 'action';
    renderInspector();
    view.showAction(mode === 'action');
    if (mode === 'action')
      try {
        replay = (await import('../headless.mjs')).replayAttack;
        if (!signal.aborted && mode === 'action') {
          range.disabled = false;
          sample(0);
        }
      } catch (cause) {
        fail(cause);
      }
  }
  return {
    update(next) {
      doc = next;
      title.textContent = doc.name;
      info.textContent = `${doc.stage.solids.length + doc.stage.targets.length + 1} objects · ${doc.mission.waves.length} waves · Y-up · meters`;
      if (selected !== 'spawn' && ![...doc.stage.solids, ...doc.stage.targets].some((s) => s.id === selected))
        selected = 'spawn';
      wave = Math.min(wave, doc.mission.waves.length - 1);
      stop();
      renderTree();
      renderInspector();
      wavePicker.replaceChildren(
        ...doc.mission.waves.map((w, i) => {
          const option = make('option', `WAVE ${i + 1}`);
          option.value = String(i);
          return option;
        }),
      );
      wavePicker.value = String(wave);
      view.update(doc, selected, wave);
      if (mode === 'action') sample(0);
      attack.hidden = mode !== 'action';
    },
    setActive(value) {
      if (!value) stop();
      view.setActive(value);
    },
    frame: () => view.frame(selected),
    view: (name) => view.view(name),
    dispose() {
      stop();
      lifetime.abort();
      audio?.close();
      view.dispose();
      container.classList.remove('iron-authoring');
      studio.classList.remove('editing-iron-yard');
      if (glbButton) glbButton.style.display = glbDisplay;
      title.remove();
      info.remove();
      for (const { host, original, panel } of occupied) {
        panel.remove();
        host.replaceChildren(...original.childNodes);
      }
    },
  };
}
