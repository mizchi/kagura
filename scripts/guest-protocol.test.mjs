import test from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import {
  assertGuestAbi,
  createGuestSession,
  createEngineFrameSession,
} from "../platform_web/host/kagura-guest-protocol.js";

test("all guest wire definitions match the canonical schema", () => {
  const result = spawnSync(
    process.execPath,
    [
      fileURLToPath(new URL("./generate-guest-wire.mjs", import.meta.url)),
      "--check",
    ],
    { encoding: "utf8" },
  );
  assert.equal(result.status, 0, result.stderr);
});

test("ABI mismatch is rejected before initialization or memory allocation", () => {
  let initialized = false;
  const exports = {
    kagura_guest_abi_version: () => 99,
    kagura_guest_init: () => {
      initialized = true;
    },
  };
  assert.throws(() => assertGuestAbi(exports), /ABI version/);
  assert.equal(initialized, false);
  assert.throws(() => assertGuestAbi({}), /version/);
});

test("engine frame adapter owns stop and prevents callbacks after stopping", () => {
  let frames = 0,
    stops = 0;
  const session = createEngineFrameSession({
    kagura_frame: () => frames++,
    kagura_stop: () => stops++,
    kagura_session_status: () => 1,
  });
  session.frame();
  session.stop();
  session.stop();
  session.frame();
  assert.equal(frames, 1);
  assert.equal(stops, 1);
  assert.equal(session.status(), "stopped");
});

test("engine frame failure stops the host driver and preserves failure state", () => {
  let status = 0,
    stops = 0;
  const session = createEngineFrameSession({
    kagura_frame: () => {
      status = 3;
    },
    kagura_stop: () => stops++,
    kagura_session_status: () => status,
  });
  assert.equal(session.status(), "starting");
  assert.throws(() => session.frame(), /Engine session failed/);
  session.frame();
  session.stop();
  assert.equal(session.status(), "failed");
  assert.equal(stops, 1);
});

test("semantic guest and engine adapter have the same owned stop behavior", () => {
  let stops = 0;
  const memory = new WebAssembly.Memory({ initial: 1 });
  const exports = {
    memory,
    kagura_guest_abi_version: () => 0,
    kagura_alloc: () => 64,
    kagura_guest_init: () => 128,
    kagura_guest_update: () => 1,
    kagura_guest_render: () => 256,
    kagura_guest_shutdown: () => stops++,
  };
  const view = new DataView(memory.buffer);
  view.setInt32(128, 320, true);
  view.setInt32(132, 240, true);
  view.setInt32(136, 60, true);
  const session = createGuestSession(exports);
  assert.throws(() => session.frame({}), /initialized/);
  assert.equal(
    session.init({
      width: 320,
      height: 240,
      devicePixelRatio: 1,
      hotReloadEnabled: false,
    }).width,
    320,
  );
  assert.deepEqual(
    session.frame({
      cursorX: 0,
      cursorY: 0,
      wheelX: 0,
      wheelY: 0,
      keys: [],
      mouseButtons: [],
    }).commands,
    [],
  );
  session.stop();
  session.stop();
  assert.equal(stops, 1);
  assert.equal(session.status(), "stopped");
});

import { readFileSync } from "node:fs";
import {
  writeInitEnv,
  serializeInput,
  inputByteSize,
} from "../platform_web/host/kagura-guest-protocol.js";
test("host wire encoding matches independent little-endian byte fixtures", () => {
  const fixtures = JSON.parse(
    readFileSync(
      new URL(
        "../examples/experimental/wasm_game/protocol/wire-v0-fixtures.json",
        import.meta.url,
      ),
      "utf8",
    ),
  );
  const memory = new WebAssembly.Memory({ initial: 1 });
  for (const [key, write] of [
    ["initEnv", writeInitEnv],
    ["input", serializeInput],
  ]) {
    const size = write(memory, 64, fixtures[key].value);
    assert.equal(
      Buffer.from(memory.buffer, 64, size).toString("hex"),
      fixtures[key].hex,
    );
    if (key === "input")
      assert.equal(size, inputByteSize(fixtures.input.value));
  }
});

import { deserializeDrawCommands } from "../platform_web/host/kagura-guest-protocol.js";
test("draw layout and color channels match the canonical byte fixture", () => {
  const fixture = JSON.parse(
    readFileSync(
      new URL(
        "../examples/experimental/wasm_game/protocol/wire-v0-fixtures.json",
        import.meta.url,
      ),
      "utf8",
    ),
  ).draw;
  const memory = new WebAssembly.Memory({ initial: 1 });
  new Uint8Array(memory.buffer, 64, fixture.hex.length / 2).set(
    Buffer.from(fixture.hex, "hex"),
  );
  const [command] = deserializeDrawCommands(memory, 64);
  assert.deepEqual(Array.from(command.vertexData), fixture.vertices);
  assert.deepEqual(Array.from(command.indices), fixture.indices);
  assert.equal(command.srcImageId, 42);
  assert.equal(command.uniformR, 1);
  assert.equal(command.uniformG, 128 / 255);
  assert.equal(command.uniformB, 0);
  assert.equal(command.uniformA, 1);
});
