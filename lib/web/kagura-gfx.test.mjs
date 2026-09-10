import test from "node:test";
import assert from "node:assert/strict";

import {
  installGfxHelpers,
  releaseGpuResources,
  renderGpu,
  setRenderTargetFormat,
  snapshotDrawGeometry,
  registerGeometry,
} from "./kagura-gfx.js";

test("geometry snapshots reuse unchanged data and preserve queued draws across in-place edits", () => {
  const gpu = {};
  const vertices = [0.1, -0, 3], indices = [0, 1, 2];
  const first = snapshotDrawGeometry(gpu, vertices, indices);
  const again = snapshotDrawGeometry(gpu, vertices, indices);
  assert.equal(first.vertexData, again.vertexData);
  assert.equal(first.indices, again.indices);
  vertices[0] = 4;
  indices[2] = 1;
  const changed = snapshotDrawGeometry(gpu, vertices, indices);
  assert.equal(first.vertexData[0], Math.fround(0.1));
  assert.equal(first.indices[2], 2);
  assert.equal(changed.vertexData[0], 4);
  assert.equal(changed.indices[2], 1);
  vertices.push(5);
  assert.equal(snapshotDrawGeometry(gpu, vertices, indices).vertexData.length, 4);
});

test("custom draws upload changed uniforms without uploading unchanged geometry", () => {
  const device = createFakeDevice(), context = createFakeContext(), gpu = createGpu(context);
  const command = createInstancedCustomCommand(1);
  gpu.commands = [command];
  renderGpu(gpu, device, context, [0,0,0,1], "bgra8unorm");
  device.state.writeBufferCount = 0;
  const uniforms = new Int32Array(command.uniformDwords);
  gpu.commands = [{...command, uniformDwords:uniforms}];
  renderGpu(gpu, device, context, [0,0,0,1], "bgra8unorm");
  assert.equal(device.state.writeBufferCount, 0);
  gpu.commands = [{...command, uniformDwords:Int32Array.from(uniforms, v=>v+1)}];
  renderGpu(gpu, device, context, [0,0,0,1], "bgra8unorm");
  assert.equal(device.state.writeBufferCount, 1);
});

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
    boundPipelineFormats: [],
    passes: [],
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
    createRenderPipeline(descriptor) {
      return {
        format: descriptor.fragment.targets[0].format,
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
          state.passes.push(desc);
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
            setPipeline(pipeline) { state.boundPipelineFormats.push(pipeline.format); },
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

test("off-screen HDR format applies to default draws and invalidates sampling views on change", () => {
  const device=createFakeDevice(), context=createFakeContext(), gpu=createGpu(context);
  const hdr={...createInstancedDefaultCommand(1),dstImageId:900,dstWidth:4,dstHeight:4};
  const screen={...createInstancedDefaultCommand(1),dstImageId:0};
  setRenderTargetFormat(gpu,900,"rgba16float");gpu.commands=[hdr,screen];
  assert.equal(renderGpu(gpu,device,context,[0,0,0,1],"bgra8unorm"),true);
  assert.equal(gpu._renderTargets.get(900).format,"rgba16float");
  assert.deepEqual(device.state.boundPipelineFormats,["rgba16float","bgra8unorm"]);
  const previous=gpu.textures.get(900);
  setRenderTargetFormat(gpu,900,"rgba8unorm");gpu.commands=[hdr,screen];
  assert.equal(renderGpu(gpu,device,context,[0,0,0,1],"bgra8unorm"),true);
  assert.equal(gpu._renderTargets.get(900).format,"rgba8unorm");
  assert.notEqual(gpu.textures.get(900).view,previous.view);
  assert.notEqual(gpu.textures.get(900).revision,previous.revision);
  assert.throws(()=>setRenderTargetFormat(gpu,0,"rgba16float"),TypeError);
  assert.throws(()=>setRenderTargetFormat(gpu,900,"depth24plus"),RangeError);
});

test('half-float texture uploads preserve PMREM bytes and reject malformed images before allocation', async () => {
  const {uploadTextureRGBA16F}=await import('./kagura-gfx.js');
  const writes=[],created=[];
  const device={createTexture:d=>{created.push(d);return {createView:()=>({}),destroy(){}}},createSampler:()=>({}),queue:{writeTexture:(...args)=>writes.push(args)}};
  const gpu={device,textures:new Map()},data=new Uint16Array([0x3c00,0x4000,0x4400,0x3c00]);
  uploadTextureRGBA16F(gpu,2000,1,1,data);
  assert.equal(created[0].format,'rgba16float');assert.equal(writes[0][1],data);assert.equal(writes[0][2].bytesPerRow,8);
  const previous=gpu.textures.get(2000);uploadTextureRGBA16F(gpu,2000,1,1,data);
  assert.notEqual(gpu.textures.get(2000).revision,previous.revision);
  assert.throws(()=>uploadTextureRGBA16F(gpu,2000,2,1,data),RangeError);
  assert.equal(created.length,2);
});


test("depth is cleared independently of color and belongs to each render target", () => {
  const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context);
  const clear={...createInstancedDefaultCommand(1),dstImageId:901,dstWidth:320,dstHeight:240};
  const mesh={...createInstancedCustomCommand(1),dstWidth:320,dstHeight:240,
    shaderSource:"struct VertexInput { @location(0) position: vec3<f32>, };",vertexStrideHint:8};
  gpu.commands=[clear,{...mesh,dstImageId:901},{...mesh,dstImageId:900},{...mesh,dstImageId:901},{...createInstancedDefaultCommand(1),dstImageId:0}];
  assert.equal(renderGpu(gpu,device,context,[0,0,0,1],"bgra8unorm"),true);
  const passes=device.state.passes.filter(p=>p.depthStencilAttachment).map(p=>p.depthStencilAttachment);
  assert.deepEqual(passes.map(p=>p.depthLoadOp),["clear","clear","load"]);
  assert.notEqual(passes[0].view,passes[1].view);
  assert.equal(passes[0].view,passes[2].view);
});

test('MSAA resolves each pass, preserves samples across passes, and invalidates resized targets', async () => {
  const {setRenderTargetSampleCount}=await import('./kagura-gfx.js');
  const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context);
  const descriptors=[];const create=device.createRenderPipeline;device.createRenderPipeline=d=>{descriptors.push(d);return create(d)};
  const images=[];const texture=device.createTexture;device.createTexture=d=>{const t=texture(d);images.push({d,t});return t};
  setRenderTargetSampleCount(gpu,900,4);
  const mesh={...createInstancedCustomCommand(1),dstImageId:900,dstWidth:320,dstHeight:240,vertexStrideHint:8,shaderSource:'struct VertexInput { @location(0) position: vec3<f32>, };'};
  const screen={...createInstancedDefaultCommand(1),dstImageId:0};
  gpu.commands=[mesh,{...mesh,dstImageId:901},mesh,screen];
  assert.equal(renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm'),true);
  const resolved=device.state.passes.filter(p=>p.colorAttachments[0].resolveTarget);
  assert.equal(resolved.length,2);assert.equal(resolved[0].colorAttachments[0].view,resolved[1].colorAttachments[0].view);
  assert.equal(resolved[1].colorAttachments[0].loadOp,'load');
  assert.ok(descriptors.some(d=>d.multisample?.count===4&&d.depthStencil));
  assert.ok(images.some(({d})=>d.format==='depth24plus'&&d.sampleCount===4));
  const previous=gpu._renderTargets.get(900);let destroyed=false;previous.msaaTexture.destroy=()=>{destroyed=true};
  gpu.commands=[{...mesh,dstWidth:640},screen];renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  assert.equal(destroyed,true);assert.notEqual(gpu._renderTargets.get(900).view,previous.view);
  assert.throws(()=>setRenderTargetSampleCount(gpu,900,8),RangeError);
});

test('texture color space and wrap modes survive uploads without changing legacy defaults', async()=>{
  const {setTextureOptions,finalizeTextureUpload}=await import('./kagura-gfx.js');
  const device=createFakeDevice(),gpu={device,textures:new Map()},textures=[],samplers=[];
  const create=device.createTexture;device.createTexture=d=>{textures.push(d);return create(d)};
  device.createSampler=d=>{samplers.push(d);return {}};
  setTextureOptions(gpu,10,{format:'rgba8unorm-srgb',addressModeU:'repeat',addressModeV:'mirror-repeat',magFilter:'linear',minFilter:'linear'});
  for(const imageId of [10,11]){gpu._pendingTexture={imageId,width:2,height:1,pixels:new Uint8Array(8)};finalizeTextureUpload(gpu)}
  assert.equal(textures[0].format,'rgba8unorm-srgb');assert.equal(samplers[0].addressModeU,'repeat');assert.equal(samplers[0].magFilter,'linear');
  assert.equal(textures[1].format,'rgba8unorm');assert.equal(samplers[1].magFilter,'nearest');
  setTextureOptions(gpu,10,{format:'rgba8unorm'});
  gpu._pendingTexture={imageId:10,width:2,height:1,pixels:new Uint8Array(8)};finalizeTextureUpload(gpu);
  assert.equal(textures[2].format,'rgba8unorm');
});

test('custom draws bind the sampler belonging to each source texture',()=>{
 const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context),groups=[];
 const original=device.createBindGroup;device.createBindGroup=d=>{groups.push(d);return original(d)};
 const imageSampler={},environmentSampler={};
 gpu.textures=new Map([[10,{view:{},sampler:imageSampler,revision:1}],[20,{view:{},sampler:environmentSampler,revision:1}]]);
 const shaderSource='@group(0) @binding(1) var tex: texture_2d<f32>; @group(0) @binding(2) var s: sampler; @group(0) @binding(3) var env: texture_2d<f32>; @group(0) @binding(4) var es: sampler;';
 gpu.commands=[{...createInstancedCustomCommand(1),shaderSource,srcImageIds:[10,20]}];
 assert.equal(renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm'),true);
 const group=groups.find(g=>g.entries.length===5);
 assert.equal(group.entries.find(e=>e.binding===2).resource,imageSampler);
 assert.equal(group.entries.find(e=>e.binding===4).resource,environmentSampler);
});

test('registered geometry uses explicit revisions, preserves queued generations and unregisters', async () => {
  const {registerGeometry, unregisterGeometry} = await import('./kagura-gfx.js');
  const gpu = {}, vertices = [1,2,3], indices = [0];
  registerGeometry(gpu, 'mesh', 0, vertices, indices);
  const first = snapshotDrawGeometry(gpu, vertices, indices);
  vertices[0] = 4;
  assert.equal(snapshotDrawGeometry(gpu, vertices, indices), first);
  registerGeometry(gpu, 'mesh', 1, vertices, indices);
  const next = snapshotDrawGeometry(gpu, vertices, indices);
  assert.equal(first.vertexData[0], 1);
  assert.equal(next.vertexData[0], 4);
  assert.throws(() => registerGeometry(gpu, 'mesh', 0, vertices, indices), RangeError);
  assert.throws(() => registerGeometry(gpu, 'mesh', 1, [], []), Error);
  assert.throws(() => registerGeometry(gpu, 'other', 0, vertices, indices), Error);
  unregisterGeometry(gpu, 'mesh');
  vertices[0] = 9;
  assert.equal(snapshotDrawGeometry(gpu, vertices, indices).vertexData[0], 9);
});

test('pooled commands keep distinct queued uniforms and upload in-place changes next frame', async () => {
  const {beginDrawFrame, enqueueCustomDraw} = await import('./kagura-gfx.js');
  const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context);
  const command=createInstancedCustomCommand(1);
  beginDrawFrame(gpu);
  const a=enqueueCustomDraw(gpu, command), b=enqueueCustomDraw(gpu, {...command, uniformDwords:new Int32Array([1,2,3,4])});
  assert.notEqual(a.uniformDwords,b.uniformDwords);
  assert.deepEqual([...a.uniformDwords],[0,0,0,0]);
  renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  beginDrawFrame(gpu);
  command.uniformDwords[0]=7;
  const next=enqueueCustomDraw(gpu,command);
  assert.equal(next,a);
  device.state.writeBufferCount=0;
  renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  assert.equal(device.state.writeBufferCount,1);
});

