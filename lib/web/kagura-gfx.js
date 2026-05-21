// Shared GFX/WebGPU backend for kagura — used by both JS-target (via globalThis.__kaguraGfx)
// and WASM-target (via ES module import)

const SHADER_CODE = `
struct Uniforms { color: vec4f }
@group(0) @binding(0) var<uniform> uniforms: Uniforms;
@group(1) @binding(0) var tex: texture_2d<f32>;
@group(1) @binding(1) var tex_sampler: sampler;
struct VertexOutput {
  @builtin(position) position: vec4f,
  @location(0) uv: vec2f,
}
@vertex fn vs_main(@location(0) pos: vec2f, @location(1) uv: vec2f) -> VertexOutput {
  var out: VertexOutput;
  out.position = vec4f(pos, 0.0, 1.0);
  out.uv = uv;
  return out;
}
@fragment fn fs_main(input: VertexOutput) -> @location(0) vec4f {
  let tex_color = textureSample(tex, tex_sampler, input.uv);
  return tex_color * uniforms.color;
}`;

// --- Shader source parsing helpers ---

function isStride32(source) {
  return /position\s*:\s*vec3<f32>/.test(source);
}

function isStride64(source) {
  return isStride32(source) &&
    /joints\s*:\s*vec4<f32>/.test(source) &&
    /weights\s*:\s*vec4<f32>/.test(source);
}

function is3DShader(source) {
  return isStride32(source) || isStride64(source);
}

function parseTextureBindings(source) {
  const results = [];
  const re = /@binding\((\d+)\)\s+var\s+\w+\s*:\s*(texture_2d<f32>|texture_2d|sampler)/g;
  let m;
  while ((m = re.exec(source)) !== null) {
    const binding = parseInt(m[1], 10);
    const raw = m[2];
    const type = raw.startsWith("texture") ? "texture" : "sampler";
    results.push({ binding, type });
  }
  results.sort((a, b) => a.binding - b.binding);
  return results;
}

function getInstanceCount(cmd) {
  const raw = cmd == null ? null : (cmd.instanceCount ?? cmd.instance_count);
  if (!Number.isFinite(raw)) return 1;
  return Math.max(1, raw | 0);
}

function getResourceCacheKey(cmd) {
  const raw = cmd == null ? null : (cmd.resourceCacheKey ?? cmd.resource_cache_key);
  if (!Number.isFinite(raw)) return 0;
  return raw | 0;
}

function performanceNow() {
  return globalThis.performance?.now?.() ?? Date.now();
}

function recordCompletedFrameMs(gpu, frameMs) {
  const safeFrameMs = Math.max(0, frameMs);
  gpu._lastCompletedFrameMs = safeFrameMs;
  if (gpu._completedFrameMsQueue == null) gpu._completedFrameMsQueue = [];
  gpu._completedFrameMsQueue.push(safeFrameMs);
  if (gpu._completedFrameMsQueue.length > 120) {
    gpu._completedFrameMsQueue.shift();
  }
}

function consumeCompletedFrameMs(gpu) {
  if (gpu == null || gpu._completedFrameMsQueue == null || gpu._completedFrameMsQueue.length === 0) {
    return -1;
  }
  return gpu._completedFrameMsQueue.shift();
}

function recordTimestampFrameMs(gpu, frameMs) {
  const safeFrameMs = Math.max(0, frameMs);
  gpu._lastTimestampFrameMs = safeFrameMs;
  if (gpu._timestampFrameMsQueue == null) gpu._timestampFrameMsQueue = [];
  gpu._timestampFrameMsQueue.push(safeFrameMs);
  if (gpu._timestampFrameMsQueue.length > 120) {
    gpu._timestampFrameMsQueue.shift();
  }
}

function recordTimestampRawDeltaNs(gpu, deltaNs) {
  gpu._lastTimestampRawDeltaNs = deltaNs;
}

function recordRenderCpuMetrics(gpu, encodeCpuMs, submitCpuMs) {
  gpu._lastRenderEncodeCpuMs = Math.max(0, encodeCpuMs);
  gpu._lastRenderSubmitCpuMs = Math.max(0, submitCpuMs);
  gpu._lastRenderCpuMs = gpu._lastRenderEncodeCpuMs + gpu._lastRenderSubmitCpuMs;
}

function recordRenderCpuStageMetrics(
  gpu,
  acquireCpuMs,
  passSetupCpuMs,
  drawEncodeCpuMs,
  cleanupCpuMs,
) {
  gpu._lastRenderAcquireCpuMs = Math.max(0, acquireCpuMs);
  gpu._lastRenderPassSetupCpuMs = Math.max(0, passSetupCpuMs);
  gpu._lastRenderDrawEncodeCpuMs = Math.max(0, drawEncodeCpuMs);
  gpu._lastRenderCleanupCpuMs = Math.max(0, cleanupCpuMs);
}

function recordRenderDrawBreakdownMetrics(
  gpu,
  uploadCpuMs,
  bindGroupCpuMs,
  passEncodeCpuMs,
) {
  gpu._lastRenderUploadCpuMs = Math.max(0, uploadCpuMs);
  gpu._lastRenderBindGroupCpuMs = Math.max(0, bindGroupCpuMs);
  gpu._lastRenderPassEncodeCpuMs = Math.max(0, passEncodeCpuMs);
}

function consumeTimestampFrameMs(gpu) {
  if (gpu == null || gpu._timestampFrameMsQueue == null || gpu._timestampFrameMsQueue.length === 0) {
    return -1;
  }
  return gpu._timestampFrameMsQueue.shift();
}

function hasFeature(features, featureName) {
  if (features == null) return false;
  if (typeof features.has === "function") {
    return features.has(featureName);
  }
  if (Array.isArray(features)) {
    return features.includes(featureName);
  }
  return false;
}

function copyMappedRange(range) {
  if (range instanceof ArrayBuffer) {
    return range.slice(0);
  }
  if (ArrayBuffer.isView(range)) {
    return range.buffer.slice(range.byteOffset, range.byteOffset + range.byteLength);
  }
  return null;
}

function configureCanvasContext(context, device, format) {
  const descriptor = { device, format, alphaMode: "opaque" };
  if (globalThis.GPUTextureUsage?.COPY_SRC != null) {
    descriptor.usage =
      globalThis.GPUTextureUsage.RENDER_ATTACHMENT | globalThis.GPUTextureUsage.COPY_SRC;
  }
  context.configure(descriptor);
}

function queueVrtFrameReadback(gpu, device, encoder, texture, format) {
  if (globalThis.__kaguraVrtReadbackEnabled !== true) return null;
  if (
    texture == null ||
    typeof encoder.copyTextureToBuffer !== "function" ||
    typeof device.createBuffer !== "function" ||
    typeof GPUBufferUsage === "undefined" ||
    typeof GPUMapMode === "undefined" ||
    !Number.isFinite(GPUBufferUsage.COPY_DST) ||
    !Number.isFinite(GPUBufferUsage.MAP_READ)
  ) {
    return null;
  }
  const runtime = globalThis.__kaguraWebRuntime;
  const width = Math.max(1, Number(texture.width ?? runtime?.width ?? 0) | 0);
  const height = Math.max(1, Number(texture.height ?? runtime?.height ?? 0) | 0);
  const unpaddedBytesPerRow = width * 4;
  const bytesPerRow = Math.ceil(unpaddedBytesPerRow / 256) * 256;
  const buffer = device.createBuffer({
    size: bytesPerRow * height,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
  });
  encoder.copyTextureToBuffer(
    { texture },
    { buffer, bytesPerRow, rowsPerImage: height },
    { width, height },
  );
  const id = (gpu._vrtReadbackId ?? 0) + 1;
  gpu._vrtReadbackId = id;
  gpu._vrtReadbackPending = true;
  return { id, buffer, width, height, bytesPerRow, format };
}

