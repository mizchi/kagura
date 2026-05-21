import test from "node:test";
import assert from "node:assert/strict";

import {
  installGfxHelpers,
  releaseGpuResources,
  renderGpu,
} from "./kagura-gfx.js";

globalThis.GPUShaderStage = {
  FRAGMENT: 1,
  VERTEX: 2,
};

globalThis.GPUTextureUsage = {
  TEXTURE_BINDING: 1,
  COPY_DST: 2,
  RENDER_ATTACHMENT: 4,
  COPY_SRC: 8,
};

globalThis.GPUBufferUsage = {
  MAP_READ: 1,
  MAP_WRITE: 2,
  COPY_SRC: 4,
  COPY_DST: 8,
  INDEX: 16,
  VERTEX: 32,
  UNIFORM: 64,
  STORAGE: 128,
  INDIRECT: 256,
  QUERY_RESOLVE: 512,
};

globalThis.GPUMapMode = {
  READ: 1,
};

function encodeTimestampPair(startNs, endNs) {
  const values = new BigUint64Array([BigInt(startNs), BigInt(endNs)]);
  return values.buffer.slice(0);
}

function createFakeDevice(options = {}) {
  const state = {
    copyTextureToBufferCount: 0,
    lastDrawIndexedArgs: null,
    timestampWrites: [],
    writeBufferCount: 0,
  };
  const queue = {
    writeTexture() {},
    submit() {},
    writeBuffer() {
      state.writeBufferCount += 1;
    },
    onSubmittedWorkDone() {
      return Promise.resolve();
    },
  };
  return {
    state,
    queue,
    createShaderModule() {
      return {
        getCompilationInfo() {
          return Promise.resolve({ messages: [] });
        },
      };
    },
    createBindGroupLayout() {
      return {};
    },
    createPipelineLayout() {
      return {};
    },
    createRenderPipeline() {
      return {
        getBindGroupLayout() {
          return {};
        },
      };
    },
    createTexture() {
      return {
        createView() {
          return {};
        },
        destroy() {},
      };
    },
    createBuffer({ size }) {
      return {
        _data: new ArrayBuffer(size),
        mapAsync() {
          if (options.deferMapAsync === true) {
            return new Promise(() => {});
          }
          return Promise.resolve();
        },
        getMappedRange() {
          return this._data.slice(0);
        },
        unmap() {},
        destroy() {},
      };
    },
    createQuerySet() {
      return {};
    },
    createBindGroup() {
      return {};
    },
    createSampler() {
      return {};
    },
    createCommandEncoder() {
      return {
        beginRenderPass(desc = {}) {
          const timestampWrites = desc.timestampWrites;
          if (timestampWrites?.beginningOfPassWriteIndex != null) {
            state.timestampWrites.push({
              querySet: timestampWrites.querySet,
              index: timestampWrites.beginningOfPassWriteIndex,
            });
          }
          if (timestampWrites?.endOfPassWriteIndex != null) {
            state.timestampWrites.push({
              querySet: timestampWrites.querySet,
              index: timestampWrites.endOfPassWriteIndex,
            });
          }
          return {
            end() {},
            setPipeline() {},
            setBindGroup() {},
            setVertexBuffer() {},
            setIndexBuffer() {},
            drawIndexed(...args) {
              state.lastDrawIndexedArgs = args;
            },
          };
        },
        resolveQuerySet(querySet, firstQuery, queryCount, dstBuffer) {
          const startNs = BigInt(options.timestampStartNs ?? 1_000_000);
          const durationNs = BigInt(options.timestampDurationNs ?? 0);
          dstBuffer._data = encodeTimestampPair(startNs, startNs + durationNs);
        },
        copyBufferToBuffer(srcBuffer, _srcOffset, dstBuffer) {
          dstBuffer._data = srcBuffer._data.slice(0);
        },
        copyTextureToBuffer() {
          state.copyTextureToBufferCount += 1;
        },
        finish() {
          return {};
        },
      };
    },
    features: {
      has(name) {
        return Array.isArray(options.features) && options.features.includes(name);
      },
    },
  };
}

function createFakeContext() {
  const state = {
    configureCount: 0,
    lastUsage: 0,
    unconfigureCount: 0,
    lastFormat: "",
  };
  return {
    state,
    configure({ format, usage }) {
      state.configureCount += 1;
      state.lastFormat = format;
      state.lastUsage = usage ?? 0;
    },
    unconfigure() {
      state.unconfigureCount += 1;
    },
    getCurrentTexture() {
      return {
        width: 320,
        height: 240,
        createView() {
          return {};
        },
      };
    },
  };
}

function createGpu(context) {
  return {
    context,
    commands: [],
    textures: new Map(),
  };
}

