// Smoke test for WASM guest modules (semantic ABI only)
// Usage: node examples/wasm_game/test-wasm.mjs [moonbit|rust|zig|all]
import {
  HOST_ASSET_TITLE,
  allocGuest,
  assert,
  assertSemanticAbi,
  deserializeDrawCommands,
  fileExists,
  inputByteSize,
  instantiateGuest,
  readSemanticGuestConfig,
  resolveTargets,
  serializeInput,
  writeInitEnv,
} from "./test-wasm-harness.mjs";

async function testWasm(path, label) {
  console.log(`\n=== ${label} ===`);
  const guest = await instantiateGuest(path);
  const { exports, memory, hostLogs } = guest;
  assertSemanticAbi(exports);

  const envPtr = allocGuest(exports, 16);
  writeInitEnv(memory, envPtr);
  const configPtr = exports.kagura_guest_init(envPtr, 16);
  const config = readSemanticGuestConfig(memory, configPtr);

  assert(hostLogs.length > 0, "guest must emit at least one host log");
  assert(
    hostLogs.some((entry) => entry.message.includes("guest init")),
    `missing init log: ${JSON.stringify(hostLogs)}`,
  );

  const { width, height, targetTps, title } = config;
  assert(width === 320, `width=${width}`);
  assert(height === 240, `height=${height}`);
  assert(targetTps === 60, `targetTps=${targetTps}`);
  assert(title === HOST_ASSET_TITLE, `title="${title}"`);
  console.log(`  config: ${width}x${height} @${targetTps} "${title}"`);

  const emptyInput = {
    cursorX: 0,
    cursorY: 0,
    wheelX: 0,
    wheelY: 0,
    keys: [],
    mouseButtons: [],
  };
  const inputPtr = allocGuest(exports, inputByteSize(emptyInput));
  const inputSize = serializeInput(memory, inputPtr, emptyInput);
  const wantsRedraw = exports.kagura_guest_update(inputPtr, inputSize);
  assert(wantsRedraw === 1, `wantsRedraw=${wantsRedraw}`);

  const drawPtr = exports.kagura_guest_render();
  const commands = deserializeDrawCommands(memory, drawPtr);
  assert(commands.length === 3, `initial cmdCount=${commands.length}, expected 3`);

  const expectedColors = [
    [135 / 255, 206 / 255, 235 / 255, 1],
    [139 / 255, 69 / 255, 19 / 255, 1],
    [1, 215 / 255, 0, 1],
  ];
  for (let i = 0; i < commands.length; i++) {
    const command = commands[i];
    assert(command.vertexData.length === 16, `cmd[${i}] vertexCount=${command.vertexData.length / 4}`);
    assert(command.indices.length === 6, `cmd[${i}] indexCount=${command.indices.length}`);
    const [r, g, b, a] = expectedColors[i];
    assert(
      command.uniformR === r &&
        command.uniformG === g &&
        command.uniformB === b &&
        command.uniformA === a,
      `cmd[${i}] color=(${command.uniformR},${command.uniformG},${command.uniformB},${command.uniformA}) expected (${r},${g},${b},${a})`,
    );
  }
  console.log("  draw commands: OK (3 cmds, correct colors)");

  for (let frame = 0; frame < 60; frame++) {
    const ptr = allocGuest(exports, inputByteSize(emptyInput));
    const bytesWritten = serializeInput(memory, ptr, emptyInput);
    exports.kagura_guest_update(ptr, bytesWritten);
    exports.kagura_guest_render();
  }
  console.log("  60 frame cycles: OK");

  const startedInput = {
    cursorX: 0,
    cursorY: 0,
    wheelX: 0,
    wheelY: 0,
    keys: [32],
    mouseButtons: [],
  };
  const ptr = allocGuest(exports, inputByteSize(startedInput));
  const bytesWritten = serializeInput(memory, ptr, startedInput);
  exports.kagura_guest_update(ptr, bytesWritten);
  const drawPtr2 = exports.kagura_guest_render();
  const commandsAfterSpace = deserializeDrawCommands(memory, drawPtr2);
  assert(commandsAfterSpace.length >= 3, `after space cmdCount=${commandsAfterSpace.length}`);
  console.log("  space key input: OK");

  assert(
    typeof exports.kagura_guest_snapshot_state === "function",
    "snapshot_state export missing",
  );
  assert(
    typeof exports.kagura_guest_restore_state === "function",
    "restore_state export missing",
  );
  const snapshotPtr = exports.kagura_guest_snapshot_state();
  assert(snapshotPtr === 0, `snapshotPtr=${snapshotPtr}`);
  const restoreResult = exports.kagura_guest_restore_state(0, 0);
  assert(restoreResult === 0, `restoreResult=${restoreResult}`);
  console.log("  semantic ABI hooks: OK");

  console.log(`  ${label}: PASS`);
}

const arg = process.argv[2] || "all";
let failed = false;

for (const target of resolveTargets(arg)) {
  if (!(await fileExists(target.path))) {
    if (arg === "moonbit" || arg === "rust" || arg === "zig") {
      console.error(`\n=== ${target.label} === FAIL (not built)`);
      failed = true;
      continue;
    }
    console.log(`\n=== ${target.label} === SKIP (not built)`);
    continue;
  }

  try {
    await testWasm(target.path, target.label);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`\n  ${target.label}: FAIL - ${message}`);
    failed = true;
  }
}

console.log(failed ? "\nSome tests FAILED" : "\nAll tests PASSED");
process.exit(failed ? 1 : 0);
