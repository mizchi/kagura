import test from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { runWasm } from "./kagura-wasm-host.js";

const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const EXAMPLE_DIR = join(REPO_ROOT, "examples", "smoke", "wasm_async_smoke");
const WASM_PATH = join(EXAMPLE_DIR, "_build", "wasm", "debug", "build", "wasm_async_smoke.wasm");

function buildGuest() {
  if (existsSync(WASM_PATH)) return true;
  const result = spawnSync("moon", ["build", "--target", "wasm"], {
    cwd: EXAMPLE_DIR,
    stdio: "pipe",
  });
  return result.status === 0 && existsSync(WASM_PATH);
}

const ready = buildGuest();

test("moonbitlang/async runs on wasm1 under the minimal JS host", { skip: !ready && "moon build --target wasm unavailable" }, () => {
  const { output, stats } = runWasm(readFileSync(WASM_PATH));

  // The guest must get all the way through its async main, not just boot.
  assert.match(output, /wasm_async_smoke: start/);
  assert.match(output, /wasm_async_smoke: ok/);

  // Timers actually fire, and the shorter one first: this is what breaks if
  // `event_bus/wait` or the clock import regresses.
  const foreground = output.indexOf("foreground task woke");
  const background = output.indexOf("background task woke");
  assert.ok(foreground >= 0, `foreground timer never fired: ${output}`);
  assert.ok(background >= 0, `background timer never fired: ${output}`);
  assert.ok(foreground < background, `timers fired out of order: ${output}`);

  // The guest reads kagura's `kagura_web` clock across the sleeps, proving the
  // engine's host namespace links alongside async's.
  assert.match(output, /host clock advanced=true/);

  // The loop should sleep rather than spin: a busy-wait shows up as a huge
  // wait count for ~40ms of sleeping.
  assert.ok(stats.waits < 200, `event loop looks like it is spinning: ${stats.waits} waits`);
});

test("shutdown completes instead of hanging on the sigwait worker", { skip: !ready && "moon build --target wasm unavailable" }, () => {
  // `thread_pool/cancel_worker` returning 0 means "retry later", which loops
  // forever at teardown. Returning 2 (NoWait) is what lets `_start` return, so
  // reaching this assertion at all is the regression test.
  const { output } = runWasm(readFileSync(WASM_PATH));
  assert.ok(output.endsWith("wasm_async_smoke: ok\n"), `unexpected tail: ${JSON.stringify(output.slice(-80))}`);
});
