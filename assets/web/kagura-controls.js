/** @typedef {{x: number, y: number}} StickVector */
/** @typedef {{key: number, payload: unknown}} ControlCommand */
/**
 * @typedef {object} ControlInput
 * @property {1} version
 * @property {(id: number, x: number, y: number) => boolean} move
 * @property {(id: number, action: string) => void} hold
 * @property {(id: number) => void} release
 * @property {(key: number, payload?: unknown) => boolean} tap
 * @property {() => ControlCommand | null} consumeCommand
 * @property {() => {x: number, y: number, actions: string[]}} snapshot
 * @property {() => void} clear
 */

/** Radial dead zone with proportional speed and a circular limit. */
export function stickVector(dx, dy, radius, {deadZone = .14} = {}) {
  if (![dx, dy, radius, deadZone].every(Number.isFinite) || radius <= 0 || deadZone < 0 || deadZone >= 1) {
    throw new RangeError('Stick coordinates must be finite, radius positive, and deadZone in [0, 1)');
  }
  const length = Math.hypot(dx, dy);
  if (length === 0 || length < radius * deadZone) return {x: 0, y: 0};
  const magnitude = Math.min(1, (length / radius - deadZone) / (1 - deadZone));
  return {x: dx / length * magnitude, y: dy / length * magnitude};
}

/** Input intents only; game simulation owns all movement, cooldowns and effects.
 * @param {{capacity?: number}} options
 * @returns {ControlInput}
 */
export function createControlInput({capacity = 8} = {}) {
  if (!Number.isSafeInteger(capacity) || capacity < 1) throw new RangeError('Command capacity must be positive');
  const held = new Map();
  const commands = [];
  let owner = null;
  let x = 0, y = 0;
  let releasePending = false;
  return {
    version: 1,
    move(id, dx, dy) {
      if (owner !== null && owner !== id) return false;
      owner = id; x = dx; y = dy;
      return true;
    },
    hold(id, action) { held.set(id, action); },
    release(id) {
      held.delete(id);
      if (owner === id) { owner = null; x = 0; y = 0; }
    },
    tap(key, payload = null) {
      if (!Number.isSafeInteger(key) || key <= 0) throw new RangeError('Command key must be a positive integer');
      if (commands.length >= capacity) return false;
      commands.push({key, payload});
      return true;
    },
    consumeCommand() {
      // Two short taps must reach edge-triggered simulation as separate presses.
      if (releasePending) { releasePending = false; return null; }
      const command = commands.shift() ?? null;
      releasePending = command !== null;
      return command;
    },
    snapshot() { return {x, y, actions: [...new Set(held.values())]}; },
    clear() {
      held.clear(); commands.length = 0; owner = null;
      x = 0; y = 0; releasePending = false;
    },
  };
}

/**
 * Bind one virtual stick, with pointer capture and explicit lifecycle cleanup.
 * @param {HTMLElement} element
 * @param {{input: ControlInput, radius?: number, enabled?: () => boolean,
 *   center?: () => StickVector, onChange?: (vector: StickVector) => void}} options
 * @returns {{reset: () => void, dispose: () => void}}
 */
export function bindVirtualStick(element, {
  input, radius = 48, enabled = () => true, onChange = () => {},
  center = () => {
    const rect = element.getBoundingClientRect();
    return {x: rect.x + rect.width / 2, y: rect.y + rect.height / 2};
  },
}) {
  stickVector(0, 0, radius);
  const document = element.ownerDocument;
  const host = document.defaultView;
  let owner = null;
  let origin = {x: 0, y: 0};
  const listeners = [];
  function listen(target, name, callback) {
    target.addEventListener(name, callback);
    listeners.push(() => target.removeEventListener(name, callback));
  }
  function reset() {
    if (owner === null) return;
    const id = owner; owner = null;
    input.release(id);
    if (element.hasPointerCapture(id)) element.releasePointerCapture(id);
    onChange({x: 0, y: 0});
  }
  function move(event) {
    if (event.pointerId !== owner) return;
    event.preventDefault(); event.stopPropagation();
    const vector = stickVector(event.clientX - origin.x, event.clientY - origin.y, radius);
    input.move(owner, vector.x, vector.y);
    onChange(vector);
  }
  listen(element, 'pointerdown', event => {
    if (owner !== null || !enabled() || !input.move(event.pointerId, 0, 0)) return;
    owner = event.pointerId;
    origin = center();
    element.setPointerCapture(owner);
    move(event);
  });
  listen(element, 'pointermove', move);
  for (const name of ['pointerup', 'pointercancel', 'lostpointercapture']) {
    listen(element, name, event => { if (event.pointerId === owner) reset(); });
  }
  listen(host, 'blur', reset);
  listen(document, 'visibilitychange', () => { if (document.hidden) reset(); });
  return {reset, dispose() { reset(); for (const remove of listeners) remove(); }};
}