function createInstancedDefaultCommand(instanceCount) {
  return {
    vertexData: new Float32Array([
      -0.8, 0.7, 0.0, 0.0,
      -0.2, -0.6, 1.0, 0.0,
      0.9, -0.3, 1.0, 1.0,
    ]),
    indices: new Uint32Array([0, 1, 2]),
    srcImageId: 0,
    uniformR: 1,
    uniformG: 1,
    uniformB: 1,
    uniformA: 1,
    instanceCount,
  };
}

function createCachedDefaultCommand(resourceCacheKey) {
  return {
    vertexData: new Float32Array([
      -0.8, 0.7, 0.0, 0.0,
      -0.2, -0.6, 1.0, 0.0,
      0.9, -0.3, 1.0, 1.0,
    ]),
    indices: new Uint32Array([0, 1, 2]),
    srcImageId: 0,
    uniformR: 1,
    uniformG: 1,
    uniformB: 1,
    uniformA: 1,
    instanceCount: 1,
    resourceCacheKey,
  };
}

function createInstancedCustomCommand(instanceCount) {
  return {
    isCustom: true,
    shaderId: 1,
    shaderSource: `
struct Uniforms { color: vec4f }
@group(0) @binding(0) var<uniform> uniforms: Uniforms;
struct VertexOutput {
  @builtin(position) position: vec4f,
}
@vertex fn vs_main(@location(0) pos: vec2f, @location(1) uv: vec2f) -> VertexOutput {
  var out: VertexOutput;
  out.position = vec4f(pos, 0.0, 1.0);
  return out;
}
@fragment fn fs_main() -> @location(0) vec4f {
  return uniforms.color;
}`,
    vertexData: new Float32Array([
      -0.8, 0.7, 0.0, 0.0,
      -0.2, -0.6, 1.0, 0.0,
      0.9, -0.3, 1.0, 1.0,
    ]),
    indices: new Uint32Array([0, 1, 2]),
    uniformDwords: new Int32Array([0, 0, 0, 0]),
    srcImageIds: new Int32Array(0),
    dstImageId: 0,
    dstWidth: 320,
    dstHeight: 240,
    blendMode: 1,
    instanceCount,
  };
}

test("renderGpu does not reconfigure context every frame when format is unchanged", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);

  assert.equal(context.state.configureCount, 1);
});

test("renderGpu configures canvas textures for readback when COPY_SRC is available", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);

  assert.equal(
    context.state.lastUsage,
    GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC,
  );
});

test("installGfxHelpers controls VRT readback and avoids duplicate pending copies", () => {
  delete globalThis.__kaguraVrtLastReadback;
  installGfxHelpers();
  const device = createFakeDevice({ deferMapAsync: true });
  const context = createFakeContext();
  const gpu = createGpu(context);
  globalThis.__kaguraGfx.configureVrtReadback(true);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.copyTextureToBufferCount, 1);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.copyTextureToBufferCount, 1);

  globalThis.__kaguraGfx.configureVrtReadback(false);
});

test("renderGpu reconfigures context when format changes", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "rgba8unorm"), true);

  assert.equal(context.state.configureCount, 2);
  assert.equal(context.state.lastFormat, "rgba8unorm");
});

test("releaseGpuResources resets configured format cache", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  releaseGpuResources(gpu);
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);

  assert.equal(context.state.unconfigureCount, 1);
  assert.equal(context.state.configureCount, 2);
});

test("renderGpu forwards instanceCount for default draw commands", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);
  gpu.commands = [createInstancedDefaultCommand(4)];

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.deepEqual(device.state.lastDrawIndexedArgs, [3, 4]);
});

test("renderGpu forwards instanceCount for custom draw commands", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);
  gpu.commands = [createInstancedCustomCommand(4)];

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.deepEqual(device.state.lastDrawIndexedArgs, [3, 4]);
});

test("renderGpu skips default buffer uploads when draw command references are unchanged", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);
  const command = createInstancedDefaultCommand(1);
  gpu.commands = [command];

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.writeBufferCount, 3);

  device.state.writeBufferCount = 0;
  gpu.commands = [command];
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.writeBufferCount, 0);
});

test("renderGpu skips custom buffer uploads when non-skinned draw command references are unchanged", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);
  const command = createInstancedCustomCommand(1);
  gpu.commands = [command];

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.writeBufferCount, 3);

  device.state.writeBufferCount = 0;
  gpu.commands = [command];
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.writeBufferCount, 0);
});

