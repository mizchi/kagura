import { Miniflare, convertV4MiniflareOptions } from 'miniflare';

/** Isolated workerd/R2 for tests; no production account or bucket access. */
export function createTestWorker(origin = 'http://localhost:5190') {
  return new Miniflare(convertV4MiniflareOptions({ host: '127.0.0.1', port: 0, workers: [{
    name: 'storage', modulesRoot: new URL('..', import.meta.url).pathname,
    modules: ['worker/index.mjs', 'storage/common.mjs'].map(path => ({ type: 'ESModule', path: new URL('../' + path, import.meta.url).pathname })),
    compatibilityDate: '2026-09-10', r2Buckets: ['RESOURCES'],
    bindings: { STORAGE_TOKEN: 'test-token', ALLOWED_ORIGINS: origin },
  }] }));
}
