// Worker side of `scripts/bench-frame-clock.mjs`.
//
// Stands where a `moonbitlang/async` guest stands: parked in the wait that
// `lib/web/kagura-wasm-worker.js` installs as `event_bus/wait`, woken by the
// driver's frame tick. It uses the shipped `createFrameWait` rather than a copy,
// so the numbers describe the real handshake.

import { parentPort, workerData } from "node:worker_threads";

import { FRAME_SLOT, createFrameWait } from "../lib/web/kagura-wasm-worker.js";

const { buffer, controlLength, stampIndex, durationMs, workMs, maxWaitMs, warmupWakes } = workerData;
const control = new Int32Array(buffer, 0, controlLength);
const stamps = new BigInt64Array(buffer);
const wait = createFrameWait(control, { maxWaitMs });

const wakeIntervalsMs = [];
const wakeLatenciesUs = [];
let previousWake = null;
let wakes = 0;
let framesSeen = 0;
let timeouts = 0;
let lastCounter = Atomics.load(control, FRAME_SLOT);

const endAt = process.hrtime.bigint() + BigInt(durationMs) * 1_000_000n;
while (process.hrtime.bigint() < endAt) {
  // The guest asks for a long park; a frame cuts it short. Same call shape the
  // async event loop makes.
  wait(maxWaitMs);
  const now = process.hrtime.bigint();
  wakes += 1;

  // A wake is not the same as a frame: `Atomics.wait` also returns on its own
  // timeout. Counting those as serviced frames is what made an early version of
  // this bench report 50ms latencies -- it was timing the timeout, against the
  // stamp of whatever tick came last. Trust the counter, not the wake.
  const counter = Atomics.load(control, FRAME_SLOT);
  const advanced = counter - lastCounter;
  if (advanced <= 0) {
    timeouts += 1;
    continue;
  }
  framesSeen += advanced;
  lastCounter = counter;

  // The first wakes land while this thread is still starting up, so their
  // latency measures worker boot rather than the handshake. Drop them.
  const warm = wakes > warmupWakes;
  const tickedAt = Atomics.load(stamps, stampIndex);
  if (warm && tickedAt > 0n) wakeLatenciesUs.push(Number(now - tickedAt) / 1000);
  if (warm && previousWake != null) wakeIntervalsMs.push(Number(now - previousWake) / 1_000_000);
  previousWake = now;

  // Stand in for a frame's synchronous work: the guest's draw calls back into
  // the host are all synchronous, so they occupy this thread the same way.
  if (workMs > 0) {
    const until = now + BigInt(Math.round(workMs * 1e6));
    while (process.hrtime.bigint() < until);
  }
}

parentPort.postMessage({ wakes, framesSeen, timeouts, wakeIntervalsMs, wakeLatenciesUs });
