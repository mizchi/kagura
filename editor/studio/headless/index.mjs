import * as runtime from '../_build/js/release/build/headless/headless.js';
import { createAPI } from '../web/api.mjs';

/** Browser-free editor factory. Initial documents start at revision zero without undo history. */
export function createHeadlessEditor(document) {
  if (document !== undefined && (document === null || typeof document !== 'object')) throw new TypeError('Expected a scene document');
  const instance = runtime.create(document === undefined ? '' : JSON.stringify(document));
  const events = new EventTarget();
  function request(value) {
    let result;
    try { result = JSON.parse(runtime.request(instance, JSON.stringify(value))); }
    catch { result = { ok: false, error: { code: 'invalid', message: 'Expected a JSON-serializable request' } }; }
    if (result.ok && value.method !== 'snapshot') events.dispatchEvent(new Event('kagura:change'));
    return result;
  }
  const adapter = {
    snapshot: () => runtime.snapshot(instance),
    dispatch: source => JSON.stringify(request({ method: 'dispatch', transaction: JSON.parse(source) })),
    history: (method, expectedRevision) => JSON.stringify(request({ method, expectedRevision })),
    select_node: id => request({ method: 'select', id }),
    seek: time => request({ method: 'seek', time }),
  };
  return Object.freeze({ ...createAPI(adapter, events), request });
}