function summarizeVrtFrameReadback(readback, copied) {
  if (copied == null) return null;
  const data = new Uint8Array(copied);
  const isBgra = typeof readback.format === "string" && readback.format.startsWith("bgra");
  let nonTransparent = 0;
  let nonDark = 0;
  let maxChannel = 0;
  let firstPixelRgba = null;
  for (let y = 0; y < readback.height; y += 1) {
    const row = y * readback.bytesPerRow;
    for (let x = 0; x < readback.width; x += 1) {
      const offset = row + x * 4;
      const c0 = data[offset] ?? 0;
      const c1 = data[offset + 1] ?? 0;
      const c2 = data[offset + 2] ?? 0;
      const a = data[offset + 3] ?? 0;
      const r = isBgra ? c2 : c0;
      const g = c1;
      const b = isBgra ? c0 : c2;
      if (firstPixelRgba == null) firstPixelRgba = [r, g, b, a];
      if (a > 0) nonTransparent += 1;
      if (a > 0 && r + g + b > 30) nonDark += 1;
      maxChannel = Math.max(maxChannel, r, g, b, a);
    }
  }
  const total = readback.width * readback.height;
  return {
    id: readback.id,
    width: readback.width,
    height: readback.height,
    format: readback.format,
    firstPixelRgba,
    maxChannel,
    nonTransparent,
    nonDark,
    nonTransparentPixelRatio: total > 0 ? nonTransparent / total : 0,
    nonDarkPixelRatio: total > 0 ? nonDark / total : 0,
  };
}

function scheduleVrtFrameReadback(gpu, readback) {
  if (readback == null || readback.buffer == null) return;
  const pending = readback.buffer.mapAsync(GPUMapMode.READ);
  if (pending == null || typeof pending.then !== "function") {
    gpu._vrtReadbackPending = false;
    return;
  }
  pending.then(() => {
    const mappedRange = readback.buffer.getMappedRange?.();
    const copied = copyMappedRange(mappedRange);
    try {
      readback.buffer.unmap?.();
    } catch (_) {}
    try {
      readback.buffer.destroy?.();
    } catch (_) {}
    const summary = summarizeVrtFrameReadback(readback, copied);
    if (summary != null && gpu._vrtReadbackId === readback.id) {
      gpu._vrtLastReadback = summary;
      globalThis.__kaguraVrtLastReadback = summary;
    }
    gpu._vrtReadbackPending = false;
  }).catch(() => {
    try {
      readback.buffer.unmap?.();
    } catch (_) {}
    try {
      readback.buffer.destroy?.();
    } catch (_) {}
    gpu._vrtReadbackPending = false;
  });
}

function canUseTimestampQueries(device) {
  return (
    device != null &&
    hasFeature(device.features, "timestamp-query") &&
    typeof device.createQuerySet === "function" &&
    typeof GPUBufferUsage !== "undefined" &&
    typeof GPUMapMode !== "undefined" &&
    Number.isFinite(GPUBufferUsage.QUERY_RESOLVE) &&
    Number.isFinite(GPUBufferUsage.COPY_SRC) &&
    Number.isFinite(GPUBufferUsage.COPY_DST) &&
    Number.isFinite(GPUBufferUsage.MAP_READ)
  );
}

function ensureTimestampQueryState(gpu, device) {
  if (gpu._timestampQueryStateInitialized === true) {
    return gpu._timestampQueryState ?? null;
  }
  gpu._timestampQueryStateInitialized = true;
  if (!canUseTimestampQueries(device)) {
    gpu._gpuTimingMethod = "queue-completion";
    gpu._timestampQueryState = null;
    return null;
  }
  const slots = [];
  for (let i = 0; i < 4; i += 1) {
    slots.push({
      querySet: device.createQuerySet({ type: "timestamp", count: 2 }),
      resolveBuffer: device.createBuffer({
        size: 16,
        usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC,
      }),
      readBuffer: device.createBuffer({
        size: 16,
        usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
      }),
      pending: false,
    });
  }
  gpu._gpuTimingMethod = "timestamp-query";
  gpu._timestampQueryState = {
    slots,
    nextSlot: 0,
  };
  return gpu._timestampQueryState;
}

function reserveTimestampQuerySlot(gpu, device) {
  const state = ensureTimestampQueryState(gpu, device);
  if (state == null) {
    return null;
  }
  for (let step = 0; step < state.slots.length; step += 1) {
    const slotIndex = (state.nextSlot + step) % state.slots.length;
    const slot = state.slots[slotIndex];
    if (slot.pending) continue;
    slot.pending = true;
    state.nextSlot = (slotIndex + 1) % state.slots.length;
    return slot;
  }
  return null;
}

function buildPassTimestampWrites(slot, writeStart, writeEnd) {
  if (slot == null || (!writeStart && !writeEnd)) {
    return undefined;
  }
  const timestampWrites = {
    querySet: slot.querySet,
  };
  if (writeStart) {
    timestampWrites.beginningOfPassWriteIndex = 0;
  }
  if (writeEnd) {
    timestampWrites.endOfPassWriteIndex = 1;
  }
  return timestampWrites;
}

function resolveTimestampQuery(encoder, slot) {
  if (
    slot == null ||
    typeof encoder.resolveQuerySet !== "function" ||
    typeof encoder.copyBufferToBuffer !== "function"
  ) {
    if (slot != null) slot.pending = false;
    return;
  }
  encoder.resolveQuerySet(slot.querySet, 0, 2, slot.resolveBuffer, 0);
  encoder.copyBufferToBuffer(slot.resolveBuffer, 0, slot.readBuffer, 0, 16);
}

function countRenderPasses(drawCommands) {
  let passCount = 0;
  let lastTargetId = 0;
  let lastNeedsDepth = false;
  for (let i = 0; i < drawCommands.length; i += 1) {
    const cmd = drawCommands[i];
    const targetId = cmd.dstImageId | 0;
    const needsDepth = cmd.isCustom && is3DShader(cmd.shaderSource);
    if (passCount === 0 || targetId !== lastTargetId || needsDepth !== lastNeedsDepth) {
      passCount += 1;
      lastTargetId = targetId;
      lastNeedsDepth = needsDepth;
    }
  }
  return passCount;
}

function scheduleTimestampReadback(gpu, slot) {
  if (slot == null || slot.readBuffer == null || typeof slot.readBuffer.mapAsync !== "function") {
    if (slot != null) slot.pending = false;
    return;
  }
  const pending = slot.readBuffer.mapAsync(GPUMapMode.READ);
  if (pending == null || typeof pending.then !== "function") {
    slot.pending = false;
    return;
  }
  pending.then(() => {
    const mappedRange = slot.readBuffer.getMappedRange?.();
    const copied = copyMappedRange(mappedRange);
    try {
      slot.readBuffer.unmap?.();
    } catch (_) {}
    slot.pending = false;
    if (copied == null || copied.byteLength < 16) return;
    const values = new BigUint64Array(copied);
    if (values.length < 2) return;
    const startNs = values[0];
    const endNs = values[1];
    if (endNs <= startNs) return;
    recordTimestampRawDeltaNs(gpu, (endNs - startNs).toString());
    recordTimestampFrameMs(gpu, Number(endNs - startNs) / 1_000_000);
  }).catch(() => {
    try {
      slot.readBuffer.unmap?.();
    } catch (_) {}
    slot.pending = false;
  });
}

function consumeGpuFrameMs(gpu) {
  const timestampFrameMs = consumeTimestampFrameMs(gpu);
  if (timestampFrameMs >= 0) {
    return timestampFrameMs;
  }
  return consumeCompletedFrameMs(gpu);
}

function createDrawEncodeBreakdown(enabled) {
  return {
    enabled,
    uploadCpuMs: 0,
    bindGroupCpuMs: 0,
    passEncodeCpuMs: 0,
  };
}

function measureDrawBreakdown(breakdown, key, fn) {
  if (breakdown == null || breakdown.enabled !== true) {
    return fn();
  }
  const start = performanceNow();
  const result = fn();
  breakdown[key] += performanceNow() - start;
  return result;
}

function createDrawResourceCache() {
  return {
    vertexBuffers: [],
    indexBuffers: [],
    uniformBuffers: [],
    uniformBindGroups: [],
    uniformBindBuffers: [],
    textureBindGroups: [],
    textureBindImageIds: [],
    textureBindRevisions: [],
    vertexDataRefs: [],
    vertexDataSizes: [],
    indexDataRefs: [],
    indexDataSizes: [],
    uniformColorKeys: [],
    resourceCacheKeys: [],
    customVertexBuffers: [],
    customVertexDataRefs: [],
    customVertexDataSizes: [],
    customIndexBuffers: [],
    customIndexDataRefs: [],
    customIndexDataSizes: [],
    customUniformBuffers: [],
    customUniformDataRefs: [],
    customUniformDataSizes: [],
    customBindGroups: [],
    customBindLayouts: [],
    customBindUniformBuffers: [],
    customBindTextureKeys: [],
    customResourceCacheKeys: [],
  };
}

