// Semantic ABI conformance test for WASM guest modules
// Usage: node examples/wasm_game/test-wasm-abi.mjs [moonbit|rust|zig|all]
import {
  HOST_ASSET_TITLE,
  allocGuest,
  assert,
  deserializeDrawCommands,
  fileExists,
  hasSemanticAbi,
  inputByteSize,
  instantiateGuest,
  readSemanticGuestConfig,
  resolveTargets,
  serializeInput,
  writeInitEnv,
} from "./test-wasm-harness.mjs";

function assertSemanticExports(exports, label) {
  assert(hasSemanticAbi(exports), `${label} guest must expose semantic guest ABI`);
  assert(typeof exports.kagura_guest_snapshot_state === "function", "snapshot_state export missing");
  assert(typeof exports.kagura_guest_restore_state === "function", "restore_state export missing");
  assert(typeof exports.kagura_guest_shutdown === "function", "shutdown export missing");
}

function initSemanticGuest(exports, memory, env) {
  const envPtr = allocGuest(exports, 16);
  writeInitEnv(memory, envPtr, env);
  const configPtr = exports.kagura_guest_init(envPtr, 16);
  return readSemanticGuestConfig(memory, configPtr);
}

function assertRenderCommands(commands) {
  assert(commands.length > 0, "render must emit at least one command");
  for (const [index, command] of commands.entries()) {
    assert(command.vertexData.length > 0, `cmd[${index}] vertexCount=${command.vertexData.length / 4}`);
    assert(command.indices.length > 0, `cmd[${index}] indexCount=${command.indices.length}`);
    for (const [channel, value] of Object.entries({
      uniformR: command.uniformR,
      uniformG: command.uniformG,
      uniformB: command.uniformB,
      uniformA: command.uniformA,
    })) {
      assert(
        typeof value === "number" && value >= 0 && value <= 1,
        `cmd[${index}] color.${channel}=${value}`,
      );
    }
  }
}

async function testGuestConformance(path, label) {
  console.log(`\n=== ${label} ABI ===`);
  const primary = await instantiateGuest(path);
  const { exports, memory, hostLogs, assetRequests } = primary;
  assertSemanticExports(exports, label);

  const config = initSemanticGuest(exports, memory, {
    width: 800,
    height: 600,
    devicePixelRatio: 2,
    hotReloadEnabled: 1,
  });
  assert(config.width === 320, `width=${config.width}`);
  assert(config.height === 240, `height=${config.height}`);
  assert(config.targetTps === 60, `targetTps=${config.targetTps}`);
  assert(config.title === HOST_ASSET_TITLE, `title="${config.title}"`);
  assert(
    assetRequests.includes("/guest-title.txt"),
    `guest did not request /guest-title.txt: ${JSON.stringify(assetRequests)}`,
  );
  assert(
    hostLogs.some((entry) => entry.message.includes("guest init")),
    `missing init log: ${JSON.stringify(hostLogs)}`,
  );
  console.log("  init + host services: OK");

  const input = {
    cursorX: 12,
    cursorY: 34,
    wheelX: 1,
    wheelY: -1,
    keys: [32],
    mouseButtons: [0],
  };
  const inputPtr = allocGuest(exports, inputByteSize(input));
  const bytesWritten = serializeInput(memory, inputPtr, input);
  const redraw = exports.kagura_guest_update(inputPtr, bytesWritten);
  assert(redraw === 0 || redraw === 1, `wantsRedraw=${redraw}`);

  const drawPtr = exports.kagura_guest_render();
  const commands = deserializeDrawCommands(memory, drawPtr);
  assertRenderCommands(commands);
  console.log("  update + render: OK");

  const snapshotPtr = exports.kagura_guest_snapshot_state();
  assert(snapshotPtr === 0, `snapshotPtr=${snapshotPtr}`);
  const restoreResult = exports.kagura_guest_restore_state(0, 0);
  assert(restoreResult === 0, `restoreResult=${restoreResult}`);
  exports.kagura_guest_shutdown();
  console.log("  snapshot + restore + shutdown: OK");

  const fallback = await instantiateGuest(path, { assets: {} });
  assertSemanticExports(fallback.exports, `${label} fallback`);
  const fallbackConfig = initSemanticGuest(fallback.exports, fallback.memory, {
    width: 320,
    height: 240,
    devicePixelRatio: 1,
    hotReloadEnabled: 0,
  });
  assert(fallbackConfig.title.length > 0, "fallback title must not be empty");
  assert(
    fallbackConfig.title !== HOST_ASSET_TITLE,
    `fallback title should not depend on host asset: "${fallbackConfig.title}"`,
  );
  assert(
    fallback.assetRequests.includes("/guest-title.txt"),
    `fallback guest did not request /guest-title.txt: ${JSON.stringify(fallback.assetRequests)}`,
  );
  console.log("  asset miss fallback: OK");

  console.log(`  ${label}: PASS`);
}

const arg = process.argv[2] || "all";
let failed = false;

for (const target of resolveTargets(arg)) {
  if (!(await fileExists(target.path))) {
    if (arg === "moonbit" || arg === "rust" || arg === "zig") {
      console.error(`\n=== ${target.label} ABI === FAIL (not built)`);
      failed = true;
      continue;
    }
    console.log(`\n=== ${target.label} ABI === SKIP (not built)`);
    continue;
  }

  try {
    await testGuestConformance(target.path, target.label);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`\n  ${target.label}: FAIL - ${message}`);
    failed = true;
  }
}

console.log(failed ? "\nSome ABI tests FAILED" : "\nAll ABI tests PASSED");
process.exit(failed ? 1 : 0);
