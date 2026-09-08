import test from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { runInWorker } from "./wasm-async-driver.mjs";
import { runAsyncWasm } from "./wasm-async-host.mjs";

const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const EXAMPLE_DIR = join(REPO_ROOT, "examples", "smoke", "wasm_async_smoke");
const WASM_PATH = join(EXAMPLE_DIR, "_build", "wasm", "debug", "build", "wasm_async_smoke.wasm");

function buildGuest() {
  if (existsSync(WASM_PATH)) return true;
  const result = spawnSync("moon", ["build", "--target", "wasm"], { cwd: EXAMPLE_DIR, stdio: "pipe" });
  return result.status === 0 && existsSync(WASM_PATH);
}

const ready = buildGuest();
const skip = !ready && "moon build --target wasm unavailable";

const framesObserved = (output) => {
  const match = output.match(/frames observed=(\d+)/);
  assert.ok(match, `guest never reported a frame count: ${output}`);
  return Number(match[1]);
};

test("a main-thread frame clock drives the guest through event_bus/wait", { skip }, async () => {
  const { output, frames } = await runInWorker(readFileSync(WASM_PATH), { frameIntervalMs: 8 });

  assert.match(output, /wasm_async_smoke: ok/);
  // The main thread ticked frames while the guest sat in its blocking event
  // loop, and the guest saw them. This is the whole point of the Worker split.
  assert.ok(frames > 0, "driver never ticked a frame");
  assert.equal(framesObserved(output), 5, `guest did not observe the driven frames: ${output}`);
});

test("the guest still terminates when nothing drives frames", { skip }, () => {
  // Same binary, single-threaded host, no frame source: the observe loop must
  // spend its budget and give up rather than hang.
  const { output } = runAsyncWasm(readFileSync(WASM_PATH));

  assert.match(output, /wasm_async_smoke: ok/);
  assert.equal(framesObserved(output), 0, `frames appeared without a driver: ${output}`);
});

test("timers still fire correctly inside the worker", { skip }, async () => {
  const { output } = await runInWorker(readFileSync(WASM_PATH), { frameIntervalMs: 8 });

  const foreground = output.indexOf("foreground task woke");
  const background = output.indexOf("background task woke");
  assert.ok(foreground >= 0 && background >= 0, `a timer never fired: ${output}`);
  assert.ok(foreground < background, `timers fired out of order: ${output}`);
  assert.match(output, /host clock advanced=true/);
});
