import { StorageError, checkSignal, metadata, listOptions } from './common.mjs';

export function createIndexedDBStore({ name = 'kagura.studio.resources.v1', indexedDB = globalThis.indexedDB } = {}) {
  let connection;
  function open() {
    if (!connection) connection = new Promise((resolve, reject) => {
      if (!indexedDB) { reject(new StorageError('unsupported', 'IndexedDB is unavailable')); return; }
      const request = indexedDB.open(name, 1);
      request.onupgradeneeded = () => request.result.createObjectStore('objects', { keyPath: 'key' });
      request.onerror = () => reject(request.error);
      request.onblocked = () => reject(new StorageError('io', 'IndexedDB upgrade blocked by another tab'));
      request.onsuccess = () => { const db = request.result; db.onversionchange = () => db.close(); resolve(db); };
    });
    return connection;
  }
  async function transaction(mode, signal, action) {
    checkSignal(signal); const db = await open(); checkSignal(signal);
    return new Promise((resolve, reject) => {
      const tx = db.transaction('objects', mode), store = tx.objectStore('objects');
      let result, failure;
      const cancel = () => tx.abort(); signal?.addEventListener('abort', cancel, { once: true });
      const cleanup = () => signal?.removeEventListener('abort', cancel);
      tx.oncomplete = () => { cleanup(); resolve(result); };
      tx.onabort = tx.onerror = () => { cleanup(); reject(failure ?? tx.error ?? new StorageError('canceled', 'Storage transaction canceled')); };
      try { action(store, value => { result = value; }, error => { failure = error; tx.abort(); }); }
      catch (error) { failure = error; tx.abort(); }
    });
  }
  return Object.freeze({
    capabilities: { conditionalWrite: true },
    read(key, { signal } = {}) { return transaction('readonly', signal, (store, done, fail) => {
      const request = store.get(key); request.onsuccess = () => request.result ? done(request.result) : fail(new StorageError('not_found', 'Resource not found: ' + key));
    }); },
    write(key, blob, { ifMatch, signal } = {}) { return transaction('readwrite', signal, (store, done, fail) => {
      const request = store.get(key);
      request.onsuccess = () => {
        if (ifMatch !== undefined && (request.result?.etag ?? null) !== ifMatch) { fail(new StorageError('conflict', 'Stored resource changed')); return; }
        const object = { key, blob, size: blob.size, type: blob.type || 'application/octet-stream', etag: '"' + crypto.randomUUID() + '"', modified: new Date().toISOString() };
        store.put(object); done(metadata(object));
      };
    }); },
    remove(key, { signal } = {}) { return transaction('readwrite', signal, (store, done) => { store.delete(key); done(undefined); }); },
    list(options) {
      const { prefix, cursor, limit, signal } = listOptions(options);
      return transaction('readonly', signal, (store, done) => {
        const objects = [], request = store.openCursor();
        request.onsuccess = () => {
          const entry = request.result;
          if (!entry) { done({ objects, cursor: null }); return; }
          if (entry.key.startsWith(prefix) && (!cursor || entry.key > cursor)) {
            if (objects.length === limit) { done({ objects, cursor: objects.at(-1).key }); return; }
            objects.push(metadata(entry.value));
          }
          entry.continue();
        };
      });
    },
    async dispose() { if (connection) (await connection).close(); connection = undefined; },
  });
}