test("renderGpu skips default buffer uploads when resourceCacheKey is unchanged", () => {
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);

  gpu.commands = [createCachedDefaultCommand(42)];
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.writeBufferCount, 3);

  device.state.writeBufferCount = 0;
  gpu.commands = [createCachedDefaultCommand(42)];
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  assert.equal(device.state.writeBufferCount, 0);
});

test("installGfxHelpers exposes latest completed GPU frame time", async () => {
  const originalPerformance = globalThis.performance;
  globalThis.performance = {
    now: (() => {
      const samples = [10, 13, 16, 19, 20, 22, 28];
      return () => samples.shift() ?? 28;
    })(),
  };
  installGfxHelpers();
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);
  gpu.commands = [createInstancedDefaultCommand(1)];

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  await Promise.resolve();

  assert.equal(typeof globalThis.__kaguraGfx.lastCompletedFrameMs, "function");
  assert.equal(globalThis.__kaguraGfx.lastCompletedFrameMs(), 6);
  globalThis.performance = originalPerformance;
});

test("installGfxHelpers exposes queued GPU frame timings for consumption", async () => {
  const originalPerformance = globalThis.performance;
  globalThis.performance = {
    now: (() => {
      const samples = [10, 13, 16, 19, 20, 22, 33, 40, 43, 46, 49, 50, 52, 65];
      return () => samples.shift() ?? 65;
    })(),
  };
  installGfxHelpers();
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);

  gpu.commands = [createInstancedDefaultCommand(1)];
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  await Promise.resolve();
  gpu.commands = [createInstancedDefaultCommand(1)];
  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  await Promise.resolve();

  assert.equal(typeof globalThis.__kaguraGfx.consumeCompletedFrameMs, "function");
  assert.equal(globalThis.__kaguraGfx.consumeCompletedFrameMs(), 11);
  assert.equal(globalThis.__kaguraGfx.consumeCompletedFrameMs(), 13);
  assert.equal(globalThis.__kaguraGfx.consumeCompletedFrameMs(), -1);
  globalThis.performance = originalPerformance;
});

test("installGfxHelpers consumes timestamp query GPU frame timings when available", async () => {
  installGfxHelpers();
  const device = createFakeDevice({
    features: ["timestamp-query"],
    timestampStartNs: 10_000_000,
    timestampDurationNs: 2_500_000,
  });
  const context = createFakeContext();
  const gpu = createGpu(context);
  gpu.commands = [createInstancedDefaultCommand(1)];

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  await Promise.resolve();
  await Promise.resolve();

  assert.equal(typeof globalThis.__kaguraGfx.consumeGpuFrameMs, "function");
  assert.equal(globalThis.__kaguraGfx.consumeGpuFrameMs(), 2.5);
  assert.equal(globalThis.__kaguraGfx.lastTimestampRawDeltaNs(), "2500000");
  assert.equal(globalThis.__kaguraGfx.gpuTimingMethod(), "timestamp-query");
  assert.deepEqual(
    device.state.timestampWrites.map((entry) => entry.index),
    [0, 1],
  );
});

test("installGfxHelpers exposes render CPU encode and submit timing split", async () => {
  const originalPerformance = globalThis.performance;
  globalThis.performance = {
    now: (() => {
      const samples = [10, 13, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 52, 60];
      return () => samples.shift() ?? 60;
    })(),
  };
  installGfxHelpers();
  const device = createFakeDevice();
  const context = createFakeContext();
  const gpu = createGpu(context);
  gpu.commands = [createInstancedDefaultCommand(1)];
  globalThis.__kaguraGfx.configureDetailedCpuTiming(true);

  assert.equal(renderGpu(gpu, device, context, [0, 0, 0, 1], "bgra8unorm"), true);
  await Promise.resolve();

  assert.equal(globalThis.__kaguraGfx.lastRenderUploadCpuMs(), 6);
  assert.equal(globalThis.__kaguraGfx.lastRenderBindGroupCpuMs(), 4);
  assert.equal(globalThis.__kaguraGfx.lastRenderPassEncodeCpuMs(), 2);
  assert.equal(globalThis.__kaguraGfx.lastRenderAcquireCpuMs(), 3);
  assert.equal(globalThis.__kaguraGfx.lastRenderPassSetupCpuMs(), 3);
  assert.equal(globalThis.__kaguraGfx.lastRenderDrawEncodeCpuMs(), 26);
  assert.equal(globalThis.__kaguraGfx.lastRenderCleanupCpuMs(), 0);
  assert.equal(globalThis.__kaguraGfx.lastRenderEncodeCpuMs(), 34);
  assert.equal(globalThis.__kaguraGfx.lastRenderSubmitCpuMs(), 8);
  assert.equal(globalThis.__kaguraGfx.lastRenderCpuMs(), 42);
  globalThis.performance = originalPerformance;
});
