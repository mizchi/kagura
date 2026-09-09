// Worker-side entry for a MoonBit `wasm` guest that links `moonbitlang/async`.
//
// The guest's async event loop blocks the thread it runs on: `_start` does not
// return until the guest's async main finishes. That is fine here and fatal on
// a browser main thread, which is the whole reason for this file.
//
// The interesting part is `event_bus/wait`. It is the one place the guest hands
// control back to the host, so instead of sleeping on a private cell it waits
// on the *shared* frame counter. A `requestAnimationFrame` on the main thread
// bumps that counter and `Atomics.notify`s it, which wakes the guest early --
// so the main thread's frame clock drives the guest without either side
// polling.
//
//   main thread            shared Int32Array          worker
//   ------------           -----------------          ------
//   rAF fires
//     Atomics.add(FRAME,1) ----> [FRAME] ----> Atomics.wait returns
//     Atomics.notify                            guest's timers advance
//
// Runs under both `node:worker_threads` and a browser Worker; only the Node
// path is covered by tests.

import { createWasmHost } from "./kagura-wasm-host.js";

/** Index of the frame counter inside the shared Int32Array. */
export const FRAME_SLOT = 0;
/** Set to 1 by the main thread to ask the guest's host to stop waiting. */
export const STOP_SLOT = 1;
/** Length, in Int32 elements, of the control array the driver allocates. */
export const CONTROL_LENGTH = 2;

/**
 * Wire up to whichever worker environment we are in, or null when this module
 * was merely imported (the driver does that to reach the slot constants).
 */
async function connect() {
  let parentPort = null;
  try {
    ({ parentPort } = await import("node:worker_threads"));
  } catch {
    parentPort = null; // not Node: either a browser Worker or a browser page
  }
  if (parentPort != null) {
    return {
      post: (message) => parentPort.postMessage(message),
      onMessage: (handler) => parentPort.on("message", handler),
    };
  }
  const scope = globalThis.WorkerGlobalScope;
  if (scope != null && globalThis instanceof scope) {
    return {
      post: (message) => globalThis.postMessage(message),
      onMessage: (handler) => {
        globalThis.onmessage = (event) => handler(event.data);
      },
    };
  }
  return null;
}

/**
 * Build the `event_bus/wait` replacement: block until the frame counter moves,
 * the stop flag is set, or the guest's own timeout expires.
 */
export function createFrameWait(control, { maxWaitMs = 50 } = {}) {
  return (ms) => {
    if (ms <= 0) return;
    if (Atomics.load(control, STOP_SLOT) !== 0) return;
    const seen = Atomics.load(control, FRAME_SLOT);
    // Waits on the value we just read, so a frame that lands between the load
    // and the wait returns immediately instead of being missed.
    Atomics.wait(control, FRAME_SLOT, seen, Math.min(ms, maxWaitMs));
  };
}

/**
 * Run a guest to completion on this thread.
 *
 * @param {Uint8Array} bytes the guest module
 * @param {Int32Array} control shared control array (see the *_SLOT exports)
 */
export function runWasmWithFrameClock(bytes, control, options = {}) {
  const chunks = [];
  const host = createWasmHost(bytes, {
    ...options,
    write: (text) => chunks.push(text),
    wait: createFrameWait(control, options),
    frameNumber: () => Atomics.load(control, FRAME_SLOT),
  });
  const instance = new WebAssembly.Instance(new WebAssembly.Module(bytes), host.imports);
  host.bind(instance);
  instance.exports._start();
  return { output: chunks.join(""), stats: host.stats };
}

// When loaded as a Worker entry point, wait for the driver's start message.
// Imported from a main thread (the driver does, for the slot constants), this
// does nothing.
const link = await connect();
link?.onMessage((message) => {
  if (message?.type !== "start") return;
  const control = new Int32Array(message.control);
  try {
    const { output, stats } = runWasmWithFrameClock(new Uint8Array(message.wasm), control, message.options ?? {});
    link.post({ type: "done", output, stats });
  } catch (error) {
    link.post({ type: "error", message: String(error?.message ?? error) });
  }
});
