import { modelFormat, prepareModel } from './model.mjs';
import { createModelFrame } from './frame.mjs';

/** Built in for every project, independent of the game's editor extension or Play runtime. */
export function installModelAssets({ host, panes, viewport, setStatus }) {
  let project = host.project(),
    mounted,
    viewer,
    resumeViewport,
    sequence = 0,
    disposed = false;
  let state = { path: null, state: 'idle', warnings: [], stats: null };
  const snapshot = () => structuredClone(state);
  function reset() {
    sequence++;
    viewer?.dispose();
    viewer = undefined;
    resumeViewport?.();
    resumeViewport = undefined;
    state = { path: null, state: 'idle', warnings: [], stats: null };
    mounted?.stage.replaceChildren();
    if (mounted) {
      mounted.warnings.textContent = '';
      mounted.overlay.hidden = true;
    }
  }
  async function list() {
    const p = host.project();
    if (!p) return [];
    const files = await p.list();
    if (host.project() !== p || disposed) throw new DOMException('Project changed', 'AbortError');
    return files.filter(modelFormat).sort();
  }
  async function refresh() {
    const target = mounted;
    const files = await list();
    if (!target || target !== mounted) return;
    target.select.replaceChildren(
      new Option('モデルを選択…', ''),
      ...files.map((path) => new Option(path, path)),
    );
    target.select.value = state.path ?? '';
    target.note.textContent = files.length
      ? 'ドラッグ: 回転 · 右ドラッグ: 平行移動 · ホイール: 拡大縮小'
      : 'プロジェクト内の .glb / .gltf / .obj をここでプレビューできます。';
  }
  function report(error) {
    if (error.name !== 'AbortError') setStatus('Error · ' + error.message);
  }
  async function preview(path) {
    if (disposed) throw Error('Model assets are disposed');
    const p = host.project();
    if (!p) throw Error('Open a project first');
    if (!modelFormat(path)) throw Error('Supported models: .glb, .gltf, .obj');
    panes.open('studio.models');
    reset();
    const token = sequence,
      target = mounted;
    state = { path, state: 'loading', warnings: [], stats: null };
    target.select.value = path;
    target.result.textContent = 'Loading · ' + path;
    try {
      const model = await prepareModel(p, path);
      if (token !== sequence || p !== host.project() || !mounted)
        throw new DOMException('Model preview superseded', 'AbortError');
      target.overlay.hidden = false;
      resumeViewport = viewport?.suspendRendering();
      viewer = createModelFrame(target.stage, model);
      const stats = await viewer.ready;
      if (token !== sequence || p !== host.project())
        throw new DOMException('Model preview superseded', 'AbortError');
      state = {
        path,
        state: 'ready',
        warnings: model.warnings,
        stats: { nodes: stats.nodes, triangles: stats.triangles },
      };
      target.result.textContent = `${path} · ${stats.nodes} nodes · ${stats.triangles} triangles`;
      target.warnings.textContent = model.warnings.join('\n');
      setStatus('Model preview · ' + path);
      return snapshot();
    } catch (error) {
      if (token === sequence) {
        viewer?.dispose();
        viewer = undefined;
        resumeViewport?.();
        resumeViewport = undefined;
        target.overlay.hidden = true;
        state = { path, state: 'error', warnings: [], stats: null };
        target.result.textContent = error.message;
      }
      throw error;
    }
  }
  panes.register({
    id: 'studio.models',
    title: 'Models',
    mount({ element }) {
      const heading = document.createElement('h2');
      heading.textContent = 'Model preview';
      const select = document.createElement('select');
      select.setAttribute('aria-label', 'Model resource');
      const note = document.createElement('p');
      note.className = 'panel-note';
      const overlay = document.createElement('section');
      overlay.className = 'model-overlay';
      overlay.setAttribute('aria-label', 'Model preview workspace');
      overlay.hidden = true;
      const toolbar = document.createElement('div');
      toolbar.className = 'model-toolbar';
      const label = document.createElement('strong');
      label.textContent = 'Model preview';
      const back = document.createElement('button');
      back.textContent = 'Close model';
      back.addEventListener('click', () => panes.close('studio.models'));
      toolbar.append(label, back);
      const stage = document.createElement('div');
      stage.className = 'model-stage';
      overlay.append(toolbar, stage);
      document.querySelector('.viewport').append(overlay);
      const result = document.createElement('p');
      result.setAttribute('aria-label', 'Model information');
      const warnings = document.createElement('p');
      warnings.className = 'model-warnings';
      const fit = document.createElement('button');
      fit.textContent = 'Frame model';
      fit.addEventListener('click', () => viewer?.reset());
      const refreshButton = document.createElement('button');
      refreshButton.textContent = 'Refresh models';
      refreshButton.addEventListener('click', () => refresh().catch(report));
      select.addEventListener('change', () => {
        if (select.value) preview(select.value).catch(report);
        else {
          reset();
          result.textContent = '';
          warnings.textContent = '';
        }
      });
      element.append(heading, select, fit, refreshButton, note, result, warnings);
      mounted = { select, note, stage, result, warnings, overlay };
      refresh().catch(report);
      return () => {
        reset();
        overlay.remove();
        mounted = undefined;
      };
    },
  });
  const unsubscribe = host.subscribe(() => {
    if (host.project() === project) return;
    project = host.project();
    reset();
    if (mounted) {
      mounted.result.textContent = '';
      mounted.warnings.textContent = '';
    }
    refresh().catch(report);
  });
  return Object.freeze({
    list,
    preview,
    snapshot,
    close() {
      panes.close('studio.models');
    },
    dispose() {
      disposed = true;
      reset();
      unsubscribe();
      panes.unregister('studio.models');
    },
  });
}
