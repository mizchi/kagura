import { validateInspection, validateInspectionEdit } from './inspection.mjs';
/** Synchronous game-owned debugger. This module also runs without a DOM/GPU. */
export function createRuntimeSession(adapter) {
  if (
    adapter?.apiVersion !== 1 ||
    typeof adapter.game !== 'string' ||
    typeof adapter.schema?.id !== 'string' ||
    !Number.isSafeInteger(adapter.schema.version) ||
    adapter.schema.version < 1 ||
    ['read', 'pause', 'step', 'replace'].some((k) => typeof adapter[k] !== 'function')
  )
    throw Error('Invalid runtime debug adapter');
  const session = crypto.randomUUID(),
    schema = structuredClone(adapter.schema);
  let disposed = false;
  const live = () => {
    if (disposed) throw Error('Runtime session disposed');
  };
  const copy = (value) => {
    const text = JSON.stringify(value, (_, v) => {
      if (
        (typeof v === 'number' && !Number.isFinite(v)) ||
        ['undefined', 'function', 'symbol', 'bigint'].includes(typeof v)
      )
        throw Error('Expected finite JSON state');
      return v;
    });
    if (new TextEncoder().encode(text).byteLength > 4 * 1024 * 1024)
      throw Error('Runtime state exceeds 4 MiB');
    return JSON.parse(text);
  };
  function snapshot() {
    live();
    const value = adapter.read();
    if (
      !Number.isSafeInteger(value.revision) ||
      value.revision < 0 ||
      typeof value.paused !== 'boolean'
    )
      throw Error('Invalid runtime snapshot');
    return copy({
      apiVersion: 1,
      game: adapter.game,
      schema,
      session,
      revision: value.revision,
      paused: value.paused,
      state: value.state,
    });
  }
  function guard(token) {
    const current = snapshot();
    if (token?.session !== session) throw Error('Runtime session conflict');
    if (token?.revision !== current.revision) throw Error('Runtime revision conflict');
    if (!current.paused) throw Error('Runtime must be paused');
    return current;
  }
  return Object.freeze({
    snapshot,
    inspect() {
      const current = snapshot();
      const subjects = adapter.inspector
        ? validateInspection(copy(adapter.inspector.describe(copy(current.state))))
        : [];
      return { session, revision: current.revision, paused: current.paused, subjects };
    },
    edit(edit, token) {
      const current = guard(token);
      if (!adapter.inspector || typeof adapter.inspector.reduce !== 'function')
        throw Error('Runtime inspector is not available');
      const subjects = validateInspection(copy(adapter.inspector.describe(copy(current.state))));
      const command = copy(edit);
      validateInspectionEdit(command, subjects);
      const next = copy(adapter.inspector.reduce(copy(current.state), command));
      adapter.replace(next);
      return snapshot();
    },
    pause() {
      live();
      adapter.pause(true);
      return snapshot();
    },
    resume(token) {
      guard(token);
      adapter.pause(false);
      return snapshot();
    },
    step(token) {
      guard(token);
      adapter.step();
      return snapshot();
    },
    replace(state, token) {
      guard(token);
      adapter.replace(copy(state));
      return snapshot();
    },
    dispose() {
      disposed = true;
    },
  });
}
