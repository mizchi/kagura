// Main-thread driver for a `moonbitlang/async` wasm guest running in a Worker.
//
// The main thread keeps the frame clock (a `requestAnimationFrame` loop in a
// browser, a timer in Node) and the guest keeps its blocking async event loop;
// they meet on a small shared Int32Array. See `kagura-wasm-worker.js` for the
// handshake.
//
// What this buys: the guest can `@async.sleep`, await I/O, and generally block
// as much as it likes without freezing the page, while still observing the
// main thread's frame clock. That is the piece a single-threaded host cannot
// give you -- there, `_start` holds the thread and the host never gets to call
// back in.
//
// Only the Node path is covered by tests; `installBrowserFrameClock` is the
// same handshake against `requestAnimationFrame`.

import { CONTROL_LENGTH, FRAME_SLOT, STOP_SLOT } from "./kagura-wasm-worker.js";

const WORKER_URL = new URL("./kagura-wasm-worker.js", import.meta.url);

/** Allocate the shared control array the driver and worker share. */
export function createFrameControl() {
  return new Int32Array(new SharedArrayBuffer(CONTROL_LENGTH * 4));
}

/** Advance the frame counter and wake the guest if it is parked. */
export function tickFrame(control) {
  Atomics.add(control, FRAME_SLOT, 1);
  Atomics.notify(control, FRAME_SLOT);
}

/** Ask the guest's host to stop parking in `event_bus/wait`. */
export function stopFrames(control) {
  Atomics.store(control, STOP_SLOT, 1);
  Atomics.notify(control, FRAME_SLOT);
}

/**
 * Drive frames from `requestAnimationFrame`. Browser-side counterpart of the
 * interval used in `runWasmInWorker`; returns a stop function.
 */
export function installBrowserFrameClock(control) {
  let handle = 0;
  const step = () => {
    tickFrame(control);
    handle = globalThis.requestAnimationFrame(step);
  };
  handle = globalThis.requestAnimationFrame(step);
  return () => globalThis.cancelAnimationFrame(handle);
}

/**
 * Run a guest in a Node worker while driving frames from this thread.
 *
 * @param {Uint8Array|Buffer} wasmBytes
 * @param {object} [options]
 * @param {number} [options.frameIntervalMs] frame period; 16 approximates 60fps
 * @param {number} [options.timeoutMs] give up and stop the worker
 * @returns {Promise<{output: string, stats: object, frames: number}>}
 */
export async function runWasmInWorker(wasmBytes, options = {}) {
  const { Worker } = await import("node:worker_threads");
  const frameIntervalMs = options.frameIntervalMs ?? 16;
  const timeoutMs = options.timeoutMs ?? 10_000;

  const control = createFrameControl();
  const worker = new Worker(WORKER_URL);

  // A plain copy: SharedArrayBuffer crosses the boundary by reference, but the
  // module bytes do not need to be shared.
  const wasm = new Uint8Array(wasmBytes).slice().buffer;

  return await new Promise((resolve, reject) => {
    const frameTimer = setInterval(() => tickFrame(control), frameIntervalMs);
    const deadline = setTimeout(() => {
      stopFrames(control);
      finish(() => reject(new Error(`guest did not finish within ${timeoutMs}ms`)));
    }, timeoutMs);

    const finish = (settle) => {
      clearInterval(frameTimer);
      clearTimeout(deadline);
      worker.terminate().then(settle, settle);
    };

    worker.on("message", (message) => {
      if (message.type === "done") {
        const frames = Atomics.load(control, FRAME_SLOT);
        finish(() => resolve({ output: message.output, stats: message.stats, frames }));
      } else if (message.type === "error") {
        finish(() => reject(new Error(message.message)));
      }
    });
    worker.on("error", (error) => finish(() => reject(error)));

    worker.postMessage(
      { type: "start", wasm, control: control.buffer, options: { maxWaitMs: options.maxWaitMs ?? 50 } },
      [wasm],
    );
  });
}
