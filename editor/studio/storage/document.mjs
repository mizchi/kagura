import { StorageError, reference, checkSignal } from './common.mjs';
const MAX_SCENE_BYTES = 4 * 1024 * 1024;

/** Persisted object versions and editor revisions are independent concurrency boundaries. */
export function createDocumentStorage(editor, storage) {
  const versions = new Map(); let saves = Promise.resolve();
  function snapshot(expectedRevision) {
    const current = editor.snapshot();
    if (!Number.isInteger(expectedRevision) || current.revision !== expectedRevision) throw new StorageError('conflict', 'Editor changed; read a new snapshot');
    return current;
  }
  return Object.freeze({
    save(location, expectedRevision, options = {}) {
      let ref, captured;
      try { ref = reference(location); captured = snapshot(expectedRevision); } catch (error) { return Promise.reject(error); }
      const task = saves.then(async () => {
        const identity = JSON.stringify(ref);
        const supportsConditions = storage.stores().find(p => p.id === ref.store)?.capabilities.conditionalWrite;
        const object = await storage.write(ref, new Blob([JSON.stringify(captured.document)], { type: 'application/json' }), {
          ...options, ifMatch: supportsConditions ? versions.get(identity) ?? null : undefined,
        });
        versions.set(identity, object.etag);
        return { location: ref, object, revision: captured.revision };
      });
      saves = task.catch(() => {}); return task;
    },
    async load(location, expectedRevision, options = {}) {
      const ref = reference(location); snapshot(expectedRevision);
      const object = await storage.read(ref, options);
      if (object.blob.size > MAX_SCENE_BYTES) throw new StorageError('too_large', 'Scene exceeds 4 MiB');
      let document;
      try { document = JSON.parse(await object.blob.text()); } catch { throw new StorageError('invalid', 'Invalid scene JSON'); }
      checkSignal(options.signal);
      const reply = editor.dispatch({ expectedRevision, commands: [{ op: 'document.replace', document }] });
      if (!reply.ok) throw new StorageError(reply.error.code, reply.error.message);
      versions.set(JSON.stringify(ref), object.etag);
      return reply;
    },
  });
}