function submitEncodedFrame(
  gpu,
  device,
  encoder,
  timestampSlot,
  renderCpuStart,
  stageMetrics,
  cleanupBuffers = null,
  readback = null,
) {
  const frameSubmitStart = performanceNow();
  device.queue.submit([encoder.finish()]);
  scheduleTimestampReadback(gpu, timestampSlot);
  scheduleVrtFrameReadback(gpu, readback);
  const frameSubmitEnd = performanceNow();
  let cleanupCpuMs = 0;
  if (Array.isArray(cleanupBuffers) && cleanupBuffers.length > 0) {
    const cleanupStart = performanceNow();
    for (let i = 0; i < cleanupBuffers.length; i += 1) {
      const buffer = cleanupBuffers[i];
      if (buffer != null && typeof buffer.destroy === "function") {
        try { buffer.destroy(); } catch (_) {}
      }
    }
    cleanupCpuMs = performanceNow() - cleanupStart;
  }
  recordRenderCpuStageMetrics(
    gpu,
    stageMetrics.acquireCpuMs ?? 0,
    stageMetrics.passSetupCpuMs ?? 0,
    stageMetrics.drawEncodeCpuMs ?? Math.max(0, frameSubmitStart - renderCpuStart),
    cleanupCpuMs,
  );
  recordRenderCpuMetrics(
    gpu,
    frameSubmitStart - renderCpuStart,
    frameSubmitEnd - frameSubmitStart,
  );
  const submitted = device.queue?.onSubmittedWorkDone?.();
  if (submitted != null && typeof submitted.then === "function") {
    submitted.then(() => {
      recordCompletedFrameMs(gpu, performanceNow() - frameSubmitEnd);
    }).catch(() => {});
  }
}

// --- Custom pipeline creation & caching ---

function getOrCreateCustomPipeline(gpu, device, cmd, format) {
  if (gpu._customPipelines == null) gpu._customPipelines = new Map();
  const key = `${cmd.shaderId}_${format}_${cmd.blendMode}`;
  const cached = gpu._customPipelines.get(key);
  if (cached != null) return cached;

  const shaderModule = device.createShaderModule({ code: cmd.shaderSource });
  shaderModule.getCompilationInfo().then(info => {
    for (const msg of info.messages) {
      if (msg.type === "error") console.error(`[WGSL ${msg.type}] shader=${cmd.shaderId} line=${msg.lineNum}: ${msg.message}`);
    }
  });
  // Use explicit stride hint when available, fall back to shader regex detection
  const hint = cmd.vertexStrideHint || 0;
  const stride64 = hint > 0 ? hint >= 16 : isStride64(cmd.shaderSource);
  const stride32 = hint > 0 ? hint >= 8 : isStride32(cmd.shaderSource);
  const is3D = hint > 0 ? hint >= 8 : is3DShader(cmd.shaderSource);

  let vertexBufferLayout;
  if (stride64) {
    // Skinned 3D vertex: position(vec3f)+normal(vec3f)+uv(vec2f)+joints(vec4f)+weights(vec4f) = 64 bytes
    vertexBufferLayout = {
      arrayStride: 64,
      attributes: [
        { shaderLocation: 0, offset: 0, format: "float32x3" },
        { shaderLocation: 1, offset: 12, format: "float32x3" },
        { shaderLocation: 2, offset: 24, format: "float32x2" },
        { shaderLocation: 3, offset: 32, format: "float32x4" },
        { shaderLocation: 4, offset: 48, format: "float32x4" },
      ],
    };
  } else if (stride32) {
    // 3D vertex: position(vec3f) + normal(vec3f) + uv(vec2f) = 32 bytes
    vertexBufferLayout = {
      arrayStride: 32,
      attributes: [
        { shaderLocation: 0, offset: 0, format: "float32x3" },
        { shaderLocation: 1, offset: 12, format: "float32x3" },
        { shaderLocation: 2, offset: 24, format: "float32x2" },
      ],
    };
  } else {
    // 2D vertex: position(vec2f) + uv(vec2f) = 16 bytes
    vertexBufferLayout = {
      arrayStride: 16,
      attributes: [
        { shaderLocation: 0, offset: 0, format: "float32x2" },
        { shaderLocation: 1, offset: 8, format: "float32x2" },
      ],
    };
  }

  let blend = undefined;
  if (cmd.blendMode === 0) {
    // Copy: no blending
    blend = {
      color: { srcFactor: "one", dstFactor: "zero", operation: "add" },
      alpha: { srcFactor: "one", dstFactor: "zero", operation: "add" },
    };
  } else if (cmd.blendMode === 1) {
    // Alpha blend
    blend = {
      color: { srcFactor: "src-alpha", dstFactor: "one-minus-src-alpha", operation: "add" },
      alpha: { srcFactor: "one", dstFactor: "one-minus-src-alpha", operation: "add" },
    };
  } else if (cmd.blendMode === 2) {
    // Additive
    blend = {
      color: { srcFactor: "src-alpha", dstFactor: "one", operation: "add" },
      alpha: { srcFactor: "one", dstFactor: "one", operation: "add" },
    };
  }

  const pipelineDesc = {
    layout: "auto",
    vertex: {
      module: shaderModule,
      entryPoint: "vs_main",
      buffers: [vertexBufferLayout],
    },
    fragment: {
      module: shaderModule,
      entryPoint: "fs_main",
      targets: [{ format, blend }],
    },
    primitive: {
      topology: "triangle-list",
      cullMode: is3D ? "back" : "none",
    },
  };

  if (is3D) {
    pipelineDesc.depthStencil = {
      format: "depth24plus",
      depthWriteEnabled: true,
      depthCompare: "less",
    };
  }

  const pipeline = device.createRenderPipeline(pipelineDesc);
  const bgl = pipeline.getBindGroupLayout(0);

  const result = { pipeline, bindGroupLayout: bgl, stride32: is3D };
  gpu._customPipelines.set(key, result);
  return result;
}

// --- Render target management ---

function ensureRenderTarget(gpu, device, imageId, width, height) {
  if (gpu._renderTargets == null) gpu._renderTargets = new Map();
  const key = imageId;
  const existing = gpu._renderTargets.get(key);
  if (existing != null && existing.width === width && existing.height === height) {
    return existing;
  }
  if (existing != null && existing.texture != null) {
    try { existing.texture.destroy(); } catch (_) {}
  }
  const texture = device.createTexture({
    size: { width, height },
    format: "rgba8unorm",
    usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_DST,
  });
  const view = texture.createView();
  const entry = { texture, view, width, height };
  gpu._renderTargets.set(key, entry);
  // Also register in gpu.textures so subsequent passes can sample it
  if (gpu.textures == null) gpu.textures = new Map();
  const sampler = gpu._linearSampler || gpu._defaultSampler;
  gpu.textures.set(imageId, { texture, view, sampler, width, height, revision: -1 });
  return entry;
}

// --- Depth buffer management ---

function ensureDepthTexture(gpu, device, width, height) {
  if (gpu._depthTextures == null) gpu._depthTextures = new Map();
  const key = `${width}x${height}`;
  const existing = gpu._depthTextures.get(key);
  if (existing != null) return existing;
  const texture = device.createTexture({
    size: { width, height },
    format: "depth24plus",
    usage: GPUTextureUsage.RENDER_ATTACHMENT,
  });
  const view = texture.createView();
  const entry = { texture, view, width, height };
  gpu._depthTextures.set(key, entry);
  return entry;
}

/**
 * Ensure the GPU render pipeline, bind group layouts, and default texture are created.
 * Returns true if pipeline is ready.
 */
