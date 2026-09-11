import { modelFormat } from '../assets/model.mjs';
import { createFileSystemStore } from '../storage/filesystem.mjs';
import { openProject } from './project.mjs';
import { downloadBlob } from '../web/storage.mjs';
import { exampleStore } from '../examples/store.mjs';
export function filesStore(files) {
  const entries = new Map([...files].map((file) => [file.webkitRelativePath || file.name, file]));
  return {
    async read(key) {
      const blob = entries.get(key);
      if (!blob) throw Error('Project resource not found: ' + key);
      return { blob };
    },
    async list() {
      return { objects: [...entries.keys()].map((key) => ({ key })), cursor: null };
    },
  };
}
export function installProjectUI({ host, panes, assets, setStatus }) {
  let store,
    paths = [],
    disposed = false;
  const controls = document.createElement('div');
  controls.className = 'project-controls';
  const button = document.createElement('button');
  button.textContent = 'Open project';
  button.type = 'button';
  const input = document.createElement('input');
  input.type = 'file';
  input.setAttribute('webkitdirectory', '');
  input.multiple = true;
  input.hidden = true;
  input.setAttribute('aria-label', 'プロジェクトフォルダ');
  const chooser = document.createElement('select');
  chooser.setAttribute('aria-label', 'プロジェクトファイル');
  chooser.hidden = true;
  const sceneChooser = document.createElement('select');
  sceneChooser.setAttribute('aria-label', 'Project scene');
  const sceneControl = document.createElement('label');
  sceneControl.className = 'scene-selector';
  const sceneLabel = document.createElement('span');
  sceneLabel.textContent = 'Scene';
  sceneControl.append(sceneLabel, sceneChooser);
  let switchingScene = false;
  function refreshScenes() {
    const manifest = host.project()?.manifest;
    const entries = manifest?.scenes
      ? Object.entries(manifest.scenes)
      : manifest
        ? [[manifest.scene, manifest.scene]]
        : [['', '']];
    sceneChooser.replaceChildren(
      ...entries.map(([id, path]) => {
        const option = document.createElement('option');
        option.value = id;
        option.textContent = !manifest
          ? 'プロジェクト未選択'
          : manifest.scenes
            ? id + (id === manifest.entryScene ? ' (start)' : '')
            : path.split('/').at(-1);
        option.title = path;
        return option;
      }),
    );
    sceneChooser.value = host.sceneId() ?? manifest?.scene ?? '';
    sceneChooser.title =
      manifest?.scenes?.[host.sceneId()] ??
      manifest?.scene ??
      'プロジェクトを開くとシーンを選択できます';
    sceneChooser.disabled = switchingScene || !manifest?.scenes || entries.length < 2;
  }
  sceneChooser.addEventListener('change', async () => {
    const selected = sceneChooser.value;
    switchingScene = true;
    sceneChooser.disabled = true;
    try {
      await host.selectScene(selected);
      setStatus('Opened scene · ' + host.sceneId());
    } catch (error) {
      setStatus('Error · ' + error.message);
    } finally {
      switchingScene = false;
      refreshScenes();
    }
  });
  const reload = document.createElement('button');
  reload.type = 'button';
  reload.textContent = '拡張を再読込';
  reload.addEventListener('click', () =>
    host
      .reload()
      .then(() => {
        title.textContent = host.project().manifest.name;
        refreshScenes();
        setStatus('Reloaded extension · ' + host.project().manifest.name);
      })
      .catch((e) => setStatus('Error · ' + e.message)),
  );
  const title = document.createElement('span');
  title.className = 'project-current';
  const generic = document.createElement('button');
  generic.type = 'button';
  generic.textContent = '汎用エディタ';
  generic.addEventListener('click', () => host.showGeneric());
  const examples = document.createElement('select');
  examples.setAttribute('aria-label', 'Examples');
  const placeholder = document.createElement('option');
  placeholder.value = '';
  placeholder.textContent = 'Examples…';
  examples.append(placeholder);
  fetch(new URL('./examples/catalog.json', location.href))
    .then(async (response) => {
      if (!response.ok) throw Error('Examplesをビルドしてください: just studio-examples-build');
      for (const item of await response.json()) {
        if (disposed) return;
        const option = document.createElement('option');
        option.value = item.id;
        option.textContent =
          item.title +
          (item.preview === 'native' ? ' (native)' : item.preview === 'asset' ? ' (assets)' : '');
        option.dataset.manifest = item.manifest;
        examples.append(option);
      }
    })
    .catch((error) => {
      examples.title = error.message;
    });
  examples.addEventListener('change', async () => {
    if (!examples.value) return;
    examples.disabled = true;
    try {
      store = await exampleStore(examples.value);
      chooser.hidden = true;
      await activate(examples.selectedOptions[0].dataset.manifest);
    } catch (error) {
      setStatus('Error · ' + error.message);
    } finally {
      examples.disabled = false;
      examples.value = '';
    }
  });
  controls.append(generic, examples, button, reload, input, chooser, title);
  const toolbar = document.querySelector('.toolbar');
  toolbar.append(controls);
  toolbar.querySelector('.brand').after(sceneControl);
  toolbar.classList.add('has-scene-selector');
  const unsubscribeScenes = host.subscribe(refreshScenes);
  refreshScenes();
  async function activate(path) {
    let next;
    try {
      next = await openProject(store, path);
      await host.openProject(next);
      title.textContent = next.manifest.name;
      refreshScenes();
      panes.open('studio.project');
      setStatus('Opened project · ' + next.manifest.name);
    } catch (error) {
      next?.dispose();
      setStatus('Error · ' + error.message);
    }
  }
  async function discover(nextStore, knownPaths) {
    store = nextStore;
    paths = knownPaths ?? [];
    let cursor = null;
    if (!knownPaths)
      do {
        const page = await store.list({ limit: 1000, cursor });
        paths.push(...page.objects.map((o) => o.key).filter((p) => p.endsWith('.kgrprj')));
        cursor = page.cursor;
      } while (cursor);
    paths.sort();
    if (!paths.length) throw Error('選択したフォルダに .kgrprj がありません');
    chooser.replaceChildren(
      ...paths.map((path) => {
        const option = document.createElement('option');
        option.value = path;
        option.textContent = path;
        return option;
      }),
    );
    chooser.hidden = paths.length === 1;
    await activate(paths[0]);
  }
  button.addEventListener('click', async () => {
    try {
      if (!window.showDirectoryPicker) {
        input.click();
        return;
      }
      const handle = await showDirectoryPicker({ mode: 'readwrite' });
      const manifests = [];
      for await (const [name, item] of handle.entries())
        if (item.kind === 'file' && name.endsWith('.kgrprj')) manifests.push(name);
      await discover(createProjectDirectoryStore(handle), manifests);
    } catch (error) {
      if (error.name !== 'AbortError') setStatus('Error · ' + error.message);
    }
  });
  input.addEventListener('change', () => {
    discover(filesStore(input.files)).catch((error) => setStatus('Error · ' + error.message));
    input.value = '';
  });
  chooser.addEventListener('change', () => activate(chooser.value));
  panes.register({
    id: 'studio.project',
    title: 'Project',
    mount({ element, signal }) {
      const heading = document.createElement('h2');
      heading.textContent = 'Project resources';
      const refresh = document.createElement('button');
      refresh.textContent = 'Refresh resources';
      const settings = document.createElement('dl');
      settings.className = 'project-settings';
      settings.setAttribute('aria-label', 'Project settings');
      const list = document.createElement('div');
      element.append(heading, settings, refresh, list);
      let renderVersion = 0;
      async function render() {
        const version = ++renderVersion;
        const p = host.project();
        list.replaceChildren();
        settings.replaceChildren();
        if (!p) {
          list.textContent = 'Open project から .kgrprj を含むフォルダを選択してください';
          return;
        }
        heading.textContent = p.manifest.name;
        const m = p.manifest;
        const entries = {
          'Project ID': m.id,
          Game: m.game,
          Runtime:
            m.runtime &&
            `${m.runtime.kind} · API ${m.runtime.apiVersion} · ${m.runtime.targets.join(', ')}`,
          Entry: m.runtime?.entry,
          Build: m.build && `moon build ${m.build.package}`,
          'Scene package': m.build?.scenePackage,
          Display: m.display && `${m.display.width} × ${m.display.height}`,
          'Scene schema': m.sceneSchema && `${m.sceneSchema.id} · v${m.sceneSchema.version}`,
          'Save namespace': m.save && `${m.save.namespace} · v${m.save.version}`,
          'Editor API': m.editor?.apiVersion,
        };
        for (const [label, value] of Object.entries(entries)) {
          if (value === undefined) continue;
          const term = document.createElement('dt'),
            description = document.createElement('dd');
          term.textContent = label;
          description.textContent = String(value);
          settings.append(term, description);
        }
        for (const path of await p.list()) {
          if (signal.aborted || disposed || version !== renderVersion || p !== host.project())
            return;
          const row = document.createElement('button');
          row.textContent = path;
          row.className = 'project-resource';
          row.addEventListener('click', async () => {
            try {
              if (assets && modelFormat(path)) await assets.preview(path);
              else downloadBlob(await p.read(path), path.split('/').at(-1));
            } catch (error) {
              setStatus(error.message);
            }
          });
          if (assets && modelFormat(path)) {
            row.title = 'Preview model';
            const actions = document.createElement('div');
            actions.className = 'project-resource-actions';
            const download = document.createElement('button');
            download.textContent = '↓';
            download.setAttribute('aria-label', 'Download ' + path);
            download.addEventListener('click', async () => {
              try {
                downloadBlob(await p.read(path), path.split('/').at(-1));
              } catch (error) {
                setStatus(error.message);
              }
            });
            actions.append(row, download);
            list.append(actions);
          } else list.append(row);
        }
      }
      refresh.addEventListener('click', () => render().catch((e) => setStatus(e.message)), {
        signal,
      });
      const unsubscribe = host.subscribe(() => render().catch((e) => setStatus(e.message)));
      render().catch((e) => setStatus(e.message));
      return unsubscribe;
    },
  });
  return {
    dispose() {
      disposed = true;
      unsubscribeScenes();
      sceneControl.remove();
      toolbar.classList.remove('has-scene-selector');
      controls.remove();
      panes.unregister('studio.project');
    },
  };
}

/** Avoid traversing compiler/dependency caches while browsing a source project. Reads are unrestricted within its root. */
export function createProjectDirectoryStore(directory) {
  const store = createFileSystemStore(directory);
  return {
    ...store,
    async list({ prefix = '', cursor = null, limit = 1000 } = {}) {
      const objects = [];
      async function walk(folder, path) {
        for await (const [name, handle] of folder.entries()) {
          const key = path + name;
          if (handle.kind === 'directory') {
            if (
              !['.git', '.mooncakes', 'node_modules', '_build'].includes(name) &&
              (prefix.startsWith(key + '/') || key.startsWith(prefix))
            )
              await walk(handle, key + '/');
          } else if (key.startsWith(prefix) && (!cursor || key > cursor)) objects.push({ key });
        }
      }
      await walk(directory, '');
      objects.sort((a, b) => (a.key < b.key ? -1 : a.key > b.key ? 1 : 0));
      return {
        objects: objects.slice(0, limit),
        cursor: objects.length > limit ? objects[limit - 1].key : null,
      };
    },
  };
}
