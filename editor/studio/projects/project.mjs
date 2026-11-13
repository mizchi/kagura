import { validateSettings } from './settings.mjs';
import { decodeSceneFile, encodeMoonScene } from '../scene/moonbit.mjs';
/** Portable project contract. Paths are relative to the directory containing the .kgrprj. */
export function projectPath(value) {
  if (
    typeof value !== 'string' ||
    value.length > 512 ||
    !value ||
    /[\\:%?#\x00-\x1f\x7f]/.test(value) ||
    value.split('/').some((p) => !p || p === '.' || p === '..')
  )
    throw Error('Invalid project-relative path');
  return value;
}
function object(value, keys) {
  if (
    !value ||
    typeof value !== 'object' ||
    Array.isArray(value) ||
    Object.keys(value).some((k) => !keys.includes(k))
  )
    throw Error('Invalid project fields');
}
export function validateProject(input) {
  object(input, [
    'format',
    'version',
    'name',
    'id',
    'game',
    'save',
    'runtime',
    'build',
    'display',
    'sceneSchema',
    'editor',
    'scene',
    'scenes',
    'entryScene',
    'resources',
    'masterData',
    'sceneFlow',
  ]);
  if (input.format !== 'kagura.project' || input.version !== 1)
    throw Error('Unsupported .kgrprj format/version');
  if (typeof input.name !== 'string' || !input.name.trim() || input.name.length > 120)
    throw Error('Invalid project name');
  if (input.editor !== undefined) {
    object(input.editor, ['id', 'entry', 'apiVersion']);
    if (typeof input.editor.id !== 'string' || !/^[a-z][a-z0-9.-]{0,79}$/.test(input.editor.id))
      throw Error('Invalid editor ID');
    if (input.editor.entry !== undefined && !projectPath(input.editor.entry).endsWith('.mjs'))
      throw Error('Editor entry must be a bundled .mjs module');
  }
  const normalized = structuredClone(input);
  if (input.scenes !== undefined || input.entryScene !== undefined) {
    object(input.scenes, Object.keys(input.scenes ?? {}));
    const paths = new Set();
    for (const [id, path] of Object.entries(input.scenes)) {
      if (!/^[a-zA-Z][a-zA-Z0-9_.-]{0,79}$/.test(id)) throw Error('Invalid scene ID');
      projectPath(path);
      if (paths.has(path)) throw Error('Duplicate scene path');
      paths.add(path);
    }
    if (typeof input.entryScene !== 'string' || !Object.hasOwn(input.scenes, input.entryScene))
      throw Error('Unknown entry scene');
    normalized.scene = input.scenes[input.entryScene];
    if (input.scene !== undefined && input.scene !== normalized.scene)
      throw Error('Scene must match entryScene');
  } else projectPath(input.scene);
  object(input.resources, Object.keys(input.resources ?? {}));
  for (const [id, path] of Object.entries(input.resources)) {
    if (!/^[a-zA-Z][a-zA-Z0-9_.-]{0,79}$/.test(id)) throw Error('Invalid resource ID');
    projectPath(path);
  }
  if (input.masterData !== undefined) {
    object(input.masterData, ['adapter', 'resource']);
    if (
      !projectPath(input.masterData.adapter).endsWith('.mjs') ||
      !Object.hasOwn(input.resources, input.masterData.resource)
    ) throw Error('Invalid master data declaration');
  }
  if (input.sceneFlow !== undefined) {
    object(input.sceneFlow, ['resource']);
    const id = input.sceneFlow.resource;
    if (typeof id !== 'string' || !Object.hasOwn(input.resources, id) ||
      !input.resources[id].endsWith('.json')) throw Error('Invalid scene flow declaration');
  }
  validateSettings(input, projectPath);
  return normalized;
}
export async function openProject(store, path) {
  projectPath(path);
  if (!path.endsWith('.kgrprj')) throw Error('Choose a .kgrprj file');
  const blob = (await store.read(path)).blob;
  if (blob.size > 1024 * 1024) throw Error('Project manifest exceeds 1 MiB');
  const manifest = validateProject(JSON.parse(await blob.text()));
  const prefix = path.slice(0, path.lastIndexOf('/') + 1),
    urls = new Map(),
    sourceRevisions = new Map(),
    resourceDrafts = new Map(),
    ownedURLs = new Set();
  let closed = false;
  let savingResources = false;
  function scoped(path) {
    if (closed) throw Error('Project is closed');
    return prefix + projectPath(path);
  }
  function scenePath(id) {
    if (id === undefined) return manifest.scene;
    if (!manifest.scenes || !Object.hasOwn(manifest.scenes, id)) throw Error('Unknown scene ID');
    return manifest.scenes[id];
  }
  const project = {
    reopen: () => openProject(store, path),
    manifest,
    writable: typeof store.write === 'function',
    async read(path) {
      scoped(path);
      if (resourceDrafts.has(path)) return resourceDrafts.get(path).blob;
      return (await store.read(scoped(path))).blob;
    },
    async readScene(id) {
      const b = await project.read(scenePath(id));
      if (b.size > 4 * 1024 * 1024) throw Error('Scene exceeds 4 MiB');
      const document = decodeSceneFile(scenePath(id), await b.text());
      sourceRevisions.set(scenePath(id), JSON.stringify(document));
      return document;
    },
    async encodeScene(scene, id) {
      const path = scenePath(id);
      let text = JSON.stringify(scene, null, 2),
        type = 'application/json';
      if (path.endsWith('.mbt')) {
        const blob = await project.read(path);
        if (blob.size > 4 * 1024 * 1024) throw Error('Scene exceeds 4 MiB');
        const source = await blob.text();
        const revision = sourceRevisions.get(path);
        if (revision !== undefined && JSON.stringify(decodeSceneFile(path, source)) !== revision)
          throw Error('Scene source changed on disk; reopen before saving');
        text = encodeMoonScene(scene, { source });
        type = 'text/plain';
      }
      const blob = new Blob([text], { type });
      if (blob.size > 4 * 1024 * 1024) throw Error('Scene exceeds 4 MiB');
      return { path, blob };
    },
    async saveScene(scene, id) {
      if (!project.writable) throw Error('Project folder is read-only');
      const { path, blob } = await project.encodeScene(scene, id);
      await store.write(scoped(path), blob);
      sourceRevisions.set(path, JSON.stringify(scene));
    },
    async list() {
      scoped(manifest.scene);
      const paths = [];
      let cursor = null;
      do {
        const page = await store.list({ prefix, limit: 1000, cursor });
        for (const item of page.objects)
          if (item.key.startsWith(prefix)) paths.push(item.key.slice(prefix.length));
        cursor = page.cursor;
      } while (cursor);
      return paths;
    },
    async url(path, type) {
      const key = scoped(path);
      if (!urls.has(key)) {
        const revision = resourceDrafts.get(path)?.revision;
        const blob = await project.read(path);
        scoped(path);
        // A draft may change while a folder read is pending. Never cache that
        // older read as the URL for a later Play.
        if (revision !== resourceDrafts.get(path)?.revision) return project.url(path, type);
        if (urls.has(key)) return urls.get(key);
        const mime =
          type ??
          (path.endsWith('.mjs')
            ? 'text/javascript'
            : path.endsWith('.json')
              ? 'application/json'
              : blob.type);
        urls.set(key, URL.createObjectURL(new Blob([blob], { type: mime })));
        ownedURLs.add(urls.get(key));
      }
      return urls.get(key);
    },
    async resource(id) {
      if (!Object.hasOwn(manifest.resources, id)) throw Error('Unknown resource: ' + id);
      return project.read(manifest.resources[id]);
    },
    async readResource(id) {
      const blob = await project.resource(id), path = manifest.resources[id];
      scoped(path);
      if (!resourceDrafts.has(path)) {
        const base = await blob.text();
        scoped(path);
        // Another read or stage may have completed while the Blob was decoded.
        if (!resourceDrafts.has(path))
          resourceDrafts.set(path, {blob, base, revision: 0, dirty: false});
      }
      const r = resourceDrafts.get(path);
      return {blob: r.blob, revision: r.revision};
    },
    async stageResource(id, blob, expectedRevision) {
      if (!(blob instanceof Blob) || blob.size > 4 * 1024 * 1024)
        throw Error('Resource exceeds 4 MiB');
      await project.readResource(id);
      const path = manifest.resources[id], r = resourceDrafts.get(path);
      scoped(path);
      if (r.revision !== expectedRevision) throw Error('Stale resource revision');
      r.blob = blob;
      r.revision++;
      r.dirty = true;
      urls.delete(scoped(path));
      return r.revision;
    },
    async saveResources() {
      if (!project.writable) throw Error('Project folder is read-only');
      if (savingResources) throw Error('Resource save is already in progress');
      savingResources = true;
      try {
        const pending = [...resourceDrafts]
          .filter(([, r]) => r.dirty)
          .map(([path, r]) => ({path, record: r, revision: r.revision, blob: r.blob, base: r.base}));
        for (const p of pending) {
          const disk = (await store.read(scoped(p.path))).blob;
          if (await disk.text() !== p.base)
            throw Error('Resource changed on disk; reopen before saving');
        }
        for (const p of pending) {
          await store.write(scoped(p.path), p.blob);
          p.record.base = await p.blob.text();
          if (p.record.revision === p.revision) p.record.dirty = false;
        }
      } finally {
        savingResources = false;
      }
    },
    dispose() {
      closed = true;
      for (const url of ownedURLs) URL.revokeObjectURL(url);
      urls.clear();
      ownedURLs.clear();
      resourceDrafts.clear();
    },
  };
  return Object.freeze(project);
}
