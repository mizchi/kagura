import { createStorageRegistry } from '../storage/registry.mjs';
import { createDocumentStorage } from '../storage/document.mjs';
import { createIndexedDBStore } from '../storage/indexeddb.mjs';
import { createFileSystemStore } from '../storage/filesystem.mjs';
import { createWorkerStore } from '../storage/worker-http.mjs';
import { reference } from '../storage/common.mjs';

export const DEFAULT_SCENE = Object.freeze({ store: 'indexeddb', key: 'scenes/default.kagura.json' });
export function downloadBlob(blob, filename = 'resource') {
  const url = URL.createObjectURL(blob), link = document.createElement('a');
  link.href = url; link.download = filename.replace(/[\\/\x00-\x1f\x7f]/g, '_');
  document.body.append(link); link.click(); link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
export function createBrowserStorage(editor) {
  const registry = createStorageRegistry(); registry.register('indexeddb', createIndexedDBStore());
  const documents = createDocumentStorage(editor, registry);
  let location = { ...DEFAULT_SCENE }, nextFolder = 1, nextRemote = 1;
  const api = Object.freeze({
    ...registry,
    location: () => ({ ...location }),
    async save(ref = location, expectedRevision = editor.snapshot().revision, options) {
      const result = await documents.save(ref, expectedRevision, options); location = reference(ref); return result;
    },
    async load(ref, expectedRevision = editor.snapshot().revision, options) {
      const result = await documents.load(ref, expectedRevision, options); location = reference(ref); return result;
    },
    async download(source, filename, options) {
      const object = await registry.read(source, options); downloadBlob(object.blob, filename ?? object.key.split('/').at(-1));
      return { size: object.size, type: object.type };
    },
    async connectDirectory(handle) {
      if (!handle && !globalThis.showDirectoryPicker) throw Error('This browser does not support folder access');
      // Called directly from a click to retain transient user activation.
      const directory = handle ?? await showDirectoryPicker({ mode: 'readwrite' });
      const id = 'folder-' + nextFolder++; registry.register(id, createFileSystemStore(directory)); return id;
    },
    async connectWorker({ endpoint, token }) {
      const provider = createWorkerStore({ endpoint, getToken: () => token });
      await provider.list({ limit: 1 });
      const id = 'r2-' + nextRemote++; registry.register(id, provider); return id;
    },
    async restore() {
      try { await api.load(DEFAULT_SCENE, editor.snapshot().revision); return 'Restored saved scene'; }
      catch (error) { if (error.code !== 'not_found') throw error; }
      const legacy = localStorage.getItem('kagura.studio.document.v1');
      if (!legacy) return null;
      let document;
      try { document = JSON.parse(legacy); } catch { throw Error('Saved scene contains invalid JSON'); }
      const reply = editor.dispatch({ expectedRevision: editor.snapshot().revision, commands: [{ op: 'document.replace', document }] });
      if (!reply.ok) throw Error(reply.error.message);
      await api.save(DEFAULT_SCENE, reply.snapshot.revision);
      // Remove legacy only after the IndexedDB commit succeeded.
      localStorage.removeItem('kagura.studio.document.v1');
      return 'Restored saved scene · migrated to IndexedDB';
    },
  });
  return api;
}