export function ensureGpuPipeline(gpu, device, format) {
  if (gpu._pipeline != null && gpu._pipelineFormat === format) {
    return true;
  }
  try {
    const shaderModule = device.createShaderModule({ code: SHADER_CODE });
    const texBGL = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.FRAGMENT, texture: { sampleType: "float" } },
        { binding: 1, visibility: GPUShaderStage.FRAGMENT, sampler: {} },
      ],
    });
    const uniformBGL = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.FRAGMENT | GPUShaderStage.VERTEX, buffer: { type: "uniform" } },
      ],
    });
    const pipelineLayout = device.createPipelineLayout({ bindGroupLayouts: [uniformBGL, texBGL] });
    const pipeline = device.createRenderPipeline({
      layout: pipelineLayout,
      vertex: {
        module: shaderModule,
        entryPoint: "vs_main",
        buffers: [{
          arrayStride: 16,
          attributes: [
            { shaderLocation: 0, offset: 0, format: "float32x2" },
            { shaderLocation: 1, offset: 8, format: "float32x2" },
          ],
        }],
      },
      fragment: {
        module: shaderModule,
        entryPoint: "fs_main",
        targets: [{
          format,
          blend: {
            color: { srcFactor: "src-alpha", dstFactor: "one-minus-src-alpha", operation: "add" },
            alpha: { srcFactor: "one", dstFactor: "one-minus-src-alpha", operation: "add" },
          },
        }],
      },
      primitive: { topology: "triangle-list", cullMode: "none" },
    });
    const defaultTex = device.createTexture({
      size: { width: 1, height: 1 },
      format: "rgba8unorm",
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST,
    });
    device.queue.writeTexture(
      { texture: defaultTex },
      new Uint8Array([255, 255, 255, 255]),
      { bytesPerRow: 4 },
      { width: 1, height: 1 },
    );
    gpu._pipeline = pipeline;
    gpu._pipelineFormat = format;
    gpu._uniformBGL = uniformBGL;
    gpu._texBGL = texBGL;
    // Also create an rgba8unorm variant for off-screen targets
    if (format !== "rgba8unorm") {
      const offscreenPipeline = device.createRenderPipeline({
        layout: pipelineLayout,
        vertex: {
          module: shaderModule,
          entryPoint: "vs_main",
          buffers: [{
            arrayStride: 16,
            attributes: [
              { shaderLocation: 0, offset: 0, format: "float32x2" },
              { shaderLocation: 1, offset: 8, format: "float32x2" },
            ],
          }],
        },
        fragment: {
          module: shaderModule,
          entryPoint: "fs_main",
          targets: [{
            format: "rgba8unorm",
            blend: {
              color: { srcFactor: "src-alpha", dstFactor: "one-minus-src-alpha", operation: "add" },
              alpha: { srcFactor: "one", dstFactor: "one-minus-src-alpha", operation: "add" },
            },
          }],
        },
        primitive: { topology: "triangle-list", cullMode: "none" },
      });
      gpu._pipelineOffscreen = offscreenPipeline;
    } else {
      gpu._pipelineOffscreen = pipeline;
    }
    gpu._defaultTexture = defaultTex;
    gpu._defaultTexView = defaultTex.createView();
    gpu._defaultSampler = device.createSampler({ magFilter: "nearest", minFilter: "nearest" });
    gpu._linearSampler = device.createSampler({
      magFilter: "linear",
      minFilter: "linear",
      addressModeU: "clamp-to-edge",
      addressModeV: "clamp-to-edge",
    });
    gpu._drawResourceCache = null;
    return true;
  } catch (_) {
    gpu._pipeline = null;
    gpu._pipelineFormat = "";
    gpu._uniformBGL = null;
    gpu._texBGL = null;
    gpu._defaultTexture = null;
    gpu._defaultTexView = null;
    gpu._defaultSampler = null;
    gpu._linearSampler = null;
    gpu._drawResourceCache = null;
    return false;
  }
}

const releaseBufferEntries = (entries) => {
  if (!Array.isArray(entries)) return;
  for (let i = 0; i < entries.length; i += 1) {
    const entry = entries[i];
    const buffer = entry == null ? null : entry.buffer;
    if (buffer != null && typeof buffer.destroy === "function") {
      try { buffer.destroy(); } catch (_) {}
    }
  }
};

/**
 * Release all GPU resources (buffers, textures, pipeline, etc.) and reset state.
 */
export function releaseGpuResources(gpu) {
  if (gpu == null) return;
  const cache = gpu._drawResourceCache;
  if (cache != null) {
    releaseBufferEntries(cache.vertexBuffers);
    releaseBufferEntries(cache.indexBuffers);
    releaseBufferEntries(cache.uniformBuffers);
    releaseBufferEntries(cache.customVertexBuffers);
    releaseBufferEntries(cache.customIndexBuffers);
    releaseBufferEntries(cache.customUniformBuffers);
  }
  const textures = gpu.textures;
  if (textures != null && typeof textures.values === "function") {
    for (const entry of textures.values()) {
      const texture = entry == null ? null : entry.texture;
      if (texture != null && typeof texture.destroy === "function") {
        try { texture.destroy(); } catch (_) {}
      }
    }
  }
  if (textures != null && typeof textures.clear === "function") {
    textures.clear();
  }
  if (gpu._defaultTexture != null && typeof gpu._defaultTexture.destroy === "function") {
    try { gpu._defaultTexture.destroy(); } catch (_) {}
  }
  if (gpu.context != null && typeof gpu.context.unconfigure === "function") {
    try { gpu.context.unconfigure(); } catch (_) {}
  }
  // Clean up custom resources
  if (gpu._customPipelines != null) gpu._customPipelines.clear();
  if (gpu._renderTargets != null) {
    for (const entry of gpu._renderTargets.values()) {
      if (entry.texture != null) try { entry.texture.destroy(); } catch (_) {}
    }
    gpu._renderTargets.clear();
  }
  if (gpu._depthTextures != null) {
    for (const entry of gpu._depthTextures.values()) {
      if (entry.texture != null) try { entry.texture.destroy(); } catch (_) {}
    }
    gpu._depthTextures.clear();
  }
  if (gpu._timestampQueryState != null) {
    for (const slot of gpu._timestampQueryState.slots ?? []) {
      if (slot.resolveBuffer != null) {
        try { slot.resolveBuffer.destroy?.(); } catch (_) {}
      }
      if (slot.readBuffer != null) {
        try { slot.readBuffer.destroy?.(); } catch (_) {}
      }
    }
  }
  gpu._pipeline = null;
  gpu._pipelineFormat = "";
  gpu._configuredFormat = "";
  gpu._uniformBGL = null;
  gpu._texBGL = null;
  gpu._defaultTexture = null;
  gpu._defaultTexView = null;
  gpu._defaultSampler = null;
  gpu._linearSampler = null;
  gpu._drawResourceCache = null;
  gpu._timestampQueryState = null;
  gpu._timestampQueryStateInitialized = false;
  gpu._lastTimestampFrameMs = 0;
  gpu._lastTimestampRawDeltaNs = "0";
  gpu._lastRenderAcquireCpuMs = 0;
  gpu._lastRenderPassSetupCpuMs = 0;
  gpu._lastRenderDrawEncodeCpuMs = 0;
  gpu._lastRenderCleanupCpuMs = 0;
  gpu._lastRenderUploadCpuMs = 0;
  gpu._lastRenderBindGroupCpuMs = 0;
  gpu._lastRenderPassEncodeCpuMs = 0;
  gpu._lastRenderEncodeCpuMs = 0;
  gpu._lastRenderSubmitCpuMs = 0;
  gpu._lastRenderCpuMs = 0;
  gpu._timestampFrameMsQueue = [];
  gpu._gpuTimingMethod = "queue-completion";
  gpu._pendingTexture = null;
  gpu._currentDraw = null;
  gpu.commands = [];
  gpu.textures = new Map();
}

/**
 * Finalize a pending texture upload: create/update GPU texture from staged pixel data.
 */
