import { MAX_OBJECT_BYTES, StorageError, check, reference, key, condition, listOptions, normalize, checkSignal, responseBlob } from './common.mjs';

/** Providers own I/O. The registry owns location validation and dispatch, never editor state. */
export function createStorageRegistry() {
  const providers = new Map();
  function provider(id) { const value = providers.get(id); if (!value) throw new StorageError('not_found', 'Unknown store: ' + id); return value; }
  async function run(signal, action) { try { checkSignal(signal); return await action(); } catch (error) { throw normalize(error); } }
  const storage = {
    register(id, value) {
      reference({ store: id, key: 'check' });
      check(value && ['read', 'write', 'remove', 'list'].every(name => typeof value[name] === 'function'), 'Invalid storage provider');
      check(!providers.has(id), 'Store already registered: ' + id);
      providers.set(id, value);
    },
    stores: () => [...providers].map(([id, provider]) => ({ id, capabilities: { ...provider.capabilities } })),
    read(source, options = {}) { return run(options.signal, async () => {
      if (source && Object.hasOwn(source, 'url')) {
        check(Object.keys(source).length === 1, 'Expected URL source');
        const url = new URL(source.url);
        check(['https:', 'http:'].includes(url.protocol) && !url.username && !url.password, 'Expected HTTP(S) URL');
        const response = await fetch(url, { signal: options.signal, credentials: 'omit' });
        if (!response.ok) throw new StorageError(response.status === 404 ? 'not_found' : 'io', 'Resource request failed: ' + response.status);
        const blob = await responseBlob(response, options.signal);
        return { blob, key: decodeURIComponent(url.pathname.split('/').at(-1)) || 'resource', size: blob.size, type: blob.type, etag: response.headers.get('etag'), modified: response.headers.get('last-modified') };
      }
      const ref = reference(source); return provider(ref.store).read(ref.key, options);
    }); },
    write(location, blob, options = {}) { return run(options.signal, () => {
      const ref = reference(location); check(blob instanceof Blob, 'Expected Blob');
      if (blob.size > MAX_OBJECT_BYTES) throw new StorageError('too_large', 'Resource exceeds 64 MiB');
      condition(options.ifMatch);
      const target = provider(ref.store);
      if (options.ifMatch !== undefined && !target.capabilities.conditionalWrite) throw new StorageError('unsupported', 'This store cannot write conditionally');
      return target.write(ref.key, blob, options);
    }); },
    remove(location, options = {}) { return run(options.signal, () => { const ref = reference(location); return provider(ref.store).remove(ref.key, options); }); },
    list(id, options = {}) { return run(options.signal, () => provider(id).list(listOptions(options))); },
    async copy(source, target, options = {}) { const object = await storage.read(source, options); return storage.write(target, object.blob, options); },
    async dispose() { for (const value of providers.values()) await value.dispose?.(); providers.clear(); },
  };
  return Object.freeze(storage);
}
