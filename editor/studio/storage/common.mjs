export const MAX_OBJECT_BYTES = 64 * 1024 * 1024;
export class StorageError extends Error {
  constructor(code, message) { super(message); this.name = 'StorageError'; this.code = code; }
}
export function check(condition, message) { if (!condition) throw new StorageError('invalid', message); }
export function key(value) {
  check(typeof value === 'string' && value.length > 0 && value.length <= 512 && !/[\\\x00-\x1f\x7f]/.test(value) && value.split('/').every(part => part && part !== '.' && part !== '..'), 'Invalid resource key');
  return value;
}
export function reference(value) {
  check(value && typeof value === 'object' && Object.keys(value).every(k => ['store', 'key'].includes(k)), 'Expected storage reference');
  check(typeof value.store === 'string' && /^[a-zA-Z0-9_.-]{1,80}$/.test(value.store), 'Invalid store ID');
  key(value.key); return { store: value.store, key: value.key };
}
export function listOptions({ prefix = '', cursor = null, limit = 100, signal } = {}) {
  check(typeof prefix === 'string' && prefix.length <= 512, 'Invalid prefix');
  if (prefix) key(prefix.endsWith('/') ? prefix.slice(0, -1) : prefix);
  check(cursor === null || typeof cursor === 'string' && cursor.length <= 4096, 'Invalid cursor');
  check(Number.isInteger(limit) && limit >= 1 && limit <= 1000, 'List limit must be 1-1000');
  return { prefix, cursor, limit, signal };
}
export function checkSignal(signal) { if (signal?.aborted) throw new StorageError('canceled', 'Storage operation canceled'); }
export function condition(value) { check(value === undefined || value === null || typeof value === 'string' && value.length > 0 && value.length <= 256 && !/[\r\n]/.test(value), 'Invalid write condition'); }
export function normalize(error) {
  if (error instanceof StorageError) return error;
  const code = ({ NotFoundError: 'not_found', NotAllowedError: 'permission', SecurityError: 'permission', AbortError: 'canceled', QuotaExceededError: 'quota' })[error.name] ?? error.code ?? 'io';
  return new StorageError(code, error.message ?? 'Storage operation failed');
}
export async function responseBlob(response, signal) {
  if (Number(response.headers.get('content-length')) > MAX_OBJECT_BYTES) throw new StorageError('too_large', 'Resource exceeds 64 MiB');
  const reader = response.body?.getReader();
  if (!reader) return new Blob([], { type: response.headers.get('content-type') ?? '' });
  const chunks = []; let size = 0;
  try {
    while (true) {
      checkSignal(signal);
      const { done, value } = await reader.read(); if (done) break;
      size += value.byteLength;
      if (size > MAX_OBJECT_BYTES) throw new StorageError('too_large', 'Resource exceeds 64 MiB');
      chunks.push(value);
    }
    return new Blob(chunks, { type: response.headers.get('content-type') ?? 'application/octet-stream' });
  } finally { await reader.cancel(); reader.releaseLock(); }
}
export function metadata(object) {
  const { key, size, type, etag, modified } = object;
  return { key, size, type, etag, modified };
}