test('immutable snapshots share GPU geometry across draw slots and release buffers', () => {
  const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context);
  const allocated=[];const original=device.createBuffer;
  device.createBuffer=d=>{const buffer=original(d);let destroyed=false;buffer.destroy=()=>{destroyed=true};allocated.push({d,buffer,isDestroyed:()=>destroyed});return buffer};
  const mesh=registerGeometry(gpu,"shared",0,[0,0,0,0,1,0,0,0,0,1,0,0],[0,1,2]);
  const command={...createInstancedCustomCommand(1),...mesh};
  gpu.commands=[command,{...command}];
  renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  assert.equal(allocated.filter(x=>x.d.usage & GPUBufferUsage.VERTEX).length,1);
  assert.equal(allocated.filter(x=>x.d.usage & GPUBufferUsage.INDEX).length,1);
  releaseGpuResources(gpu);
  assert.ok(allocated.every(x=>x.isDestroyed()));
});

test('uniform instancing merges only adjacent compatible opaque draws, preserving each instance', async () => {
  const {instanceUniformShader,beginDrawFrame,enqueueCustomDraw}=await import('./kagura-gfx.js');
  const source=`struct Uniforms { color:vec4<f32>, };
@group(0) @binding(0) var<uniform> uniforms: Uniforms;
struct VertexInput { @location(0) position: vec3<f32>, };
struct VertexOutput { @builtin(position) clip_position: vec4<f32>, };
@vertex fn vs_main(input: VertexInput) -> VertexOutput { var out: VertexOutput; out.clip_position=vec4(input.position,1); return out; }
@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> { return uniforms.color; }`;
  const shaderSource=instanceUniformShader(source,4);
  assert.match(shaderSource, /@builtin\(instance_index\)/);
  assert.match(shaderSource, /@interpolate\(flat\)/);
  const gpu={}, command={...createInstancedCustomCommand(1),shaderSource,blendMode:0,immutableGeometry:true,resourceCacheKey:123};
  beginDrawFrame(gpu);
  for(let i=0;i<35;i++)enqueueCustomDraw(gpu,{...command,uniformDwords:new Int32Array([i,2,3,4])});
  assert.deepEqual(gpu.commands.map(c=>c.instanceCount),[32,3]);
  assert.equal(gpu.commands[0].resourceCacheKey,0,"batch dirtiness must include every record, not just the first resource key");
  assert.equal(gpu.commands[0].uniformDwords[31*4],31);
  assert.equal(gpu.commands[1].uniformDwords[0],32);
  for(const change of [{blendMode:1},{dstImageId:900},{srcImageIds:[7]},{vertexStrideHint:16},{vertexData:new Float32Array(command.vertexData)}])enqueueCustomDraw(gpu,{...command,...change});
  assert.equal(gpu.commands.length,7);
  assert.throws(()=>instanceUniformShader('wrong shader',4),Error);
  assert.throws(()=>instanceUniformShader(source,129),RangeError);
});

