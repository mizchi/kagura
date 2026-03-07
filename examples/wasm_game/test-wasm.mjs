// Smoke test for WASM guest modules
// Usage: node examples/wasm_game/test-wasm.mjs [moonbit|rust|zig|all]
import {
  HOST_ASSET_TITLE,
  allocGuest,
  assert,
  fileExists,
  hasSemanticAbi,
  instantiateGuest,
  readDrawCommands,
  readLegacyConfig,
  readSemanticConfig,
  resolveTargets,
  writeInitEnv,
  writeInput,
} from "./test-wasm-harness.mjs";

async function testWasm(path, label) {
  console.log(`\n=== ${label} ===`);
  const guest = await instantiateGuest(path);
  const { exports, memory, hostLogs } = guest;
  const semanticAbi = hasSemanticAbi(exports);

  const {
    kagura_init,
    kagura_update,
    kagura_draw,
    kagura_guest_init,
    kagura_guest_update,
    kagura_guest_render,
    kagura_guest_snapshot_state,
    kagura_guest_restore_state,
  } = exports;

  if (label === "MoonBit" || label === "Rust" || label === "Zig") {
    assert(semanticAbi, `${label} guest must expose semantic guest ABI`);
  }

  let config;
  if (semanticAbi) {
    const envPtr = allocGuest(exports, 16);
    writeInitEnv(memory, envPtr);
    const configPtr = kagura_guest_init(envPtr, 16);
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

  const inputPtr = allocGuest(exports, 64);
  const inputSize = writeInput(memory, inputPtr);
  const wantsRedraw = semanticAbi
    ? kagura_guest_update(inputPtr, inputSize)
    : (kagura_update(inputPtr, inputSize), 1);
  assert(wantsRedraw === 1, `wantsRedraw=${wantsRedraw}`);

  const drawPtr = semanticAbi ? kagura_guest_render() : kagura_draw();
  const commands = readDrawCommands(memory, drawPtr);
  assert(commands.length === 3, `initial cmdCount=${commands.length}, expected 3`);

  const expectedColors = [
    [135, 206, 235, 255],
    [139, 69, 19, 255],
    [255, 215, 0, 255],
  ];
  for (let i = 0; i < commands.length; i++) {
    const command = commands[i];
    assert(command.vertexCount === 4, `cmd[${i}] vertexCount=${command.vertexCount}`);
    assert(command.indexCount === 6, `cmd[${i}] indexCount=${command.indexCount}`);
    const [r, g, b, a] = expectedColors[i];
    assert(
      command.color.r === r &&
        command.color.g === g &&
        command.color.b === b &&
        command.color.a === a,
      `cmd[${i}] color=(${command.color.r},${command.color.g},${command.color.b},${command.color.a}) expected (${r},${g},${b},${a})`,
    );
  }
  console.log("  draw commands: OK (3 cmds, correct colors)");

  for (let frame = 0; frame < 60; frame++) {
    const ptr = allocGuest(exports, 64);
    const bytesWritten = writeInput(memory, ptr);
    if (semanticAbi) {
      kagura_guest_update(ptr, bytesWritten);
      kagura_guest_render();
    } else {
      kagura_update(ptr, bytesWritten);
      kagura_draw();
    }
  }
  console.log("  60 frame cycles: OK");

  const ptr = allocGuest(exports, 68);
  const bytesWritten = writeInput(memory, ptr, { keys: [32] });
  if (semanticAbi) {
    kagura_guest_update(ptr, bytesWritten);
  } else {
    kagura_update(ptr, bytesWritten);
  }
  const drawPtr2 = semanticAbi ? kagura_guest_render() : kagura_draw();
  const commandsAfterSpace = readDrawCommands(memory, drawPtr2);
  assert(commandsAfterSpace.length >= 3, `after space cmdCount=${commandsAfterSpace.length}`);
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
