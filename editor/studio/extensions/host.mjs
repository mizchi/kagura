import { assertProjectCompatibility, runtimeEntry } from '../projects/settings.mjs';
import { downloadBlob } from '../web/storage.mjs';
import * as core from './core.mjs';
/** Generic editing is built in. A game extension may add only panes or replace selected editing modes. */
export function createExtensionHost(context, catalog) {
  const base = core.activate(context);
  let current = base,
    activeModule = core,
    project,
    sceneId;
  let drafts = new Map();
  const listeners = new Set();
  const notifyState = () => {
    for (const listener of listeners) listener();
  };
  const validate = (module, doc, manifest = project?.manifest) =>
    (module.validateDocument ?? core.validateDocument)(doc, manifest);
  async function prepare(id, resourceProject) {
    let module;
    if (resourceProject?.manifest.editor?.entry) {
      const url = await resourceProject.url(
        resourceProject.manifest.editor.entry,
        'text/javascript',
      );
      module = await import(/* @vite-ignore */ url);
    } else {
      if (!catalog[id]) throw Error('Unknown editor extension: ' + id);
      module = await catalog[id]();
    }
    if (
      module.apiVersion !== 1 ||
      module.id !== id ||
      typeof module.activate !== 'function' ||
      (module.validateDocument !== undefined && typeof module.validateDocument !== 'function')
    )
      throw Error('Invalid editor extension API');
    if (resourceProject) assertProjectCompatibility(resourceProject.manifest, module);
    return module;
  }
  function release() {
    current?.dispose();
    current = base;
    activeModule = core;
    project?.dispose();
    project = undefined;
    sceneId = undefined;
    drafts.clear();
    notifyState();
  }
  async function activate(module, next) {
    const additions = await module.activate({
      ...context,
      base,
      project: next,
      notifyState,
      getSceneId: () => sceneId,
      getSceneDocument: readScene,
    });
    if (!additions || typeof additions.dispose !== 'function')
      throw Error('Editor extension must return dispose()');
    if (
      ['play', 'stop', 'playing', 'canPlay', 'debug', 'hierarchy'].some(
        (key) => additions[key] !== undefined && typeof additions[key] !== 'function',
      ) ||
      (additions.play && (!additions.stop || !additions.playing))
    ) {
      additions.dispose();
      throw Error('Runtime capability requires play(), stop() and playing()');
    }
    current = { ...base, ...additions };
    activeModule = module;
    project = next;
    notifyState();
  }
  async function readScene(id) {
    if (id === sceneId) return current.readDocument();
    return structuredClone(drafts.get(id) ?? (await project.readScene(id)));
  }
  async function open(next, override, selected = next.manifest.entryScene) {
    const revision = context.editor.snapshot().revision;
    try {
      if (next.manifest.scenes && !Object.hasOwn(next.manifest.scenes, selected))
        throw Error('Unknown selected scene');
      const module = await prepare(next.manifest.editor?.id ?? 'kagura.scene', next),
        doc = validate(module, override ?? (await next.readScene(selected)), next.manifest);
      if (context.editor.snapshot().revision !== revision)
        throw Error('Scene changed while project was loading');
      const files = new Set(Object.values(next.manifest.resources));
      const entry = runtimeEntry(next.manifest);
      if (entry) files.add(entry);
      for (const path of files) await next.read(path);
      if (context.editor.snapshot().revision !== revision)
        throw Error('Scene changed while resources were loading');
      release();
      try {
        sceneId = selected;
        await activate(module, next);
        await current.importScene(doc, revision);
        context.editor.clearHistory(context.editor.snapshot().revision);
      } catch (error) {
        release();
        throw error;
      }
    } catch (error) {
      next.dispose();
      throw error;
    }
  }
  return Object.freeze({
    subscribe(listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
    transport: () => ({
      available: !!project,
      canPlay: !!project && typeof current.play === 'function' && (current.canPlay?.() ?? true),
      playing: !!project && (current.playing?.() ?? false),
      debugging: !!current.debug?.(),
      paused: current.debug?.()?.snapshot().paused ?? false,
    }),
    hierarchy: () => current.hierarchy?.(),
    debug(method, ...args) {
      const runtime = current.debug?.();
      if (!runtime || !['snapshot', 'pause', 'resume', 'step', 'replace'].includes(method))
        throw Error('Runtime debugger is not available');
      try { return runtime[method](...args); }
      finally { if (method !== 'snapshot') notifyState(); }
    },
    async play() {
      if (!project || !current.play || current.canPlay?.() === false)
        throw Error('Project runtime is not available');
      try {
        await current.play();
      } finally {
        notifyState();
      }
    },
    async stop() {
      try {
        await current.stop?.();
      } finally {
        notifyState();
      }
    },
    async edit() {
      try {
        await current.stop?.();
        await current.open();
      } finally {
        notifyState();
      }
    },
    async useBuiltin(id) {
      if (activeModule?.id === id && !project) return current;
      const module = await prepare(id);
      release();
      await activate(module);
      return current;
    },
    openProject: open,
    async reload() {
      if (!project) throw Error('Open a project first');
      const doc = current.readDocument();
      const savedDrafts = new Map(drafts);
      await open(await project.reopen(), doc, sceneId);
      drafts = savedDrafts;
    },
    sceneId: () => sceneId,
    async selectScene(id) {
      if (!project?.manifest.scenes || !Object.hasOwn(project.manifest.scenes, id))
        throw Error('Unknown scene ID');
      if (id === sceneId) return;
      const revision = context.editor.snapshot().revision;
      const next = validate(activeModule, await readScene(id));
      if (context.editor.snapshot().revision !== revision)
        throw Error('Scene changed while loading');
      const previous = current.readDocument();
      await current.importScene(next, revision);
      context.editor.clearHistory(context.editor.snapshot().revision);
      current.closeView?.();
      drafts.set(sceneId, previous);
      sceneId = id;
      notifyState();
    },
    active: () => current.active(),
    accepts(doc) {
      try {
        validate(activeModule, doc);
        return true;
      } catch {
        return false;
      }
    },
    showGeneric() {
      current.closeView?.();
      notifyState();
    },
    open: () => current.open(),
    frame: () => current.frame(),
    view: (name) => current.view(name),
    importScene: (doc, revision) => current.importScene(validate(activeModule, doc), revision),
    exportScene: () => current.exportScene(),
    async save() {
      if (!project) return false;
      if (!project.writable) {
        if (project.encodeScene) {
          const file = await project.encodeScene(current.readDocument(), sceneId);
          downloadBlob(file.blob, file.path.split('/').at(-1));
        } else current.exportScene();
        return 'Exported scene · フォルダ読込は読み取り専用';
      }
      drafts.set(sceneId, current.readDocument());
      const documents = [...drafts].map(([id, doc]) => [id, validate(activeModule, doc)]);
      for (const [id, doc] of documents) await project.saveScene(doc, id);
      return 'Saved project · ' + project.manifest.name;
    },
    project: () => project,
    document: () => current.readDocument(),
    dispose: release,
  });
}
