import { MAX_OBJECT_BYTES, StorageError, key as validateKey, listOptions } from '../storage/common.mjs';

const API_PATH = '/api/storage/objects';
function metadata(object) {
  return { key: object.key, size: object.size, type: object.httpMetadata?.contentType ?? 'application/octet-stream', etag: object.httpEtag, modified: object.uploaded.toISOString() };
}
async function authorize(request, secret) {
  if (!secret) return false;
  // Hash to fixed-size bytes before comparing. This endpoint is one private workspace.
  const digest = value => crypto.subtle.digest('SHA-256', new TextEncoder().encode(value));
  const [actual, expected] = await Promise.all([digest(request.headers.get('authorization') ?? ''), digest('Bearer ' + secret)]);
  const a = new Uint8Array(actual), b = new Uint8Array(expected); let difference = 0;
  for (let i = 0; i < a.length; i++) difference |= a[i] ^ b[i];
  return difference === 0;
}
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname !== API_PATH) {
      if (url.pathname.startsWith('/api/')) return new Response('Not found', { status: 404 });
      return env.ASSETS ? env.ASSETS.fetch(request) : new Response('Not found', { status: 404 });
    }
    const origin = request.headers.get('Origin');
    const allowed = !origin || origin === url.origin || (env.ALLOWED_ORIGINS ?? '').split(',').map(s => s.trim()).includes(origin);
    const headers = new Headers({ 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff', Vary: 'Origin' });
    if (allowed && origin) {
      headers.set('Access-Control-Allow-Origin', origin);
      headers.set('Access-Control-Expose-Headers', 'ETag, Content-Type, Content-Length, Last-Modified, Content-Disposition');
    }
    function error(status, code) { return Response.json({ error: { code } }, { status, headers }); }
    if (!allowed) return error(403, 'permission');
    if (request.method === 'OPTIONS') {
      headers.set('Access-Control-Allow-Methods', 'GET, PUT, DELETE, OPTIONS');
      headers.set('Access-Control-Allow-Headers', 'Authorization, Content-Type, If-Match, If-None-Match');
      return new Response(null, { status: 204, headers });
    }
    if (!await authorize(request, env.STORAGE_TOKEN)) return error(401, 'permission');
    if (!env.RESOURCES) return error(503, 'unavailable');
    try {
      if (['GET', 'PUT', 'DELETE'].includes(request.method) === false) return error(405, 'method');
      for (const parameter of url.searchParams.keys()) if (!['key', 'prefix', 'cursor', 'limit'].includes(parameter)) throw new StorageError('invalid', 'Unknown query parameter');
      const resourceKey = url.searchParams.get('key');
      if (resourceKey === null) {
        if (request.method !== 'GET') return error(400, 'invalid');
        const { prefix, cursor, limit } = listOptions({ prefix: url.searchParams.get('prefix') ?? '', cursor: url.searchParams.get('cursor'), limit: Number(url.searchParams.get('limit') ?? 100) });
        const result = await env.RESOURCES.list({ prefix, limit, ...(cursor ? { cursor } : {}), include: ['httpMetadata'] });
        return Response.json({ objects: result.objects.map(metadata), cursor: result.truncated ? result.cursor : null }, { headers });
      }
      validateKey(resourceKey);
      if (request.method === 'GET') {
        const object = await env.RESOURCES.get(resourceKey);
        if (!object) return error(404, 'not_found');
        headers.set('Content-Type', object.httpMetadata?.contentType ?? 'application/octet-stream');
        headers.set('ETag', object.httpEtag); headers.set('Content-Length', String(object.size));
        headers.set('Last-Modified', object.uploaded.toUTCString());
        const filename = encodeURIComponent(resourceKey.split('/').at(-1)).replace(/[!'()*]/g, c => '%' + c.charCodeAt(0).toString(16));
        headers.set('Content-Disposition', "attachment; filename*=UTF-8''" + filename);
        return new Response(object.body, { headers });
      }
      if (request.method === 'DELETE') { await env.RESOURCES.delete(resourceKey); return new Response(null, { status: 204, headers }); }
      const match = request.headers.get('If-Match'), noneMatch = request.headers.get('If-None-Match');
      if (match && noneMatch || noneMatch !== null && noneMatch !== '*') return error(400, 'invalid');
      if (Number(request.headers.get('content-length')) > MAX_OBJECT_BYTES) return error(413, 'too_large');
      // A bounded body is independent of the client-supplied Content-Length.
      const reader = request.body?.getReader(); const parts = []; let size = 0;
      if (reader) {
        try { while (true) { const next = await reader.read(); if (next.done) break; size += next.value.byteLength; if (size > MAX_OBJECT_BYTES) return error(413, 'too_large'); parts.push(next.value); } }
        finally { await reader.cancel(); reader.releaseLock(); }
      }
      const body = new Blob(parts);
      const onlyIf = new Headers(); if (match) onlyIf.set('If-Match', match); if (noneMatch) onlyIf.set('If-None-Match', noneMatch);
      const object = await env.RESOURCES.put(resourceKey, body.stream(), { onlyIf, httpMetadata: { contentType: request.headers.get('Content-Type') ?? 'application/octet-stream' } });
      if (!object) return error(412, 'conflict');
      return Response.json(metadata(object), { headers });
    } catch (cause) {
      return error(cause instanceof StorageError ? 400 : 500, cause instanceof StorageError ? cause.code : 'io');
    }
  },
};
