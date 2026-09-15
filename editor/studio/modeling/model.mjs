import * as core from "../_build/js/release/build/modeling/bridge/bridge.js";

/** Pure MoonBit state; the host only carries JSON and subscriptions. */
export function createModelEditor(document) {
  const instance = core.create(),
    listeners = new Set();
  let current = JSON.parse(core.snapshot(instance));
  function request(command) {
    const result = JSON.parse(core.request(instance, JSON.stringify(command)));
    if (!result.ok) throw new Error(result.error);
    current = result.snapshot;
    for (const listener of listeners) listener(structuredClone(current));
    return structuredClone(current);
  }
  if (document) request({ op: "replace", document });
  return Object.freeze({
    request,
    snapshot: () => structuredClone(current),
    subscribe(listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
  });
}
export const kawaikoDocument = () => JSON.parse(core.kawaiko());

/** Deterministic neutral-relative evaluation; usable without a DOM or editor session. */
export function evaluateModel(document, weights = {}) {
  const result = JSON.parse(
    core.evaluate(JSON.stringify(document), JSON.stringify(weights)),
  );
  if (!result.ok) throw new Error(result.error);
  return result.document;
}
