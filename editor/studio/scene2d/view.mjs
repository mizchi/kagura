import { readScene2D, screenPoint, resizedObject } from './model.mjs';
import { isInspectorChrome } from '../web/studio-parts.mjs';
const ns = 'http://www.w3.org/2000/svg';
const color = (value) => '#' + value.toString(16).padStart(6, '0');
/** Event-driven layout view: local camera/selection, transactional document edits. */
export function createPlaneEditor({ editor, project, profile, edit, setStatus, workspace }) {
  const lifetime = new AbortController(),
    signal = lifetime.signal;
  const occupied = [];
  const make = (tag, text) => {
    const node = document.createElement(tag);
    if (text !== undefined) node.textContent = text;
    return node;
  };
  function occupy(selector) {
    const host = document.querySelector(selector),
      original = make('div'),
      panel = make('div');
    original.hidden = true;
    const keep = [...host.childNodes].filter((node) => isInspectorChrome(node));
    original.append(...[...host.childNodes].filter((node) => !isInspectorChrome(node)));
    panel.className = 'plane-panel';
    host.append(original, panel);
    for (const node of keep) host.insertBefore(node, original);
    occupied.push({ original, panel });
    return panel;
  }
  function fill(slotId, selector) {
    if (!workspace) return occupy(selector);
    const node = workspace.slot(slotId).adopt({
      id: 'plane',
      title: slotId,
      mount({ element }) {
        element.classList.add('plane-panel');
      },
    });
    return node;
  }
  const tree = fill('hierarchy', '.hierarchy'),
    inspector = fill('inspector', '.inspector'),
    resources = fill('resources', '.assets'),
    timeline = fill('timeline', '.timeline');
  const container = document.getElementById('viewport');
  const root = make('div');
  root.className = 'plane2d';
  root.setAttribute('aria-label', '2D scene editor');
  const svg = document.createElementNS(ns, 'svg');
  svg.setAttribute('aria-label', '2D scene viewport');
  svg.setAttribute('tabindex', '0');
  svg.setAttribute('role', 'img');
  const toolbar = make('div');
  toolbar.className = 'plane-controls';
  const caption = make('span', '2D · X → / Y ↓ · px');
  const zoomLabel = make('span');
  zoomLabel.setAttribute('aria-label', '2D zoom');
  const gridLabel = make('label', 'Grid '),
    grid = make('input');
  grid.type = 'checkbox';
  grid.checked = true;
  grid.setAttribute('aria-label', '2D grid');
  gridLabel.append(grid);
  const snapLabel = make('label', 'Snap '),
    snap = make('input');
  snap.type = 'number';
  snap.value = '1';
  snap.min = '1';
  snap.max = '64';
  snap.setAttribute('aria-label', '2D snap');
  snapLabel.append(snap);
  const fitButton = make('button', 'Fit'),
    oneButton = make('button', '100%');
  fitButton.type = oneButton.type = 'button';
  toolbar.append(caption, fitButton, oneButton, zoomLabel, gridLabel, snapLabel);
  const help = make('p', 'Drag: move · Corner: resize · Wheel: zoom · Middle / right drag: pan');
  help.className = 'plane-help';
  root.append(svg, toolbar, help);
  container.append(root);
  container.classList.add('plane-active');
  document.querySelector('.studio').classList.add('editing-2d');
  const glb = [...document.querySelectorAll('.toolbar button')].find(
    (node) => node.textContent === 'Export GLB',
  );
  const glbDisplay = glb?.style.display;
  if (glb) glb.style.display = 'none';
  const info = make('span', '2D · pixels · Y-down');
  info.className = 'plane-info';
  document.querySelector('.workspace-info').after(info);
  let layout,
    selected = '',
    drag,
    active = true,
    signature = Symbol('initial');
  const camera = { x: 20, y: 20, zoom: 1 };
  function frameSize() {
    return layout ?? project.manifest.display ?? { width: 640, height: 480 };
  }
  function fit() {
    const r = svg.getBoundingClientRect(),
      size = frameSize();
    camera.zoom = Math.max(
      0.1,
      Math.min(8, Math.min((r.width - 64) / size.width, (r.height - 100) / size.height)),
    );
    camera.x = (r.width - size.width * camera.zoom) / 2;
    camera.y = (r.height - size.height * camera.zoom) / 2 + 12;
    draw();
  }
  function fail(error) {
    setStatus('Error · ' + error.message);
    renderInspector();
    draw();
  }
  function shape(tag, attrs) {
    const node = document.createElementNS(ns, tag);
    for (const [key, value] of Object.entries(attrs)) node.setAttribute(key, String(value));
    return node;
  }
  function draw(preview) {
    const size = frameSize();
    svg.replaceChildren();
    const group = shape('g', {
      transform: `translate(${camera.x} ${camera.y}) scale(${camera.zoom})`,
    });
    svg.append(group);
    group.append(
      shape('rect', {
        width: size.width,
        height: size.height,
        fill: color(layout?.background ?? 0x1b2634),
        stroke: '#75869b',
        'stroke-width': 1 / camera.zoom,
      }),
    );
    if (grid.checked) {
      const lines = shape('path', {
        fill: 'none',
        stroke: '#ffffff',
        opacity: '.10',
        'stroke-width': 1 / camera.zoom,
        'pointer-events': 'none',
      });
      let d = '';
      for (let x = 16; x < size.width; x += 16) d += `M${x} 0V${size.height}`;
      for (let y = 16; y < size.height; y += 16) d += `M0 ${y}H${size.width}`;
      lines.setAttribute('d', d);
      group.append(lines);
    }
    for (const original of layout?.objects ?? []) {
      const object = preview?.id === original.id ? { ...original, ...preview.changes } : original;
      const rect = shape('rect', {
        x: object.x,
        y: object.y,
        width: Math.max(0.1, object.width),
        height: Math.max(0.1, object.height),
        fill: color(object.color),
        'data-object-id': object.id,
        'aria-label': object.name,
      });
      group.append(rect);
    }
    const object = layout?.objects.find((o) => o.id === selected);
    if (object) {
      const shown = preview?.id === selected ? { ...object, ...preview.changes } : object;
      group.append(
        shape('rect', {
          x: shown.x,
          y: shown.y,
          width: Math.max(0.1, shown.width),
          height: Math.max(0.1, shown.height),
          fill: 'none',
          stroke: '#ffce80',
          'stroke-width': 2 / camera.zoom,
          'pointer-events': 'none',
        }),
      );
      if (
        profile.fields[object.kind].includes('width') &&
        profile.fields[object.kind].includes('height')
      )
        group.append(
          shape('rect', {
            x: shown.x + shown.width - 4 / camera.zoom,
            y: shown.y + shown.height - 4 / camera.zoom,
            width: 8 / camera.zoom,
            height: 8 / camera.zoom,
            fill: '#ffce80',
            'data-resize-id': object.id,
            'aria-label': 'Resize ' + object.name,
          }),
        );
    }
    zoomLabel.textContent = Math.round(camera.zoom * 100) + '%';
  }
  function select(id) {
    selected = id;
    renderTree();
    renderInspector();
    draw();
  }
  function renderTree() {
    tree.replaceChildren(make('h2', '2D Hierarchy'));
    for (const object of layout?.objects ?? []) {
      const button = make('button', object.name);
      button.type = 'button';
      button.className = 'plane-object';
      button.dataset.planeId = object.id;
      button.setAttribute('aria-pressed', String(selected === object.id));
      button.addEventListener('click', () => select(object.id));
      tree.append(button);
    }
    if (!layout)
      tree.append(
        make('p', 'このゲームの配置アダプターは未実装です。Play でゲームを確認できます。'),
      );
  }
  function renderInspector() {
    inspector.replaceChildren(make('h2', '2D Inspector'));
    const object = layout?.objects.find((o) => o.id === selected);
    if (!object) {
      inspector.append(
        make(
          'p',
          profile
            ? 'オブジェクトを選択してください。'
            : '起動パラメーターは Example設定で編集します。',
        ),
      );
      return;
    }
    inspector.append(make('p', object.kind + ' · pixels'));
    for (const [key, label] of [
      ['name', 'Name'],
      ['x', 'X'],
      ['y', 'Y'],
      ['width', 'Width'],
      ['height', 'Height'],
      ['color', 'Color'],
    ]) {
      const row = make('label', label),
        input = make('input');
      row.className = 'custom-field';
      input.setAttribute('aria-label', '2D ' + label);
      input.type = key === 'color' ? 'color' : key === 'name' ? 'text' : 'number';
      input.value = key === 'color' ? color(object[key]) : String(object[key]);
      input.step = '1';
      input.disabled = !profile.fields[object.kind].includes(key);
      input.addEventListener('change', () => {
        try {
          edit(object.id, {
            [key]:
              key === 'color'
                ? parseInt(input.value.slice(1), 16)
                : key === 'name'
                  ? input.value
                  : input.valueAsNumber,
          });
        } catch (error) {
          fail(error);
        }
      });
      row.append(input);
      inspector.append(row);
    }
  }
  function refresh(snapshot) {
    const matches =
      snapshot.document.resources.find((r) => r.id === 'kagura.example')?.data.example ===
      profile?.game;
    const next = profile && matches ? readScene2D(snapshot.document) : undefined,
      key = JSON.stringify(next);
    if (next) profile.validate(next);
    if (signature === key) return;
    const first = signature === undefined || !layout;
    signature = key;
    layout = next;
    if (!layout?.objects.some((o) => o.id === selected))
      selected = layout?.objects.find((o) => o.kind === 'bird')?.id ?? layout?.objects[0]?.id ?? '';
    drag = undefined;
    info.textContent = `${layout?.objects.length ?? 0} objects · 2D · pixels · Y-down`;
    renderTree();
    renderInspector();
    if (first) fit();
    else draw();
    timeline.replaceChildren(
      make('h2', '2D Layout'),
      make('p', `${frameSize().width} × ${frameSize().height} px · origin: top left`),
      make(
        'p',
        profile
          ? '配置の変更は次の Play に反映されます。Save でシーンを保存します。'
          : 'シーン配置の編集にはゲーム固有のアダプターが必要です。',
      ),
    );
  }
  resources.append(make('h2', '2D Resources'));
  for (const [id, path] of Object.entries(project.manifest.resources))
    if (id !== 'runtime') resources.append(make('p', `${id} · ${path}`));
  if (!resources.querySelector('p'))
    resources.append(make('p', 'プロジェクトのアセットは Project ペーンで確認できます。'));
  svg.addEventListener('contextmenu', (e) => e.preventDefault(), { signal });
  const point = (e) => screenPoint(e.clientX, e.clientY, svg.getBoundingClientRect(), camera);
  svg.addEventListener(
    'pointerdown',
    (e) => {
      if (!active) return;
      if (e.button === 1 || e.button === 2)
        drag = { mode: 'pan', startX: e.clientX, startY: e.clientY, x: camera.x, y: camera.y };
      else if (e.button === 0) {
        const id = e.target.dataset.resizeId ?? e.target.dataset.objectId,
          object = layout?.objects.find((o) => o.id === id);
        select(id ?? '');
        if (!object || !profile) return;
        drag = {
          mode: e.target.dataset.resizeId ? 'resize' : 'move',
          object,
          start: point(e),
          revision: editor.snapshot().revision,
        };
      } else return;
      e.preventDefault();
      svg.setPointerCapture(e.pointerId);
    },
    { signal },
  );
  svg.addEventListener(
    'pointermove',
    (e) => {
      if (!drag) return;
      if (drag.mode === 'pan') {
        camera.x = drag.x + e.clientX - drag.startX;
        camera.y = drag.y + e.clientY - drag.startY;
        draw();
        return;
      }
      const p = point(e),
        step = Math.max(1, Math.min(64, Number(snap.value) || 1));
      const changes =
        drag.mode === 'resize'
          ? resizedObject(drag.object, p, step)
          : Object.fromEntries(
              ['x', 'y']
                .filter((k) => profile.fields[drag.object.kind].includes(k))
                .map((k) => [k, Math.round((drag.object[k] + p[k] - drag.start[k]) / step) * step]),
            );
      drag.changes = profile.edit(drag.object, changes, layout);
      draw({ id: drag.object.id, changes: drag.changes });
    },
    { signal },
  );
  function cancel() {
    drag = undefined;
    draw();
  }
  svg.addEventListener(
    'pointerup',
    (e) => {
      const operation = drag;
      drag = undefined;
      if (svg.hasPointerCapture(e.pointerId)) svg.releasePointerCapture(e.pointerId);
      if (
        operation?.changes &&
        Object.keys(operation.changes).some((k) => operation.changes[k] !== operation.object[k])
      ) {
        try {
          edit(operation.object.id, operation.changes, operation.revision);
        } catch (error) {
          fail(error);
        }
      }
      draw();
    },
    { signal },
  );
  svg.addEventListener('pointercancel', cancel, { signal });
  svg.addEventListener('lostpointercapture', cancel, { signal });
  svg.addEventListener(
    'keydown',
    (e) => {
      if (e.key === 'Escape') cancel();
    },
    { signal },
  );
  svg.addEventListener(
    'wheel',
    (e) => {
      e.preventDefault();
      const p = point(e),
        rect = svg.getBoundingClientRect();
      camera.zoom = Math.max(0.1, Math.min(8, camera.zoom * Math.exp(-e.deltaY * 0.001)));
      camera.x = e.clientX - rect.left - p.x * camera.zoom;
      camera.y = e.clientY - rect.top - p.y * camera.zoom;
      draw();
    },
    { signal, passive: false },
  );
  fitButton.addEventListener('click', fit, { signal });
  oneButton.addEventListener(
    'click',
    () => {
      camera.zoom = 1;
      draw();
    },
    { signal },
  );
  grid.addEventListener('change', () => draw(), { signal });
  const observer = new ResizeObserver(fit);
  observer.observe(svg);
  const unsubscribe = editor.subscribe((snapshot) => {
    try {
      refresh(snapshot);
    } catch (error) {
      fail(error);
    }
  });
  refresh(editor.snapshot());
  return {
    fit,
    setActive(value) {
      active = value;
      if (!active) cancel();
    },
    dispose() {
      if (glb) glb.style.display = glbDisplay;
      info.remove();
      lifetime.abort();
      observer.disconnect();
      unsubscribe();
      root.remove();
      container.classList.remove('plane-active');
      document.querySelector('.studio').classList.remove('editing-2d');
      if (workspace) {
        for (const id of ['hierarchy', 'inspector', 'resources', 'timeline']) workspace.slot(id).release('plane');
      } else {
        for (const { original, panel } of occupied) {
          panel.remove();
          original.replaceWith(...original.childNodes);
        }
      }
    },
  };
}
