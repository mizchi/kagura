import { add, sub, scale, normal, ray, pick, orbitCamera, frameCamera, sceneBounds } from './camera.mjs';
/** Reuse the game's WebGPU renderer in an isolated Window; no Three scene reconstruction. */
export function createIronYardSceneView(
  container,
  {
    onSelect,
    onError,
    projectSettings,
    resourceAssets = async () => ({}),
    runtimeURL = new URL('games/iron-yard/index.html', document.baseURI).href,
  },
) {
  const frame = document.createElement('iframe');
  frame.className = 'iron-scene-canvas';
  frame.title = 'IRON YARD シーンプレビュー';
  frame.setAttribute('aria-label', frame.title);
  frame.dataset.ready = 'false';
  frame.dataset.renderer = 'kagura-webgpu';
  let runtime,
    doc,
    wave = 0,
    selected = 'spawn',
    active = true,
    disposed = false,
    action = false,
    sampleTime = 0,
    signature;
  let camera = { eye: [65, 78, -82], target: [0, 0, -2] },
    detach = () => {};
  const bounds = () => (doc ? sceneBounds(doc, wave) : []);
  const updateCamera = () => runtime?.camera(camera.eye, camera.target);
  const select = (id) => {
    selected = id;
    runtime?.selection(bounds().find((b) => b.id === id));
  };
  function sync() {
    if (!runtime || !doc) return;
    const next = JSON.stringify([doc, wave]);
    if (next !== signature) {
      runtime.scene(doc, wave);
      signature = next;
    }
    if (action) runtime.attack(doc, sampleTime);
    select(selected);
    updateCamera();
    runtime.active(active);
  }
  let resolveReady;
  const ready = new Promise((resolve) => (resolveReady = resolve));
  const message = async (event) => {
    if (
      event.source !== frame.contentWindow ||
      event.origin !== location.origin ||
      event.data?.version !== 1 ||
      disposed
    )
      return;
    try {
      if (event.data.type === 'kagura:request-assets') {
        const assets = await resourceAssets();
        if (!disposed)
          frame.contentWindow.postMessage({ type: 'kagura:assets', version: 1, assets, project: projectSettings }, location.origin);
      }
      if (event.data.type === 'kagura:game-error') throw Error(event.data.message);
      if (event.data.type === 'kagura:authoring-ready') {
        runtime = frame.contentWindow.kaguraAuthoring;
        sync();
        const canvas = frame.contentDocument.getElementById('app');
        const abort = new AbortController();
        detach = () => abort.abort();
        let down, last;
        canvas.addEventListener(
          'pointerdown',
          (e) => {
            down = [e.clientX, e.clientY, e.button];
            last = down;
            canvas.setPointerCapture(e.pointerId);
          },
          { signal: abort.signal },
        );
        canvas.addEventListener(
          'pointermove',
          (e) => {
            if (!down) return;
            const dx = e.clientX - last[0],
              dy = e.clientY - last[1];
            last = [e.clientX, e.clientY];
            if (down[2] === 2 || e.shiftKey) {
              const d = Math.hypot(...sub(camera.eye, camera.target)) * 0.0015;
              const horizontal = normal([
                  camera.target[2] - camera.eye[2],
                  0,
                  camera.eye[0] - camera.target[0],
                ]),
                v = add(scale(horizontal, -dx * d), [0, dy * d, 0]);
              camera = { eye: add(camera.eye, v), target: add(camera.target, v) };
            } else camera = orbitCamera(camera, -dx * 0.005, -dy * 0.005);
            updateCamera();
          },
          { signal: abort.signal },
        );
        canvas.addEventListener(
          'pointerup',
          (e) => {
            if (
              down &&
              down[2] === 0 &&
              Math.hypot(e.clientX - down[0], e.clientY - down[1]) < 4 &&
              !action
            ) {
              const r = canvas.getBoundingClientRect();
              const id = pick(
                ray(
                  camera,
                  ((e.clientX - r.left) / r.width) * 2 - 1,
                  1 - ((e.clientY - r.top) / r.height) * 2,
                  r.width / r.height,
                ),
                bounds(),
              );
              if (id) onSelect(id);
            }
            down = null;
          },
          { signal: abort.signal },
        );
        canvas.addEventListener('pointercancel', () => (down = null), { signal: abort.signal });
        canvas.addEventListener('contextmenu', (e) => e.preventDefault(), { signal: abort.signal });
        canvas.addEventListener(
          'wheel',
          (e) => {
            e.preventDefault();
            const offset = sub(camera.eye, camera.target),
              distance = Math.max(2, Math.min(240, Math.hypot(...offset) * Math.exp(e.deltaY * 0.001)));
            camera = { ...camera, eye: add(camera.target, scale(normal(offset), distance)) };
            updateCamera();
          },
          { passive: false, signal: abort.signal },
        );
        // Bubble editor shortcuts across the frame without capturing game input.
        frame.contentDocument.addEventListener(
          'keydown',
          (e) => {
            if (
              e.key.toLowerCase() === 'f' ||
              ((e.metaKey || e.ctrlKey) && ['s', 'z'].includes(e.key.toLowerCase()))
            ) {
              e.preventDefault();
              document.dispatchEvent(
                new KeyboardEvent('keydown', {
                  key: e.key,
                  ctrlKey: e.ctrlKey,
                  metaKey: e.metaKey,
                  shiftKey: e.shiftKey,
                  bubbles: true,
                }),
              );
            }
          },
          { signal: abort.signal },
        );
        frame.dataset.ready = 'true';
        resolveReady();
      }
    } catch (error) {
      if (!disposed) onError(error);
      resolveReady();
    }
  };
  window.addEventListener('message', message);
  const url = new URL(runtimeURL);
  url.searchParams.set('authoring', '1');
  frame.src = url.href;
  container.append(frame);
  return {
    ready,
    select,
    update(next, id, index) {
      doc = next;
      wave = index;
      selected = id;
      sync();
    },
    setActive(value) {
      active = value;
      runtime?.active(value);
    },
    showAction(value) {
      action = value;
      signature = undefined;
      sampleTime = 0;
      camera = value ? { eye: [23, 15, -17], target: [0, 2, 8] } : { eye: [65, 78, -82], target: [0, 0, -2] };
      sync();
    },
    sampleAttack(_action, time) {
      sampleTime = time;
      if (runtime && doc) runtime.attack(doc, time);
    },
    frame(id = selected) {
      const box = bounds().find((b) => b.id === id);
      if (box) {
        camera = frameCamera(camera, box);
        updateCamera();
      }
    },
    view(name) {
      const offsets = {
        perspective: [65, 78, -82],
        front: [0, 12, -100],
        side: [100, 12, 0],
        top: [0, 140, 0.01],
      };
      camera = { eye: offsets[name] ?? offsets.perspective, target: [0, 0, -2] };
      updateCamera();
    },
    dispose() {
      disposed = true;
      detach();
      window.removeEventListener('message', message);
      frame.remove();
      runtime = undefined;
      resolveReady();
    },
  };
}