export function finalizeTextureUpload(gpu) {
  if (gpu == null || gpu._pendingTexture == null || gpu.device == null) return;
  const { imageId, width, height, pixels } = gpu._pendingTexture;
  gpu._pendingTexture = null;
  if (width <= 0 || height <= 0) return;
  if (gpu.textures == null) gpu.textures = new Map();
  const existing = gpu.textures.get(imageId);
  if (existing != null && (existing.width !== width || existing.height !== height)) {
    if (existing.texture != null && typeof existing.texture.destroy === "function") {
      existing.texture.destroy();
    }
    gpu.textures.delete(imageId);
  }
  let entry = gpu.textures.get(imageId);
  if (entry == null) {
    const nextRevision = existing != null && Number.isFinite(existing.revision)
      ? ((existing.revision | 0) + 1)
      : 1;
    const texture = gpu.device.createTexture({
      size: { width, height },
      format: "rgba8unorm",
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST,
    });
    const view = texture.createView();
    const sampler = gpu.device.createSampler({
      magFilter: "nearest",
      minFilter: "nearest",
      addressModeU: "clamp-to-edge",
      addressModeV: "clamp-to-edge",
    });
    entry = { texture, view, sampler, width, height, revision: nextRevision };
    gpu.textures.set(imageId, entry);
  } else if (!Number.isFinite(entry.revision)) {
    entry.revision = 1;
  }
  gpu.device.queue.writeTexture(
    { texture: entry.texture },
    pixels,
    { bytesPerRow: width * 4 },
    { width, height },
  );
}

// --- Draw helpers ---

function drawDefaultCommand(gpu, device, pass, cmd, drawIndex, cache, passFormat, breakdown = null) {
  const ensureBufferEntry = (slots, slotIndex, minSize, usage) => {
    const requiredSize = Math.max(16, Number(minSize) | 0);
    let entry = slots[slotIndex];
    const currentSize = entry == null ? 0 : (Number(entry.size ?? 0) | 0);
    if (entry == null || currentSize < requiredSize) {
      if (entry != null && entry.buffer != null && typeof entry.buffer.destroy === "function") {
        try { entry.buffer.destroy(); } catch (_) {}
      }
      entry = {
        size: requiredSize,
        buffer: device.createBuffer({ size: requiredSize, usage }),
      };
      slots[slotIndex] = entry;
    }
    return entry;
  };

  if (cmd.vertexData == null || cmd.vertexData.length === 0) return;
  if (cmd.indices == null || cmd.indices.length === 0) return;
  const resourceCacheKey = getResourceCacheKey(cmd);
  const vbEntry = ensureBufferEntry(
    cache.vertexBuffers, drawIndex, cmd.vertexData.byteLength,
    GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
  );
  if (
    (resourceCacheKey === 0 && cache.vertexDataRefs[drawIndex] !== cmd.vertexData) ||
    cache.resourceCacheKeys[drawIndex] !== resourceCacheKey ||
    cache.vertexDataSizes[drawIndex] !== cmd.vertexData.byteLength
  ) {
    measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
      device.queue.writeBuffer(vbEntry.buffer, 0, cmd.vertexData);
    });
    cache.vertexDataRefs[drawIndex] = cmd.vertexData;
    cache.vertexDataSizes[drawIndex] = cmd.vertexData.byteLength;
  }
  const ibEntry = ensureBufferEntry(
    cache.indexBuffers, drawIndex, cmd.indices.byteLength,
    GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
  );
  if (
    (resourceCacheKey === 0 && cache.indexDataRefs[drawIndex] !== cmd.indices) ||
    cache.resourceCacheKeys[drawIndex] !== resourceCacheKey ||
    cache.indexDataSizes[drawIndex] !== cmd.indices.byteLength
  ) {
    measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
      device.queue.writeBuffer(ibEntry.buffer, 0, cmd.indices);
    });
    cache.indexDataRefs[drawIndex] = cmd.indices;
    cache.indexDataSizes[drawIndex] = cmd.indices.byteLength;
  }
  const ubEntry = ensureBufferEntry(
    cache.uniformBuffers, drawIndex, 16,
    GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
  );
  const uniformColorKey = `${cmd.uniformR},${cmd.uniformG},${cmd.uniformB},${cmd.uniformA}`;
  if (
    (resourceCacheKey === 0 && cache.uniformColorKeys[drawIndex] !== uniformColorKey) ||
    cache.resourceCacheKeys[drawIndex] !== resourceCacheKey
  ) {
    measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
      device.queue.writeBuffer(ubEntry.buffer, 0, new Float32Array([
        cmd.uniformR, cmd.uniformG, cmd.uniformB, cmd.uniformA,
      ]));
    });
    cache.uniformColorKeys[drawIndex] = uniformColorKey;
  }
  cache.resourceCacheKeys[drawIndex] = resourceCacheKey;
  let uniformBG = cache.uniformBindGroups[drawIndex];
  if (uniformBG == null || cache.uniformBindBuffers[drawIndex] !== ubEntry.buffer) {
    uniformBG = measureDrawBreakdown(breakdown, "bindGroupCpuMs", () => {
      return device.createBindGroup({
        layout: gpu._uniformBGL,
        entries: [{ binding: 0, resource: { buffer: ubEntry.buffer } }],
      });
    });
    cache.uniformBindGroups[drawIndex] = uniformBG;
    cache.uniformBindBuffers[drawIndex] = ubEntry.buffer;
  }
  let texView = gpu._defaultTexView;
  let texSampler = gpu._defaultSampler;
  let resolvedImageId = 0;
  let resolvedRevision = -1;
  if (gpu.textures != null && cmd.srcImageId > 0) {
    const texEntry = gpu.textures.get(cmd.srcImageId);
    if (texEntry != null) {
      texView = texEntry.view;
      texSampler = texEntry.sampler;
      resolvedImageId = cmd.srcImageId | 0;
      resolvedRevision = Number.isFinite(texEntry.revision)
        ? (texEntry.revision | 0)
        : 0;
    }
  }
  let texBG = cache.textureBindGroups[drawIndex];
  if (
    texBG == null ||
    cache.textureBindImageIds[drawIndex] !== resolvedImageId ||
    cache.textureBindRevisions[drawIndex] !== resolvedRevision
  ) {
    texBG = measureDrawBreakdown(breakdown, "bindGroupCpuMs", () => {
      return device.createBindGroup({
        layout: gpu._texBGL,
        entries: [
          { binding: 0, resource: texView },
          { binding: 1, resource: texSampler },
        ],
      });
    });
    cache.textureBindGroups[drawIndex] = texBG;
    cache.textureBindImageIds[drawIndex] = resolvedImageId;
    cache.textureBindRevisions[drawIndex] = resolvedRevision;
  }
  const selectedPipeline = (passFormat != null && passFormat !== gpu._pipelineFormat && gpu._pipelineOffscreen != null)
    ? gpu._pipelineOffscreen
    : gpu._pipeline;
  measureDrawBreakdown(breakdown, "passEncodeCpuMs", () => {
    pass.setPipeline(selectedPipeline);
    pass.setBindGroup(0, uniformBG);
    pass.setBindGroup(1, texBG);
    pass.setVertexBuffer(0, vbEntry.buffer);
    pass.setIndexBuffer(ibEntry.buffer, "uint32");
    pass.drawIndexed(cmd.indices.length, getInstanceCount(cmd));
  });
}