test('short-lived legacy geometry does not accumulate shared GPU buffers', () => {
  const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context);
  const allocations=[];const original=device.createBuffer;device.createBuffer=d=>{allocations.push(d);return original(d)};
  for(let i=0;i<10;i++){
    gpu.commands=[{...createInstancedCustomCommand(1),...snapshotDrawGeometry(gpu,[0,0,1,1],[0])}];
    renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  }
  assert.equal(allocations.filter(d=>d.usage & GPUBufferUsage.VERTEX).length,1);
  assert.equal(gpu._sharedGeometryBuffers?.resident.size ?? 0,0);
});

test('batched uniform uploads compare and copy only active records', () => {
  const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context),writes=[];
  const original=device.queue.writeBuffer;device.queue.writeBuffer=(...args)=>{writes.push(args);original(...args)};
  const command={...createInstancedCustomCommand(1),uniformDwords:new Int32Array(128),uniformUsedDwords:4};
  gpu.commands=[command];renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  assert.equal(writes.at(-1)[4],4);
  device.state.writeBufferCount=0;
  command.uniformDwords[127]=7;
  gpu.commands=[command];renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  assert.equal(device.state.writeBufferCount,0);
  command.uniformUsedDwords=128;
  gpu.commands=[command];renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm');
  assert.equal(device.state.writeBufferCount,1);
});

