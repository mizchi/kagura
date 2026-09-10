import { StorageError, check, responseBlob } from './common.mjs';

/** The endpoint may be backed by R2 or an S3 adapter; signing/authentication stays server-side. */
export function createWorkerStore({ endpoint, getToken = () => '', fetch: request = globalThis.fetch }) {
  const base = new URL(endpoint);
  check(['https:', 'http:'].includes(base.protocol) && !base.username && !base.password && !base.search && !base.hash, 'Invalid Worker endpoint');
  async function send(verb, parameters, { signal, blob, ifMatch } = {}) {
    const url = new URL(base); for (const [key, value] of Object.entries(parameters)) if (value !== null && value !== undefined) url.searchParams.set(key, value);
    const headers = new Headers(), token = await getToken();
    if (token) headers.set('Authorization', 'Bearer ' + token);
    if (blob) headers.set('Content-Type', blob.type || 'application/octet-stream');
    if (ifMatch === null) headers.set('If-None-Match', '*');
    else if (ifMatch !== undefined) headers.set('If-Match', ifMatch);
    const response = await request(url, { method: verb, headers, body: blob, signal, credentials: 'omit', redirect: 'error' });
    if (!response.ok) {
      const code = ({ 400: 'invalid', 401: 'permission', 403: 'permission', 404: 'not_found', 409: 'conflict', 412: 'conflict', 413: 'too_large' })[response.status] ?? 'io';
      throw new StorageError(code, 'Worker storage request failed: ' + response.status);
    }
    return response;
  }
  return Object.freeze({
    capabilities: { conditionalWrite: true },
    async read(key, options = {}) {
      const response = await send('GET', { key }, options), blob = await responseBlob(response, options.signal);
      return { key, blob, size: blob.size, type: blob.type, etag: response.headers.get('etag'), modified: response.headers.get('last-modified') };
    },
    async write(key, blob, options = {}) { return (await send('PUT', { key }, { ...options, blob })).json(); },
    async remove(key, options = {}) { await send('DELETE', { key }, options); },
    async list({ prefix = '', cursor, limit = 100, signal } = {}) { return (await send('GET', { prefix, cursor, limit }, { signal })).json(); },
  });
}