function prepareGpuSkinnedDraw(device, shaderSource, vertexData, uniformDwords) {
  if (
    device == null ||
    typeof device.createComputePipeline !== "function" ||
    vertexData == null ||
    uniformDwords == null
  ) {
    return null;
  }
  const isSkinned =
    /position\s*:\s*vec3<f32>/.test(shaderSource) &&
    /joints\s*:\s*vec4<f32>/.test(shaderSource) &&
    /weights\s*:\s*vec4<f32>/.test(shaderSource) &&
    /bone_matrices/.test(shaderSource);
  if (!isSkinned) return null;
  const floatCount = vertexData.length | 0;
  if (floatCount <= 0 || (floatCount % 16) !== 0) return null;
  if ((uniformDwords.length | 0) < 60) return null;
  const queue = device.queue;
  if (queue == null || typeof queue.writeBuffer !== "function") return null;

  const cacheKey = "__kaguraSkinnedComputeCache";
  let cache = globalThis[cacheKey];
  if (cache == null || cache.device !== device) {
    cache = { device, pipeline: null, bgl: null };
    globalThis[cacheKey] = cache;
  }
  if (cache.pipeline == null || cache.bgl == null) {
    const code = `
const MAX_BONES: u32 = 64u;
struct Uniforms {
  mvp: mat4x4<f32>,
  model: mat4x4<f32>,
  normal_col0: vec4<f32>,
  normal_col1: vec4<f32>,
  normal_col2: vec4<f32>,
  light_dir: vec4<f32>,
  light_color: vec4<f32>,
  ambient_color: vec4<f32>,
  num_bones: vec4<f32>,
  bone_matrices: array<mat4x4<f32>, 64>,
};
@group(0) @binding(0) var<storage, read> in_data: array<f32>;
@group(0) @binding(1) var<storage, read_write> out_data: array<f32>;
@group(0) @binding(2) var<uniform> uniforms: Uniforms;
@compute @workgroup_size(64)
fn cs_main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let idx = gid.x;
  let elem_count = arrayLength(&in_data);
  let vertex_count = elem_count / 16u;
  if (idx >= vertex_count) { return; }
  let base = idx * 16u;
  let px = in_data[base + 0u];
  let py = in_data[base + 1u];
  let pz = in_data[base + 2u];
  let nx = in_data[base + 3u];
  let ny = in_data[base + 4u];
  let nz = in_data[base + 5u];
  let j0 = u32(in_data[base + 8u]);
  let j1 = u32(in_data[base + 9u]);
  let j2 = u32(in_data[base + 10u]);
  let j3 = u32(in_data[base + 11u]);
  let w0 = in_data[base + 12u];
  let w1 = in_data[base + 13u];
  let w2 = in_data[base + 14u];
  let w3 = in_data[base + 15u];
  var skin_mat = mat4x4<f32>();
  if (w0 > 0.0) { skin_mat = skin_mat + w0 * uniforms.bone_matrices[j0]; }
  if (w1 > 0.0) { skin_mat = skin_mat + w1 * uniforms.bone_matrices[j1]; }
  if (w2 > 0.0) { skin_mat = skin_mat + w2 * uniforms.bone_matrices[j2]; }
  if (w3 > 0.0) { skin_mat = skin_mat + w3 * uniforms.bone_matrices[j3]; }
  let sp = skin_mat * vec4<f32>(px, py, pz, 1.0);
  let sn = (skin_mat * vec4<f32>(nx, ny, nz, 0.0)).xyz;
  let sn_len = max(length(sn), 1e-6);
  let nn = sn / sn_len;
  out_data[base + 0u] = sp.x;
  out_data[base + 1u] = sp.y;
  out_data[base + 2u] = sp.z;
  out_data[base + 3u] = nn.x;
  out_data[base + 4u] = nn.y;
  out_data[base + 5u] = nn.z;
  for (var i = 6u; i < 16u; i = i + 1u) {
    out_data[base + i] = in_data[base + i];
  }
}`;
    const module = device.createShaderModule({ code });
    const pipeline = device.createComputePipeline({
      layout: "auto",
      compute: { module, entryPoint: "cs_main" },
    });
    cache.pipeline = pipeline;
    cache.bgl = pipeline.getBindGroupLayout(0);
  }

  const inBuf = device.createBuffer({
    size: Math.max(16, vertexData.byteLength | 0),
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
  });
  const outBuf = device.createBuffer({
    size: Math.max(16, vertexData.byteLength | 0),
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX,
  });
  const uniformBytes = uniformDwords.byteLength | 0;
  const alignedUniformBytes = Math.max(16, Math.ceil(uniformBytes / 16) * 16);
  const ubCompute = device.createBuffer({
    size: alignedUniformBytes,
    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
  });
  const ubRender = device.createBuffer({
    size: alignedUniformBytes,
    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
  });
  queue.writeBuffer(inBuf, 0, vertexData);
  queue.writeBuffer(
    ubCompute,
    0,
    new Uint8Array(
      uniformDwords.buffer,
      uniformDwords.byteOffset,
      uniformDwords.byteLength,
    ),
  );
  const patched = new Uint32Array(uniformDwords.length | 0);
  for (let i = 0; i < patched.length; i += 1) patched[i] = uniformDwords[i] >>> 0;
  if (patched.length > 57) patched[57] = 0x3f800000;
  queue.writeBuffer(ubRender, 0, new Uint8Array(patched.buffer));
  const bindGroup = device.createBindGroup({
    layout: cache.bgl,
    entries: [
      { binding: 0, resource: { buffer: inBuf } },
      { binding: 1, resource: { buffer: outBuf } },
      { binding: 2, resource: { buffer: ubCompute } },
    ],
  });
  const encoder = device.createCommandEncoder();
  const cpass = encoder.beginComputePass();
  cpass.setPipeline(cache.pipeline);
  cpass.setBindGroup(0, bindGroup);
  cpass.dispatchWorkgroups(Math.ceil((floatCount / 16) / 64));
  cpass.end();
  queue.submit([encoder.finish()]);
  return {
    vertexBuffer: outBuf,
    uniformBuffer: ubRender,
    cleanupBuffers: [inBuf, ubCompute, outBuf, ubRender],
  };
}

