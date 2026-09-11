import { runtimeSettings } from '../../../../../editor/studio/projects/settings.mjs';
export const game = 'iron_yard';
export const sceneSchema = Object.freeze({ id: 'iron_yard.scene', version: 1 });
import { createIronYardPlugin, readSettings, previewId } from './plugin.mjs';
import { readScene, sceneId, defaultScene, validateSceneDocument } from './scene-plugin.mjs';
import { createGamePreview } from '../../../../../editor/studio/web/game-preview.mjs';
import { createIronYardAuthoring } from './panels.mjs';
import { downloadBlob } from '../../../../../editor/studio/web/storage.mjs';

export function installIronYard({
  editor,
  panes,
  viewport,
  setStatus,
  project,
  runtimeURL,
  notifyState,
}) {
  const resourceAssets = async () => {
    if (!project) return {};
    const entries = await Promise.all(
      Object.entries(project.manifest.resources).map(async ([id, path]) => [
        id,
        await project.url(path),
      ]),
    );
    return Object.fromEntries(entries);
  };
  const container = document.getElementById('viewport');
  const sessionId = crypto.randomUUID();
  let authoring,
    sceneSignature,
    settingsSignature,
    lastRequest,
    lastRevision = -1,
    disposed = false,
    gameActive = false;
  const button = (label, fn) => {
    const node = document.createElement('button');
    node.type = 'button';
    node.textContent = label;
    node.addEventListener('click', fn);
    return node;
  };
  const preview = createGamePreview(container, {
    url: (() => {
      const url = new URL(runtimeURL ?? 'games/iron-yard/index.html', document.baseURI);
      url.searchParams.set('editor', '1');
      return url.href;
    })(),
    resourceAssets,
    projectSettings: project ? runtimeSettings(project.manifest) : undefined,
    title: 'IRON YARD game preview',
    onStatus: setStatus,
    onActive(active) {
      gameActive = active;
      viewport?.setActive(!active && !authoring);
      authoring?.setActive(!active);
      notifyState?.();
    },
  });
  async function invoke(tool, args, expectedRevision = editor.snapshot().revision) {
    const reply = await panes.invokeTool('iron-yard', tool, args, { expectedRevision });
    if (!reply.ok) throw Error(reply.error.message);
    return reply;
  }
  invoke.capture = () => editor.snapshot().revision;
  function fail(error) {
    setStatus('IRON YARD · ' + error.message);
  }
  function activate() {
    if (authoring || disposed) return;
    authoring = createIronYardAuthoring({
      container,
      invoke,
      onStatus: setStatus,
      play: trial,
      resourceAssets,
      projectSettings: project ? runtimeSettings(project.manifest) : undefined,
      runtimeURL,
    });
    viewport?.setActive(false);
    authoring.update(readScene(editor.snapshot()));
    authoring.setActive(!gameActive);
    notifyState?.();
  }
  async function open() {
    try {
      if (disposed) throw Error('IRON YARD plugin is unloaded');
      if (!editor.snapshot().document.resources.some((r) => r.id === sceneId))
        await invoke('scene_load', { document: defaultScene() });
      activate();
      preview.close();
      panes.open('iron-yard');
    } catch (error) {
      fail(error);
    }
  }
  async function trial() {
    try {
      await open();
      await invoke('preview', { action: 'play' });
    } catch (error) {
      fail(error);
    }
  }
  function closeEditor() {
    preview.close();
    authoring?.dispose();
    authoring = undefined;
    viewport?.setActive(true);
    notifyState?.();
  }
  function sync(snapshot) {
    if (lastRevision === snapshot.revision) return;
    lastRevision = snapshot.revision;
    try {
      const settings = readSettings(snapshot),
        hasScene = snapshot.document.resources.some((r) => r.id === sceneId),
        scene = hasScene ? readScene(snapshot) : null;
      const a = JSON.stringify(settings),
        b = JSON.stringify(scene);
      if (a !== settingsSignature) {
        preview.configure(settings);
        settingsSignature = a;
        sceneSignature = undefined;
      }
      if (b !== sceneSignature) {
        preview.loadScene(scene);
        sceneSignature = b;
        if (scene) {
          activate();
          authoring?.update(scene);
        } else closeEditor();
      }
      const request = snapshot.document.resources.find((r) => r.id === previewId),
        serialized = JSON.stringify(request) ?? 'absent';
      if (serialized !== lastRequest) {
        const execute =
          lastRequest !== undefined &&
          request?.kind === previewId &&
          request.version === 1 &&
          request.data.session === sessionId &&
          request.data.token === snapshot.revision;
        lastRequest = serialized;
        if (execute) {
          if (scene) activate();
          preview.command(request.data.action).catch(fail);
        } else preview.command('pause');
      }
    } catch (error) {
      preview.close();
      fail(error);
    }
  }
  const unsubscribe = editor.subscribe(sync);
  sync(editor.snapshot());
  function release() {
    if (disposed) return;
    disposed = true;
    unsubscribe();
    closeEditor();
    preview.dispose();
  }
  panes.registerPlugin(
    createIronYardPlugin({
      sessionId,
      dispose: release,
      inspect: preview.snapshot,
      mount({ element, signal, subscribe }) {
        const title = document.createElement('h2');
        title.textContent = 'IRON YARD / Scene Studio';
        const note = document.createElement('p');
        note.className = 'panel-note';
        note.textContent =
          '建物・敵・出撃地点をHierarchyで選択し、Inspectorで編集。シーン・攻撃・ミッションを保存して試遊できます。';
        const controls = document.createElement('div');
        controls.className = 'game-transport';
        controls.append(
          button('編集に戻る', open),
          button('試遊する', trial),
          button('Pause game', () => invoke('preview', { action: 'pause' }).catch(fail)),
          button('Reset game', () => invoke('preview', { action: 'reset' }).catch(fail)),
          button('Close IRON YARD', closeEditor),
        );
        const label = document.createElement('label');
        label.className = 'custom-field';
        label.textContent = '試遊モード';
        const mode = document.createElement('select');
        mode.setAttribute('aria-label', '試遊モード');
        for (const [value, text] of [
          ['true', '敵AIと交戦'],
          ['false', '静止標的で演習'],
        ]) {
          const option = document.createElement('option');
          option.value = value;
          option.textContent = text;
          mode.append(option);
        }
        mode.addEventListener(
          'change',
          () =>
            invoke('configure', {
              ...readSettings(editor.snapshot()),
              ai: mode.value === 'true',
            }).catch(fail),
          { signal },
        );
        label.append(mode);
        const summary = document.createElement('p');
        summary.className = 'panel-note';
        const render = (snapshot) => {
          try {
            const scene = readScene(snapshot);
            mode.value = String(readSettings(snapshot).ai);
            summary.textContent = `${scene.stage.solids.length} BUILDINGS · ${scene.stage.targets.length} ENEMIES · ${scene.mission.waves.length} WAVES`;
          } catch (error) {
            summary.textContent = error.message;
          }
        };
        render(editor.snapshot());
        subscribe(render);
        element.append(title, note, controls, label, summary);
      },
    }),
  );
  if (editor.snapshot().document.resources.some((r) => r.id === sceneId)) open();
  return Object.freeze({
    play: trial,
    canPlay: () => !disposed,
    stop: () => preview.close(),
    playing: () => gameActive,
    open,
    closeView: closeEditor,
    active: () => !!authoring,
    readDocument: () => readScene(editor.snapshot()),
    validateDocument: validateSceneDocument,
    frame: () => authoring?.frame(),
    view: (name) => authoring?.view(name),
    async importScene(document, revision) {
      await invoke('scene_load', { document }, revision);
      await open();
    },
    exportScene() {
      downloadBlob(
        new Blob([JSON.stringify(readScene(editor.snapshot()), null, 2)], {
          type: 'application/json',
        }),
        'iron-yard.scene.json',
      );
    },
    dispose() {
      panes.unregister('iron-yard');
      release();
    },
  });
}

export const apiVersion = 1;
export const id = 'iron-yard';
export const validateDocument = validateSceneDocument;
export const activate = installIronYard;
