import { validateHierarchy } from '../runtime/hierarchy.mjs';
import { createRuntimeSession } from '../runtime/session.mjs';
import { runtimeEntry, runtimeSettings } from '../projects/settings.mjs';
import { compileProject } from '../scene/profile.mjs';
import catalog from './catalog.json';
import { readLaunch, validateLaunch, launchTools, invokeLaunch } from './contract.mjs';
import { defineJSPlugin } from '../plugins/adapters.mjs';
import * as core from '../extensions/core.mjs';

export const apiVersion = 1;
export const id = 'kagura.example';
export const sceneSchema = Object.freeze({ id: 'kagura.example', version: 1 });
export function validateDocument(document, manifest) {
  const doc = core.validateDocument(document, manifest);
  const config = readLaunch({ document: doc });
  if (manifest?.game && manifest.game !== config.example)
    throw Error('Project game does not match launch scene');
  if (!catalog.some((e) => e.id === config.example && e.id !== 'iron_yard'))
    throw Error('Unknown browser example');
  return doc;
}
export function activate(
  { editor, panes, project, viewport, base, setStatus, getSceneId, getSceneDocument, notifyState },
  { toggles: toggleLabels = {}, compileScene } = {},
) {
  if (!project) throw Error('Open an example project first');
  let debug;
  let frame,
    detach,
    timer,
    disposed = false;
  const toolbar = document.createElement('div');
  toolbar.className = 'project-controls';
  const button = (text, action) => {
    const node = document.createElement('button');
    node.type = 'button';
    node.textContent = text;
    node.addEventListener('click', () =>
      Promise.resolve()
        .then(action)
        .catch((e) => setStatus('Error · ' + e.message)),
    );
    return node;
  };
  function stop() {
    debug?.dispose();
    debug = undefined;
    clearTimeout(timer);
    detach?.();
    detach = undefined;
    frame?.remove();
    frame = undefined;
    document.getElementById('viewport').classList.remove('game-active');
    viewport?.setActive(true);
    notifyState?.();
  }
  async function play() {
    if (!runtimeEntry(project.manifest))
      throw Error('このexampleはnative専用です。Projectペーンからソースを参照できます。');
    const revision = editor.snapshot().revision;
    const scene = compileScene?.(editor.snapshot().document);
    let sceneProject;
    if (scene && project.manifest.scenes) {
      const scenes = [];
      for (const id of Object.keys(project.manifest.scenes)) {
        const doc = await (getSceneDocument?.(id) ?? project.readScene(id));
        const compiled = compileScene(doc);
        scenes.push({ id, data: compiled.data });
      }
      sceneProject = compileProject(getSceneId?.() ?? project.manifest.entryScene, scenes);
    }
    if (editor.snapshot().revision !== revision) throw Error('Scene changed while preparing Play');
    validateDocument(editor.snapshot().document, project.manifest);
    stop();
    const config = readLaunch(editor.snapshot()),
      item = catalog.find((e) => e.id === config.example);
    const current = document.createElement('iframe');
    frame = current;
    current.className = 'game-frame';
    current.title = item.title + ' プレビュー';
    current.allow = 'autoplay';
    // Each restart owns a fresh Window, releasing input, audio and GPU resources on stop.
    const fail = (message) => {
      if (frame !== current) return;
      stop();
      setStatus('Error · ' + message);
    };
    const message = async (event) => {
      if (
        event.source !== current.contentWindow ||
        event.origin !== location.origin ||
        event.data?.version !== 1
      )
        return;
      if (event.data.type === 'kagura:example-request') {
        try {
          const assets = {};
          for (const [key, path] of Object.entries(project.manifest.resources))
            if (key !== 'runtime') assets[path] = await project.url(path);
          const script = await project.url(runtimeEntry(project.manifest), 'text/javascript');
          if (frame === current && !disposed)
            current.contentWindow.postMessage(
              {
                type: 'kagura:example-init',
                version: 1,
                script,
                assets,
                scene,
                sceneProject,
                project: runtimeSettings(project.manifest, item),
              },
              location.origin,
            );
        } catch (error) {
          fail(error.message);
        }
      }
      if (event.data.type === 'kagura:example-ready') {
        clearTimeout(timer);
        current.dataset.ready = 'true';
        current.dataset.renderer = 'kagura-webgpu';
        const adapter = current.contentWindow.kaguraDebugAdapter;
        if (adapter) {
          try {
            if (adapter.game !== config.example) throw Error('Runtime debugger game mismatch');
            debug = createRuntimeSession(adapter);
          } catch (error) { fail(error.message); return; }
        }
        notifyState?.();
        setStatus(item.title + ' · Ready');
      }
      if (event.data.type === 'kagura:example-error') fail(String(event.data.message));
    };
    window.addEventListener('message', message);
    detach = () => window.removeEventListener('message', message);
    timer = setTimeout(() => fail('Example loading timed out'), 30000);
    current.src =
      './example-runtime/index.html?' +
      new URLSearchParams(Object.entries(config.query).map(([k, v]) => [k, String(v)]));
    const container = document.getElementById('viewport');
    container.classList.add('game-active');
    viewport?.setActive(false);
    container.append(current);
    notifyState?.();
    setStatus('Loading · ' + item.title);
  }
  toolbar.append(button('Example設定', () => panes.open('studio.example')));
  document.querySelector('.viewport-toolbar').append(toolbar);
  panes.registerPlugin(
    defineJSPlugin({
      manifest: { apiVersion: 1, id: 'studio.example', title: 'Example', tools: launchTools },
      invoke: (request) => invokeLaunch(request.tool, request.arguments, request.snapshot),
      mount({ element, subscribe }) {
        const config = readLaunch(editor.snapshot()),
          item = catalog.find((e) => e.id === config.example);
        const heading = document.createElement('h2');
        heading.textContent = item.title;
        const note = document.createElement('p');
        note.textContent = compileScene
          ? 'シーンの配置と起動設定を次のPlayに反映します。'
          : '起動設定は次のPlayで反映されます。レベルはMoonBitコードで定義されています。汎用シーンのノードはゲームへ自動変換されません。';
        if (item.preview === 'native')
          note.textContent =
            'native専用exampleです。ブラウザでの試遊には未対応です。Projectペーンでソースを参照し、汎用エディタやカスタムペーンで編集データを作成できます。';
        const controls = document.createElement('p');
        controls.textContent = item.controls.join(' / ');
        const label = document.createElement('label');
        label.textContent = '起動パラメーター (JSON)';
        const input = document.createElement('textarea');
        input.rows = 8;
        input.setAttribute('aria-label', '起動パラメーター (JSON)');
        label.append(input);
        const alert = document.createElement('p');
        alert.setAttribute('role', 'alert');
        async function commit(query) {
          try {
            validateLaunch({ ...readLaunch(editor.snapshot()), query });
            const result = await panes.invokeTool(
              'studio.example',
              'launch_update',
              { query },
              { expectedRevision: editor.snapshot().revision },
            );
            if (!result.ok) throw Error(result.error.message);
            alert.textContent = '設定を更新しました。Playで再起動してください。';
          } catch (error) {
            alert.textContent = error.message;
          }
        }
        const shortcuts = document.createElement('div'),
          toggles = [];
        shortcuts.className = 'example-toggles';
        {
          for (const [key, title] of Object.entries(toggleLabels)) {
            const row = document.createElement('label'),
              checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            row.append(checkbox, title);
            shortcuts.append(row);
            checkbox.addEventListener('change', () =>
              commit({ ...readLaunch(editor.snapshot()).query, [key]: checkbox.checked }),
            );
            toggles.push([key, checkbox]);
          }
        }
        const refresh = () => {
          const query = readLaunch(editor.snapshot()).query;
          input.value = JSON.stringify(query, null, 2);
          for (const [key, toggle] of toggles)
            toggle.checked = query[key] === true || query[key] === 'true' || query[key] === 1;
        };
        element.append(
          heading,
          note,
          controls,
          shortcuts,
          label,
          button('起動設定を適用', () => {
            try {
              return commit(JSON.parse(input.value));
            } catch (e) {
              alert.textContent = e.message;
            }
          }),
          alert,
        );
        refresh();
        subscribe(refresh);
      },
    }),
  );
  return {
    play: runtimeEntry(project.manifest) ? play : undefined,
    stop,
    playing: () => !!frame,
    debug: () => debug,
    hierarchy: () => {
      const runtime = frame?.dataset.ready === 'true' ? frame.contentWindow.kaguraSceneRuntime : undefined;
      return typeof runtime?.hierarchy === 'function' ? validateHierarchy(runtime.hierarchy()) : undefined;
    },
    canPlay: () => !disposed && !!runtimeEntry(project.manifest),
    async importScene(doc, revision) {
      await base.importScene(validateDocument(doc, project.manifest), revision);
      panes.open('studio.example');
    },
    open: () => panes.open('studio.example'),
    active: () => !!frame,
    closeView: stop,
    dispose() {
      disposed = true;
      stop();
      toolbar.remove();
      panes.unregister('studio.example');
    },
  };
}