function drawCustomCommand(gpu, device, pass, cmd, format, drawIndex, cache, breakdown = null) {
  const pipelineInfo = getOrCreateCustomPipeline(gpu, device, cmd, format);
  const ensureBufferEntry = (slots, slotIndex, minSize, usage) => {
    const requiredSize = Math.max(16, Number(minSize) | 0);
    let entry = slots[slotIndex];
    const currentSize = entry == null ? 0 : (Number(entry.size ?? 0) | 0);
    if (entry == null || currentSize < requiredSize) {
      if (entry != null && entry.buffer != null && typeof entry.buffer.destroy === "function") {
        try { entry.buffer.destroy(); } catch (_) {}
      }
      entry = {
        size: requiredSize,
        buffer: device.createBuffer({ size: requiredSize, usage }),
      };
      slots[slotIndex] = entry;
    }
    return entry;
  };

  // Vertex buffer
  if (cmd.vertexData == null || cmd.vertexData.length === 0) return;
  if (cmd.indices == null || cmd.indices.length === 0) return;
  const computed = measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
    return prepareGpuSkinnedDraw(
      device,
      cmd.shaderSource,
      cmd.vertexData,
      cmd.uniformDwords,
    );
  });
  const usingComputed = computed != null;
  const resourceCacheKey = getResourceCacheKey(cmd);
  const vb = usingComputed
    ? computed.vertexBuffer
    : (() => {
      const entry = ensureBufferEntry(
        cache.customVertexBuffers,
        drawIndex,
        cmd.vertexData.byteLength,
        GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
      );
      if (
        (resourceCacheKey === 0 && cache.customVertexDataRefs[drawIndex] !== cmd.vertexData) ||
        cache.customResourceCacheKeys[drawIndex] !== resourceCacheKey ||
        cache.customVertexDataSizes[drawIndex] !== cmd.vertexData.byteLength
      ) {
        measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
          device.queue.writeBuffer(entry.buffer, 0, cmd.vertexData);
        });
        cache.customVertexDataRefs[drawIndex] = cmd.vertexData;
        cache.customVertexDataSizes[drawIndex] = cmd.vertexData.byteLength;
      }
      return entry.buffer;
    })();

  // Index buffer
  const ib = usingComputed
    ? measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
      const created = device.createBuffer({
        size: Math.max(16, cmd.indices.byteLength),
        usage: GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
      });
      device.queue.writeBuffer(created, 0, cmd.indices);
      return created;
    })
    : (() => {
      const entry = ensureBufferEntry(
        cache.customIndexBuffers,
        drawIndex,
        cmd.indices.byteLength,
        GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
      );
      if (
        (resourceCacheKey === 0 && cache.customIndexDataRefs[drawIndex] !== cmd.indices) ||
        cache.customResourceCacheKeys[drawIndex] !== resourceCacheKey ||
        cache.customIndexDataSizes[drawIndex] !== cmd.indices.byteLength
      ) {
        measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
          device.queue.writeBuffer(entry.buffer, 0, cmd.indices);
        });
        cache.customIndexDataRefs[drawIndex] = cmd.indices;
        cache.customIndexDataSizes[drawIndex] = cmd.indices.byteLength;
      }
      return entry.buffer;
    })();

  // Uniform buffer (16-byte aligned or compute-prepared)
  const ub = usingComputed
    ? computed.uniformBuffer
    : (() => {
      const uniformBytes = cmd.uniformDwords != null ? cmd.uniformDwords.byteLength : 0;
      const alignedSize = Math.max(16, Math.ceil(uniformBytes / 16) * 16);
      const entry = ensureBufferEntry(
        cache.customUniformBuffers,
        drawIndex,
        alignedSize,
        GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
      );
      if (
        (resourceCacheKey === 0 && cache.customUniformDataRefs[drawIndex] !== cmd.uniformDwords) ||
        cache.customResourceCacheKeys[drawIndex] !== resourceCacheKey ||
        cache.customUniformDataSizes[drawIndex] !== uniformBytes
      ) {
        if (cmd.uniformDwords != null && cmd.uniformDwords.length > 0) {
          measureDrawBreakdown(breakdown, "uploadCpuMs", () => {
            device.queue.writeBuffer(
              entry.buffer,
              0,
              new Uint8Array(
                cmd.uniformDwords.buffer,
                cmd.uniformDwords.byteOffset,
                cmd.uniformDwords.byteLength,
              ),
            );
          });
        }
        cache.customUniformDataRefs[drawIndex] = cmd.uniformDwords;
        cache.customUniformDataSizes[drawIndex] = uniformBytes;
      }
      cache.customResourceCacheKeys[drawIndex] = resourceCacheKey;
      return entry.buffer;
    })();

  // Build bind group entries
  const bgEntries = [
    { binding: 0, resource: { buffer: ub } },
  ];

  // Parse texture bindings from shader source
  const texBindings = parseTextureBindings(cmd.shaderSource);
  const sampler = gpu._linearSampler || gpu._defaultSampler;

  // Group texture bindings into (texture, sampler) pairs
  let srcIndex = 0;
  const textureKeyParts = [];
  for (let i = 0; i < texBindings.length; i++) {
    const tb = texBindings[i];
    if (tb.type === "texture") {
      // Find the texture for this src image
      let texView = gpu._defaultTexView;
      let resolvedImageId = 0;
      let resolvedRevision = -1;
      if (cmd.srcImageIds != null && srcIndex < cmd.srcImageIds.length) {
        const imgId = cmd.srcImageIds[srcIndex];
        if (imgId > 0 && gpu.textures != null) {
          const texEntry = gpu.textures.get(imgId);
          if (texEntry != null) {
            texView = texEntry.view;
            resolvedImageId = imgId | 0;
            resolvedRevision = Number.isFinite(texEntry.revision)
              ? (texEntry.revision | 0)
              : 0;
          }
        }
        srcIndex++;
      }
      textureKeyParts.push(`${tb.binding}:${resolvedImageId}:${resolvedRevision}`);
      bgEntries.push({ binding: tb.binding, resource: texView });
    } else if (tb.type === "sampler") {
      bgEntries.push({ binding: tb.binding, resource: sampler });
    }
  }
  const textureKey = textureKeyParts.join("|");

  const bindGroup = usingComputed
    ? measureDrawBreakdown(breakdown, "bindGroupCpuMs", () => {
      return device.createBindGroup({
        layout: pipelineInfo.bindGroupLayout,
        entries: bgEntries,
      });
    })
    : (() => {
      let existing = cache.customBindGroups[drawIndex];
      if (
        existing == null ||
        cache.customBindLayouts[drawIndex] !== pipelineInfo.bindGroupLayout ||
        cache.customBindUniformBuffers[drawIndex] !== ub ||
        cache.customBindTextureKeys[drawIndex] !== textureKey
      ) {
        existing = measureDrawBreakdown(breakdown, "bindGroupCpuMs", () => {
          return device.createBindGroup({
            layout: pipelineInfo.bindGroupLayout,
            entries: bgEntries,
          });
        });
        cache.customBindGroups[drawIndex] = existing;
        cache.customBindLayouts[drawIndex] = pipelineInfo.bindGroupLayout;
        cache.customBindUniformBuffers[drawIndex] = ub;
        cache.customBindTextureKeys[drawIndex] = textureKey;
      }
      return existing;
    })();

  measureDrawBreakdown(breakdown, "passEncodeCpuMs", () => {
    pass.setPipeline(pipelineInfo.pipeline);
    pass.setBindGroup(0, bindGroup);
    pass.setVertexBuffer(0, vb);
    pass.setIndexBuffer(ib, "uint32");
    pass.drawIndexed(cmd.indices.length, getInstanceCount(cmd));
  });

  // Schedule buffer cleanup after GPU submission
  if (gpu._pendingBufferCleanup == null) gpu._pendingBufferCleanup = [];
  if (usingComputed) {
    gpu._pendingBufferCleanup.push(...computed.cleanupBuffers, ib);
  }
}

/**
 * Render all queued draw commands using WebGPU.
 * Supports multi-pass rendering with custom shaders and render targets.
 * Returns true if rendering succeeded.
 */
