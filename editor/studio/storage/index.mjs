export { createStorageRegistry } from './registry.mjs';
export { createDocumentStorage } from './document.mjs';
export { createIndexedDBStore } from './indexeddb.mjs';
export { createFileSystemStore } from './filesystem.mjs';
export { createWorkerStore } from './worker-http.mjs';
export { StorageError, MAX_OBJECT_BYTES } from './common.mjs';
