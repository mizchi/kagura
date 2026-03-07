// Smoke test for WASM guest modules
// Usage: node examples/wasm_game/test-wasm.mjs [moonbit|rust|zig|all]
import { readFile, access } from "node:fs/promises";

const MOONBIT_WASM =
  "examples/wasm_game/guest/moonbit/_build/wasm/debug/build/wasm_game_guest.wasm";
const RUST_WASM =
  "examples/wasm_game/guest/rust/target/wasm32-unknown-unknown/release/kagura_wasm_guest_rust.wasm";
const ZIG_WASM =
  "examples/wasm_game/guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm";
const HOST_ASSET_TITLE = "Flappy Bird via Host Asset";

function writeEmptyInput(memory, ptr) {
  const dv = new DataView(memory.buffer);
  dv.setFloat64(ptr, 0, true);
  dv.setFloat64(ptr + 8, 0, true);
  dv.setFloat64(ptr + 16, 0, true);
  dv.setFloat64(ptr + 24, 0, true);
  dv.setInt32(ptr + 32, 0, true);
  dv.setInt32(ptr + 36, 0, true);
  dv.setInt32(ptr + 40, 0, true);
  dv.setInt32(ptr + 44, 0, true);
}

function writeInitEnv(memory, ptr, env = { width: 640, height: 480, devicePixelRatio: 1, hotReloadEnabled: 1 }) {
  const dv = new DataView(memory.buffer);
  dv.setInt32(ptr, env.width, true);
  dv.setInt32(ptr + 4, env.height, true);
  dv.setFloat32(ptr + 8, env.devicePixelRatio, true);
  dv.setInt32(ptr + 12, env.hotReloadEnabled, true);
}

function assert(cond, msg) {
  if (!cond) throw new Error(`Assertion failed: ${msg}`);
}

function hasSemanticAbi(exports) {
  return (
    typeof exports.kagura_guest_init === "function" &&
    typeof exports.kagura_guest_update === "function" &&
    typeof exports.kagura_guest_render === "function"
  );
}

function readLegacyConfig(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const width = dv.getInt32(ptr, true);
  const height = dv.getInt32(ptr + 4, true);
  const titleLen = dv.getInt32(ptr + 8, true);
  const title = new TextDecoder().decode(
    new Uint8Array(memory.buffer, ptr + 12, titleLen),
  );
  return { width, height, targetTps: 60, title };
}

function readSemanticConfig(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const width = dv.getInt32(ptr, true);
  const height = dv.getInt32(ptr + 4, true);
  const targetTps = dv.getInt32(ptr + 8, true);
  const titleLen = dv.getInt32(ptr + 12, true);
  const title = new TextDecoder().decode(
    new Uint8Array(memory.buffer, ptr + 16, titleLen),
  );
  return { width, height, targetTps, title };
}