test('bulk draw bridge owns queued data, reuses slots, and observes registered revisions', async()=>{
 const {submitCustomDraw,beginDrawFrame}=await import('./kagura-gfx.js');
 const gpu={}, vertices=[1,2,3,4],indices=[0],uniforms=[3,4,5,6],textures=[10];
 const submit=()=>submitCustomDraw(gpu,1,'@vertex',vertices,indices,uniforms,textures,900,320,240,0,1,8);
 registerGeometry(gpu,'mesh',0,vertices,indices);
 beginDrawFrame(gpu);const a=submit();uniforms[0]=9;textures[0]=20;vertices[0]=7;
 registerGeometry(gpu,'mesh',1,vertices,indices);const b=submit();
 assert.equal(a.uniformDwords[0],3);assert.equal(a.srcImageIds[0],10);assert.equal(a.vertexData[0],1);
 assert.equal(b.uniformDwords[0],9);assert.equal(b.vertexData[0],7);
 beginDrawFrame(gpu);const next=submit();assert.equal(next,a);assert.equal(next.uniformDwords[0],9);
 assert.equal(next.dstWidth,320);assert.equal(next.immutableGeometry,true);
});

test('custom bind groups track actual sampler/view changes even without revision changes',()=>{
 const device=createFakeDevice(),context=createFakeContext(),gpu=createGpu(context),groups=[];
 const original=device.createBindGroup;device.createBindGroup=d=>{groups.push(d);return original(d)};
 const view={},sampler={};gpu.textures.set(10,{view,sampler,revision:1});
 const shaderSource='@binding(1) var tex: texture_2d<f32>; @binding(2) var s: sampler;';
 const cmd={...createInstancedCustomCommand(1),shaderSource,srcImageIds:[10]};
 const draw=()=>{gpu.commands=[cmd];renderGpu(gpu,device,context,[0,0,0,1],'bgra8unorm')};
 draw();const count=groups.length;draw();assert.equal(groups.length,count);
 const nextSampler={};gpu.textures.get(10).sampler=nextSampler;
 draw();assert.equal(groups.length,count+1);assert.equal(groups.at(-1).entries[2].resource,nextSampler);
 const nextView={};gpu.textures.get(10).view=nextView;
 draw();assert.equal(groups.length,count+2);assert.equal(groups.at(-1).entries[1].resource,nextView);
 gpu.textures.delete(10);draw();assert.equal(groups.length,count+3);
 assert.equal(groups.at(-1).entries[1].resource,gpu._defaultTexView);
});
