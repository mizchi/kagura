/** Transport boundary. Domain validation and history live in MoonBit. */
export function createAPI(app, events = globalThis) {
  const invalid = message => ({ ok: false, error: { code: 'invalid', message } });
  const api = {
    snapshot: () => JSON.parse(app.snapshot()),
    dispatch(envelope) {
      try { return JSON.parse(app.dispatch(JSON.stringify(envelope))); }
      catch { return invalid('Expected a JSON-serializable transaction'); }
    },
    clearHistory(expectedRevision) { return history('history.clear', expectedRevision); },
    undo(expectedRevision) { return history('undo', expectedRevision); },
    redo(expectedRevision) { return history('redo', expectedRevision); },
    select(id) {
      if (typeof id !== 'string' || (id && !api.snapshot().document.nodes.some(n => n.id === id))) return invalid('Unknown node ID');
      app.select_node(id);
      return { ok: true, snapshot: api.snapshot() };
    },
    seek(time) {
      if (!Number.isFinite(time) || time < 0 || time > api.snapshot().document.action.duration) return invalid('Time outside action');
      app.seek(time);
      return { ok: true, snapshot: api.snapshot() };
    },
    subscribe(listener) {
      const handler = () => listener(api.snapshot()); // Each subscriber owns its copy.
      events.addEventListener('kagura:change', handler);
      return () => events.removeEventListener('kagura:change', handler);
    },
    capabilities: () => ({ apiVersion: 1, coordinates: { units: 'meters', up: 'Y', forward: '+Z', angles: 'radians', time: 'seconds' },
      assets: ['primitive.box', 'primitive.sphere', 'primitive.cylinder', 'group'],
      commands: ['node.add', 'node.remove', 'node.rename', 'node.reparent', 'node.transform', 'node.material', 'action.set', 'document.replace', 'resource.put', 'resource.remove'],
      limits: { nodes: 2000, batch: 100, history: 100 }, contract: './contract.d.ts' }),
  };
  function history(direction, revision) {
    if (!Number.isSafeInteger(revision) || revision < 0 || revision > 2147483647) return invalid('expectedRevision must be a non-negative 32-bit integer');
    return JSON.parse(app.history(direction, revision));
  }
  return Object.freeze(api);
}