async function testWasm(path, label) {
  console.log(`\n=== ${label} ===`);
  const buf = await readFile(path);
  const hostLogs = [];
  let currentMemory = null;
  const assetBytes = new TextEncoder().encode(HOST_ASSET_TITLE);
  const imports = {
    kagura_host: {
      log_i32_utf8(level, ptr, len) {
        if (!currentMemory) {
          throw new Error("host log called before memory was ready");
        }
        const bytes = new Uint8Array(currentMemory.buffer, ptr, len);
        const message = new TextDecoder().decode(bytes);
        hostLogs.push({ level, message });
        return 0;
      },
      read_asset_len_i32_utf8(ptr, len) {
        if (!currentMemory) {
          throw new Error("asset read called before memory was ready");
        }
        const bytes = new Uint8Array(currentMemory.buffer, ptr, len);
        const path = new TextDecoder().decode(bytes);
        return path === "/guest-title.txt" ? assetBytes.length : -1;
      },
      read_asset_copy_i32_utf8(pathPtr, pathLen, dstPtr) {
        if (!currentMemory) {
          throw new Error("asset copy called before memory was ready");
        }
        const pathBytes = new Uint8Array(currentMemory.buffer, pathPtr, pathLen);
        const path = new TextDecoder().decode(pathBytes);
        if (path !== "/guest-title.txt") {
          return -1;
        }
        const dst = new Uint8Array(currentMemory.buffer, dstPtr, assetBytes.length);
        dst.set(assetBytes);
        return assetBytes.length;
      },
    },
  };
  const { instance } = await WebAssembly.instantiate(buf, imports);
  const { memory, _start } = instance.exports;
  currentMemory = memory;
  const semanticAbi = hasSemanticAbi(instance.exports);
  const {
    kagura_init,
    kagura_alloc,
    kagura_update,
    kagura_draw,
    kagura_guest_init,
    kagura_guest_update,
    kagura_guest_render,
    kagura_guest_snapshot_state,
    kagura_guest_restore_state,
  } = instance.exports;

  if (_start) _start();

  if (label === "MoonBit" || label === "Rust" || label === "Zig") {
    assert(semanticAbi, `${label} guest must expose semantic guest ABI`);
  }

  assert(typeof kagura_alloc === "function", "guest allocator export is required");
  const dv = new DataView(memory.buffer);

  let config;
  if (semanticAbi) {
    const envSize = 16;
    const envPtr = kagura_alloc(envSize);
    writeInitEnv(memory, envPtr);
    const configPtr = kagura_guest_init(envPtr, envSize);
    config = readSemanticConfig(memory, configPtr);
    assert(hostLogs.length > 0, "semantic guest must emit at least one host log");
    assert(
      hostLogs.some((entry) => entry.message.includes("guest init")),
      `missing init log: ${JSON.stringify(hostLogs)}`,
    );
  } else {
    const configPtr = kagura_init();
    config = readLegacyConfig(memory, configPtr);
  }

  const { width, height, targetTps, title } = config;
  assert(width === 320, `width=${width}`);
  assert(height === 240, `height=${height}`);
  assert(targetTps === 60, `targetTps=${targetTps}`);
  if (semanticAbi) {
    assert(title === HOST_ASSET_TITLE, `title="${title}"`);
  } else {
    assert(title.length > 0, `title="${title}"`);
  }
  console.log(`  config: ${width}x${height} @${targetTps} "${title}"`);

  // kagura_update + kagura_draw: initial state (sky+ground+bird)
  const inputSize = 48;
  const inputPtr = kagura_alloc(inputSize);
  writeEmptyInput(memory, inputPtr);
  const wantsRedraw = semanticAbi
    ? kagura_guest_update(inputPtr, inputSize)
    : (kagura_update(inputPtr, inputSize), 1);
  assert(wantsRedraw === 1, `wantsRedraw=${wantsRedraw}`);
  const drawPtr = semanticAbi ? kagura_guest_render() : kagura_draw();
  const cmdCount = dv.getInt32(drawPtr, true);
  assert(cmdCount === 3, `initial cmdCount=${cmdCount}, expected 3`);

  // Verify draw command structure
  let offset = drawPtr + 4;
  const expectedColors = [
    [135, 206, 235, 255], // sky (#87CEEB)
    [139, 69, 19, 255],   // ground (#8B4513)
    [255, 215, 0, 255],   // bird (#FFD700)
  ];
  for (let i = 0; i < cmdCount; i++) {
    const v = dv.getInt32(offset, true);
    const idx = dv.getInt32(offset + 4, true);
    assert(v === 4, `cmd[${i}] vertexCount=${v}`);
    assert(idx === 6, `cmd[${i}] indexCount=${idx}`);
    const r = dv.getInt32(offset + 12, true);
    const g = dv.getInt32(offset + 16, true);
    const b = dv.getInt32(offset + 20, true);
    const a = dv.getInt32(offset + 24, true);
    const [er, eg, eb, ea] = expectedColors[i];
    assert(
      r === er && g === eg && b === eb && a === ea,
      `cmd[${i}] color=(${r},${g},${b},${a}) expected (${er},${eg},${eb},${ea})`,
    );
    offset += 28 + v * 16 + idx * 4;
  }
  console.log("  draw commands: OK (3 cmds, correct colors)");

  // 60 frame cycles without crash
  for (let frame = 0; frame < 60; frame++) {
    const ptr = kagura_alloc(inputSize);
    writeEmptyInput(memory, ptr);
    if (semanticAbi) {
      kagura_guest_update(ptr, inputSize);
      kagura_guest_render();
    } else {
      kagura_update(ptr, inputSize);
      kagura_draw();
    }
  }
  console.log("  60 frame cycles: OK");

  // Space key starts game (game_mode 0→1)
  const ptr3 = kagura_alloc(52);
  const dv3 = new DataView(memory.buffer);
  dv3.setFloat64(ptr3, 0, true);
  dv3.setFloat64(ptr3 + 8, 0, true);
  dv3.setFloat64(ptr3 + 16, 0, true);
  dv3.setFloat64(ptr3 + 24, 0, true);
  dv3.setInt32(ptr3 + 32, 1, true); // 1 key
  dv3.setInt32(ptr3 + 36, 32, true); // Space
  dv3.setInt32(ptr3 + 40, 0, true);
  dv3.setInt32(ptr3 + 44, 0, true);
  dv3.setInt32(ptr3 + 48, 0, true);
  if (semanticAbi) {
    kagura_guest_update(ptr3, 52);
  } else {
    kagura_update(ptr3, 52);
  }
  const drawPtr2 = semanticAbi ? kagura_guest_render() : kagura_draw();
  const cmdCount2 = new DataView(memory.buffer).getInt32(drawPtr2, true);
  assert(cmdCount2 >= 3, `after space cmdCount=${cmdCount2}`);
  console.log("  space key input: OK");

  if (semanticAbi) {
    assert(
      typeof kagura_guest_snapshot_state === "function",
      "snapshot_state export missing",
    );
    assert(
      typeof kagura_guest_restore_state === "function",
      "restore_state export missing",
    );
    const snapshotPtr = kagura_guest_snapshot_state();
    assert(snapshotPtr === 0, `snapshotPtr=${snapshotPtr}`);
    const restoreResult = kagura_guest_restore_state(0, 0);
    assert(restoreResult === 0, `restoreResult=${restoreResult}`);
    console.log("  semantic ABI hooks: OK");
  }

  console.log(`  ${label}: PASS`);
}

async function fileExists(path) {
  try { await access(path); return true; } catch { return false; }
}

const arg = process.argv[2] || "all";
let failed = false;

const targets = [];
if (arg === "all" || arg === "moonbit") targets.push([MOONBIT_WASM, "MoonBit"]);
if (arg === "all" || arg === "rust") targets.push([RUST_WASM, "Rust"]);
if (arg === "all" || arg === "zig") targets.push([ZIG_WASM, "Zig"]);

for (const [path, label] of targets) {
  if (!(await fileExists(path))) {
    if (arg === "zig" || arg === "moonbit" || arg === "rust") {
      console.error(`\n=== ${label} === FAIL (not built)`);
      failed = true;
      continue;
    }
    console.log(`\n=== ${label} === SKIP (not built)`);
    continue;
  }
  try {
    await testWasm(path, label);
  } catch (e) {
    console.error(`\n  ${label}: FAIL - ${e.message}`);
    failed = true;
  }
}

console.log(failed ? "\nSome tests FAILED" : "\nAll tests PASSED");
process.exit(failed ? 1 : 0);
