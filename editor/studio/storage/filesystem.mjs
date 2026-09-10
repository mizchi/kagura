import { StorageError, checkSignal, metadata, listOptions } from './common.mjs';

/** A user-picked directory or OPFS directory. External OS writes cannot be made conditional. */
export function createFileSystemStore(directory) {
  async function parent(key, create) {
    const parts = key.split('/'), name = parts.pop(); let folder = directory;
    for (const part of parts) folder = await folder.getDirectoryHandle(part, { create });
    return { folder, name };
  }
  async function read(key, { signal } = {}) {
    checkSignal(signal); const { folder, name } = await parent(key, false);
    const handle = await folder.getFileHandle(name), blob = await handle.getFile(); checkSignal(signal);
    return { key, blob, size: blob.size, type: blob.type || 'application/octet-stream', etag: null, modified: new Date(blob.lastModified).toISOString() };
  }
  return Object.freeze({
    capabilities: { conditionalWrite: false }, read,
    async write(key, blob, { signal, ifMatch } = {}) {
      if (ifMatch !== undefined) throw new StorageError('unsupported', 'File system cannot write conditionally');
      checkSignal(signal); const { folder, name } = await parent(key, true); checkSignal(signal);
      const handle = await folder.getFileHandle(name, { create: true });
      const stream = await handle.createWritable();
      try { checkSignal(signal); await stream.write(blob); checkSignal(signal); await stream.close(); }
      catch (error) { await stream.abort().catch(() => {}); throw error; }
      return metadata(await read(key));
    },
    async remove(key, { signal } = {}) {
      checkSignal(signal);
      try { const { folder, name } = await parent(key, false); await folder.removeEntry(name); }
      catch (error) { if (error.name !== 'NotFoundError') throw error; }
    },
    async list(options) {
      const { prefix, cursor, limit, signal } = listOptions(options), objects = [];
      async function walk(folder, path) {
        for await (const [name, handle] of folder.entries()) {
          checkSignal(signal); const key = path + name;
          if (handle.kind === 'directory') { if (prefix.startsWith(key + '/') || key.startsWith(prefix)) await walk(handle, key + '/'); }
          else if (key.startsWith(prefix) && (!cursor || key > cursor)) objects.push(metadata(await read(key, { signal })));
        }
      }
      await walk(directory, ''); objects.sort((a, b) => a.key < b.key ? -1 : a.key > b.key ? 1 : 0);
      return { objects: objects.slice(0, limit), cursor: objects.length > limit ? objects[limit - 1].key : null };
    },
  });
}