export function renderGpu(gpu, device, context, clearColor, format) {
  if (device == null || context == null) return false;
  try {
    const renderCpuStart = performanceNow();
    globalThis.__kaguraLastGpu = gpu;
    if (globalThis.__kaguraDetailedCpuTimingEnabled === true) {
      gpu._detailedTimingEnabled = true;
    }
    const safeFormat = typeof format === "string" && format.length > 0 ? format : "bgra8unorm";
    if (!ensureGpuPipeline(gpu, device, safeFormat)) return false;
    if (gpu._configuredFormat !== safeFormat) {
      configureCanvasContext(context, device, safeFormat);
      gpu._configuredFormat = safeFormat;
    }
    const [r, g, b, a] = clearColor;

    const drawCommands = Array.isArray(gpu.commands) ? gpu.commands : [];
    if (drawCommands.length === 0) {
      // Still need to clear the screen
      const texture = context.getCurrentTexture();
      const view = texture.createView();
      const acquireEnd = performanceNow();
      const encoder = device.createCommandEncoder();
      const timestampSlot = reserveTimestampQuerySlot(gpu, device);
      const pass = encoder.beginRenderPass({
        colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: "clear", storeOp: "store" }],
        timestampWrites: buildPassTimestampWrites(timestampSlot, true, true),
      });
      const passSetupEnd = performanceNow();
      pass.end();
      resolveTimestampQuery(encoder, timestampSlot);
      const readback = queueVrtFrameReadback(gpu, device, encoder, texture, safeFormat);
      const drawEncodeEnd = performanceNow();
      submitEncodedFrame(
        gpu,
        device,
        encoder,
        timestampSlot,
        renderCpuStart,
        {
          acquireCpuMs: acquireEnd - renderCpuStart,
          passSetupCpuMs: passSetupEnd - acquireEnd,
          drawEncodeCpuMs: drawEncodeEnd - passSetupEnd,
        },
        null,
        readback,
      );
      gpu.commands = [];
      return true;
    }

    // Check if any custom commands exist
    let hasCustom = false;
    for (let i = 0; i < drawCommands.length; i++) {
      if (drawCommands[i].isCustom) { hasCustom = true; break; }
    }

    if (!hasCustom) {
      // Fast path: single-pass default rendering (original behavior)
      const texture = context.getCurrentTexture();
      const view = texture.createView();
      if (gpu._drawResourceCache == null) {
        gpu._drawResourceCache = createDrawResourceCache();
      }
      const cache = gpu._drawResourceCache;
      const acquireEnd = performanceNow();
      const encoder = device.createCommandEncoder();
      const timestampSlot = reserveTimestampQuerySlot(gpu, device);
      const drawBreakdown = createDrawEncodeBreakdown(gpu._detailedTimingEnabled === true);
      const pass = encoder.beginRenderPass({
        colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: "clear", storeOp: "store" }],
        timestampWrites: buildPassTimestampWrites(timestampSlot, true, true),
      });
      const passSetupEnd = performanceNow();
      for (let drawIndex = 0; drawIndex < drawCommands.length; drawIndex += 1) {
        drawDefaultCommand(
          gpu,
          device,
          pass,
          drawCommands[drawIndex],
          drawIndex,
          cache,
          safeFormat,
          drawBreakdown,
        );
      }
      pass.end();
      resolveTimestampQuery(encoder, timestampSlot);
      const readback = queueVrtFrameReadback(gpu, device, encoder, texture, safeFormat);
      const drawEncodeEnd = performanceNow();
      recordRenderDrawBreakdownMetrics(
        gpu,
        drawBreakdown.uploadCpuMs,
        drawBreakdown.bindGroupCpuMs,
        drawBreakdown.passEncodeCpuMs,
      );
      submitEncodedFrame(
        gpu,
        device,
        encoder,
        timestampSlot,
        renderCpuStart,
        {
          acquireCpuMs: acquireEnd - renderCpuStart,
          passSetupCpuMs: passSetupEnd - acquireEnd,
          drawEncodeCpuMs: drawEncodeEnd - passSetupEnd,
        },
        null,
        readback,
      );
      gpu.commands = [];
      return true;
    }

    // Multi-pass rendering path
    gpu._pendingBufferCleanup = [];
    if (gpu._drawResourceCache == null) {
      gpu._drawResourceCache = createDrawResourceCache();
    }
    const cache = gpu._drawResourceCache;

    const screenTexture = context.getCurrentTexture();
    const screenView = screenTexture.createView();
    const acquireEnd = performanceNow();

    const encoder = device.createCommandEncoder();
    const timestampSlot = reserveTimestampQuerySlot(gpu, device);
    const drawBreakdown = createDrawEncodeBreakdown(gpu._detailedTimingEnabled === true);
    const totalPassCount = countRenderPasses(drawCommands);
    let currentPass = null;
    let currentPassTarget = -999; // sentinel: no pass active
    let currentPassHasDepth = false;
    let currentPassIndex = -1;
    const passStarted = {}; // track which targets have been cleared
    let defaultDrawIndex = 0;

    // Detect screen target: last command's dst is the final output (screen)
    const lastCmd = drawCommands[drawCommands.length - 1];
    const screenTargetId = lastCmd.dstImageId | 0;
    gpu._screenTargetId = screenTargetId;
    const passSetupEnd = performanceNow();


    for (let i = 0; i < drawCommands.length; i++) {
      const cmd = drawCommands[i];
      const targetId = cmd.dstImageId | 0;
      const needsDepth = cmd.isCustom && is3DShader(cmd.shaderSource);

      if (targetId !== currentPassTarget || needsDepth !== currentPassHasDepth) {
        // End current pass
        if (currentPass != null) {
          currentPass.end();
        }

        // Begin new pass
        let targetView;
        let passFormat;
        let depthAttachment = undefined;
        let targetWidth, targetHeight;

        // Detect screen target: id=0 or the configured screen target id
        const isScreen = targetId === 0 || targetId === (gpu._screenTargetId | 0);
        if (isScreen) {
          // Screen target
          targetView = screenView;
          passFormat = safeFormat;
          targetWidth = screenTexture.width;
          targetHeight = screenTexture.height;
        } else {
          // Off-screen render target
          const rtWidth = cmd.dstWidth || 1;
          const rtHeight = cmd.dstHeight || 1;
          const rt = ensureRenderTarget(gpu, device, targetId, rtWidth, rtHeight);
          targetView = rt.view;
          passFormat = "rgba8unorm";
          targetWidth = rtWidth;
          targetHeight = rtHeight;
        }

        // Check if this is a 3D pass needing depth
        if (needsDepth) {
          const depth = ensureDepthTexture(gpu, device, targetWidth, targetHeight);
          depthAttachment = {
            view: depth.view,
            depthClearValue: 1.0,
            depthLoadOp: passStarted[targetId] ? "load" : "clear",
            depthStoreOp: "store",
          };
        }

        const loadOp = passStarted[targetId] ? "load" : "clear";
        const passDesc = {
          colorAttachments: [{
            view: targetView,
            clearValue: { r, g, b, a },
            loadOp,
            storeOp: "store",
          }],
          timestampWrites: buildPassTimestampWrites(
            timestampSlot,
            currentPassIndex + 1 === 0,
            currentPassIndex + 1 === totalPassCount - 1,
          ),
        };
        if (depthAttachment != null) {
          passDesc.depthStencilAttachment = depthAttachment;
        }

        currentPass = encoder.beginRenderPass(passDesc);
        currentPassIndex += 1;
        currentPassTarget = targetId;
        currentPassHasDepth = needsDepth;
        passStarted[targetId] = true;
      }

      const isScreenPass = targetId === 0 || targetId === (gpu._screenTargetId | 0);
      const passFormat = isScreenPass ? safeFormat : "rgba8unorm";
      if (cmd.isCustom) {
        drawCustomCommand(
          gpu,
          device,
          currentPass,
          cmd,
          passFormat,
          i,
          cache,
          drawBreakdown,
        );
      } else {
        drawDefaultCommand(
          gpu,
          device,
          currentPass,
          cmd,
          defaultDrawIndex,
          cache,
          passFormat,
          drawBreakdown,
        );
        defaultDrawIndex++;
      }
    }

    // End final pass
    if (currentPass != null) {
      currentPass.end();
    }

    resolveTimestampQuery(encoder, timestampSlot);
    const readback = queueVrtFrameReadback(gpu, device, encoder, screenTexture, safeFormat);
    const drawEncodeEnd = performanceNow();
    recordRenderDrawBreakdownMetrics(
      gpu,
      drawBreakdown.uploadCpuMs,
      drawBreakdown.bindGroupCpuMs,
      drawBreakdown.passEncodeCpuMs,
    );
    submitEncodedFrame(
      gpu,
      device,
      encoder,
      timestampSlot,
      renderCpuStart,
      {
        acquireCpuMs: acquireEnd - renderCpuStart,
        passSetupCpuMs: passSetupEnd - acquireEnd,
        drawEncodeCpuMs: drawEncodeEnd - passSetupEnd,
      },
      gpu._pendingBufferCleanup,
      readback,
    );
    gpu._pendingBufferCleanup = null;

    gpu.commands = [];
    return true;
  } catch (e) {
    console.error("kagura-gfx renderGpu error:", e);
    return false;
  }
}

/**
 * Install GFX helpers on globalThis for use from MoonBit extern "js" inline code.
 */
export function installGfxHelpers() {
  globalThis.__kaguraGfx = {
    ensurePipeline: ensureGpuPipeline,
    render: renderGpu,
    release: releaseGpuResources,
    finalizeTexture: finalizeTextureUpload,
    configureDetailedCpuTiming: (enabled) => {
      globalThis.__kaguraDetailedCpuTimingEnabled = enabled === true;
      if (globalThis.__kaguraLastGpu != null) {
        globalThis.__kaguraLastGpu._detailedTimingEnabled = enabled === true;
      }
    },
    lastCompletedFrameMs: () => globalThis.__kaguraLastGpu?._lastCompletedFrameMs ?? 0.0,
    consumeCompletedFrameMs: () => consumeCompletedFrameMs(globalThis.__kaguraLastGpu),
    lastTimestampFrameMs: () => globalThis.__kaguraLastGpu?._lastTimestampFrameMs ?? 0.0,
    lastTimestampRawDeltaNs: () => globalThis.__kaguraLastGpu?._lastTimestampRawDeltaNs ?? "0",
    consumeTimestampFrameMs: () => consumeTimestampFrameMs(globalThis.__kaguraLastGpu),
    consumeGpuFrameMs: () => consumeGpuFrameMs(globalThis.__kaguraLastGpu),
    gpuTimingMethod: () => globalThis.__kaguraLastGpu?._gpuTimingMethod ?? "queue-completion",
    lastRenderUploadCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderUploadCpuMs ?? 0.0,
    lastRenderBindGroupCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderBindGroupCpuMs ?? 0.0,
    lastRenderPassEncodeCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderPassEncodeCpuMs ?? 0.0,
    lastRenderAcquireCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderAcquireCpuMs ?? 0.0,
    lastRenderPassSetupCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderPassSetupCpuMs ?? 0.0,
    lastRenderDrawEncodeCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderDrawEncodeCpuMs ?? 0.0,
    lastRenderCleanupCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderCleanupCpuMs ?? 0.0,
    lastRenderEncodeCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderEncodeCpuMs ?? 0.0,
    lastRenderSubmitCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderSubmitCpuMs ?? 0.0,
    lastRenderCpuMs: () => globalThis.__kaguraLastGpu?._lastRenderCpuMs ?? 0.0,
    lastReadbackSummary: () => globalThis.__kaguraLastGpu?._vrtLastReadback ?? null,
  };
}
