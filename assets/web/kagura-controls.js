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

import {stickVector, createControlInput} from './kagura-runtime.generated.js';
export {stickVector, createControlInput};

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
