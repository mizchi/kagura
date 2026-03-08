const textDecoder = new TextDecoder();

export const INIT_ENV_SIZE = 16;

export function serializeInput(memory, ptr, input) {
  const dv = new DataView(memory.buffer);
  dv.setFloat64(ptr, input.cursorX, true);
  dv.setFloat64(ptr + 8, input.cursorY, true);
  dv.setFloat64(ptr + 16, input.wheelX, true);
  dv.setFloat64(ptr + 24, input.wheelY, true);

  const keyCount = input.keys.length;
  dv.setInt32(ptr + 32, keyCount, true);
  for (let i = 0; i < keyCount; i++) {
    dv.setInt32(ptr + 36 + i * 4, input.keys[i], true);
  }

  let offset = ptr + 36 + keyCount * 4;
  const mouseCount = input.mouseButtons.length;
  dv.setInt32(offset, mouseCount, true);
  offset += 4;
  for (let i = 0; i < mouseCount; i++) {
    dv.setInt32(offset + i * 4, input.mouseButtons[i], true);
  }
  offset += mouseCount * 4;

  dv.setInt32(offset, 0, true);
  offset += 4;
  dv.setInt32(offset, 0, true);
  offset += 4;

  return offset - ptr;
}

export function inputByteSize(input) {
  return (
    32 +
    4 +
    input.keys.length * 4 +
    4 +
    input.mouseButtons.length * 4 +
    4 +
    4
  );
}

export function writeInitEnv(
  memory,
  ptr,
  env = { width: 640, height: 480, devicePixelRatio: 1, hotReloadEnabled: true },
) {
  const dv = new DataView(memory.buffer);
  dv.setInt32(ptr, env.width, true);
  dv.setInt32(ptr + 4, env.height, true);
  dv.setFloat32(ptr + 8, env.devicePixelRatio, true);
  dv.setInt32(ptr + 12, env.hotReloadEnabled ? 1 : 0, true);
  return INIT_ENV_SIZE;
}

export function readSemanticGuestConfig(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const width = dv.getInt32(ptr, true);
  const height = dv.getInt32(ptr + 4, true);
  const targetTps = dv.getInt32(ptr + 8, true);
  const titleLen = dv.getInt32(ptr + 12, true);
  const title = textDecoder.decode(
    new Uint8Array(memory.buffer, ptr + 16, titleLen),
  );
  return { width, height, targetTps, title };
}

export function deserializeDrawCommands(memory, ptr) {
  const dv = new DataView(memory.buffer);
  const cmdCount = dv.getInt32(ptr, true);
  const commands = [];
  let offset = ptr + 4;

  for (let i = 0; i < cmdCount; i++) {
    const vertexCount = dv.getInt32(offset, true);
    const indexCount = dv.getInt32(offset + 4, true);
    const srcImageId = dv.getInt32(offset + 8, true);
    const uniformR = dv.getInt32(offset + 12, true) / 255;
    const uniformG = dv.getInt32(offset + 16, true) / 255;
    const uniformB = dv.getInt32(offset + 20, true) / 255;
    const uniformA = dv.getInt32(offset + 24, true) / 255;

    const vertFloatCount = vertexCount * 4;
    const vertByteOffset = offset + 28;
    const vertexData = new Float32Array(
      memory.buffer,
      vertByteOffset,
      vertFloatCount,
    );

    const idxByteOffset = vertByteOffset + vertFloatCount * 4;
    const indices = new Uint32Array(memory.buffer, idxByteOffset, indexCount);

    commands.push({
      vertexData: new Float32Array(vertexData),
      indices: new Uint32Array(indices),
      srcImageId,
      uniformR,
      uniformG,
      uniformB,
      uniformA,
    });

    offset = idxByteOffset + indexCount * 4;
  }

  return commands;
}
