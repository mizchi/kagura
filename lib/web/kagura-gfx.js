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
  const stride32 = isStride32(cmd.shaderSource);

  let vertexBufferLayout;
  if (stride32) {
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
      cullMode: stride32 ? "back" : "none",
    },
  };

  if (stride32) {
    pipelineDesc.depthStencil = {
      format: "depth24plus",
      depthWriteEnabled: true,
      depthCompare: "less",
    };
  }

  const pipeline = device.createRenderPipeline(pipelineDesc);
  const bgl = pipeline.getBindGroupLayout(0);

  const result = { pipeline, bindGroupLayout: bgl, stride32 };
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
  gpu._pipeline = null;
  gpu._pipelineFormat = "";
  gpu._uniformBGL = null;
  gpu._texBGL = null;
  gpu._defaultTexture = null;
  gpu._defaultTexView = null;
  gpu._defaultSampler = null;
  gpu._linearSampler = null;
  gpu._drawResourceCache = null;
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

function drawDefaultCommand(gpu, device, pass, cmd, drawIndex, cache, passFormat) {
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
  const vbEntry = ensureBufferEntry(
    cache.vertexBuffers, drawIndex, cmd.vertexData.byteLength,
    GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
  );
  device.queue.writeBuffer(vbEntry.buffer, 0, cmd.vertexData);
  const ibEntry = ensureBufferEntry(
    cache.indexBuffers, drawIndex, cmd.indices.byteLength,
    GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
  );
  device.queue.writeBuffer(ibEntry.buffer, 0, cmd.indices);
  const ubEntry = ensureBufferEntry(
    cache.uniformBuffers, drawIndex, 16,
    GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
  );
  device.queue.writeBuffer(ubEntry.buffer, 0, new Float32Array([
    cmd.uniformR, cmd.uniformG, cmd.uniformB, cmd.uniformA,
  ]));
  let uniformBG = cache.uniformBindGroups[drawIndex];
  if (uniformBG == null || cache.uniformBindBuffers[drawIndex] !== ubEntry.buffer) {
    uniformBG = device.createBindGroup({
      layout: gpu._uniformBGL,
      entries: [{ binding: 0, resource: { buffer: ubEntry.buffer } }],
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
    texBG = device.createBindGroup({
      layout: gpu._texBGL,
      entries: [
        { binding: 0, resource: texView },
        { binding: 1, resource: texSampler },
      ],
    });
    cache.textureBindGroups[drawIndex] = texBG;
    cache.textureBindImageIds[drawIndex] = resolvedImageId;
    cache.textureBindRevisions[drawIndex] = resolvedRevision;
  }
  const selectedPipeline = (passFormat != null && passFormat !== gpu._pipelineFormat && gpu._pipelineOffscreen != null)
    ? gpu._pipelineOffscreen
    : gpu._pipeline;
  pass.setPipeline(selectedPipeline);
  pass.setBindGroup(0, uniformBG);
  pass.setBindGroup(1, texBG);
  pass.setVertexBuffer(0, vbEntry.buffer);
  pass.setIndexBuffer(ibEntry.buffer, "uint32");
  pass.drawIndexed(cmd.indices.length);
}

function drawCustomCommand(gpu, device, pass, cmd, format) {
  const pipelineInfo = getOrCreateCustomPipeline(gpu, device, cmd, format);

  // Vertex buffer
  if (cmd.vertexData == null || cmd.vertexData.length === 0) return;
  if (cmd.indices == null || cmd.indices.length === 0) return;
  const vb = device.createBuffer({
    size: Math.max(16, cmd.vertexData.byteLength),
    usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
  });
  device.queue.writeBuffer(vb, 0, cmd.vertexData);

  // Index buffer
  const ib = device.createBuffer({
    size: Math.max(16, cmd.indices.byteLength),
    usage: GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
  });
  device.queue.writeBuffer(ib, 0, cmd.indices);

  // Uniform buffer (16-byte aligned)
  const uniformBytes = cmd.uniformDwords != null ? cmd.uniformDwords.byteLength : 0;
  const alignedSize = Math.max(16, Math.ceil(uniformBytes / 16) * 16);
  const ub = device.createBuffer({
    size: alignedSize,
    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
  });
  if (cmd.uniformDwords != null && cmd.uniformDwords.length > 0) {
    device.queue.writeBuffer(ub, 0, new Uint8Array(cmd.uniformDwords.buffer, cmd.uniformDwords.byteOffset, cmd.uniformDwords.byteLength));
  }

  // Build bind group entries
  const bgEntries = [
    { binding: 0, resource: { buffer: ub } },
  ];

  // Parse texture bindings from shader source
  const texBindings = parseTextureBindings(cmd.shaderSource);
  const sampler = gpu._linearSampler || gpu._defaultSampler;

  // Group texture bindings into (texture, sampler) pairs
  let srcIndex = 0;
  for (let i = 0; i < texBindings.length; i++) {
    const tb = texBindings[i];
    if (tb.type === "texture") {
      // Find the texture for this src image
      let texView = gpu._defaultTexView;
      if (cmd.srcImageIds != null && srcIndex < cmd.srcImageIds.length) {
        const imgId = cmd.srcImageIds[srcIndex];
        if (imgId > 0 && gpu.textures != null) {
          const texEntry = gpu.textures.get(imgId);
          if (texEntry != null) {
            texView = texEntry.view;
          }
        }
        srcIndex++;
      }
      bgEntries.push({ binding: tb.binding, resource: texView });
    } else if (tb.type === "sampler") {
      bgEntries.push({ binding: tb.binding, resource: sampler });
    }
  }

  const bindGroup = device.createBindGroup({
    layout: pipelineInfo.bindGroupLayout,
    entries: bgEntries,
  });

  pass.setPipeline(pipelineInfo.pipeline);
  pass.setBindGroup(0, bindGroup);
  pass.setVertexBuffer(0, vb);
  pass.setIndexBuffer(ib, "uint32");
  pass.drawIndexed(cmd.indices.length);

  // Schedule buffer cleanup after GPU submission
  if (gpu._pendingBufferCleanup == null) gpu._pendingBufferCleanup = [];
  gpu._pendingBufferCleanup.push(vb, ib, ub);
}

/**
 * Render all queued draw commands using WebGPU.
 * Supports multi-pass rendering with custom shaders and render targets.
 * Returns true if rendering succeeded.
 */
export function renderGpu(gpu, device, context, clearColor, format) {
  if (device == null || context == null) return false;
  try {
    const safeFormat = typeof format === "string" && format.length > 0 ? format : "bgra8unorm";
    if (!ensureGpuPipeline(gpu, device, safeFormat)) return false;
    context.configure({ device, format: safeFormat, alphaMode: "opaque" });
    const [r, g, b, a] = clearColor;

    const drawCommands = Array.isArray(gpu.commands) ? gpu.commands : [];
    if (drawCommands.length === 0) {
      // Still need to clear the screen
      const texture = context.getCurrentTexture();
      const view = texture.createView();
      const encoder = device.createCommandEncoder();
      const pass = encoder.beginRenderPass({
        colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: "clear", storeOp: "store" }],
      });
      pass.end();
      device.queue.submit([encoder.finish()]);
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
      const encoder = device.createCommandEncoder();
      const pass = encoder.beginRenderPass({
        colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: "clear", storeOp: "store" }],
      });
      if (gpu._drawResourceCache == null) {
        gpu._drawResourceCache = {
          vertexBuffers: [],
          indexBuffers: [],
          uniformBuffers: [],
          uniformBindGroups: [],
          uniformBindBuffers: [],
          textureBindGroups: [],
          textureBindImageIds: [],
          textureBindRevisions: [],
        };
      }
      const cache = gpu._drawResourceCache;
      for (let drawIndex = 0; drawIndex < drawCommands.length; drawIndex += 1) {
        drawDefaultCommand(gpu, device, pass, drawCommands[drawIndex], drawIndex, cache, safeFormat);
      }
      pass.end();
      device.queue.submit([encoder.finish()]);
      gpu.commands = [];
      return true;
    }

    // Multi-pass rendering path
    gpu._pendingBufferCleanup = [];
    if (gpu._drawResourceCache == null) {
      gpu._drawResourceCache = {
        vertexBuffers: [],
        indexBuffers: [],
        uniformBuffers: [],
        uniformBindGroups: [],
        uniformBindBuffers: [],
        textureBindGroups: [],
        textureBindImageIds: [],
        textureBindRevisions: [],
      };
    }
    const cache = gpu._drawResourceCache;

    const screenTexture = context.getCurrentTexture();
    const screenView = screenTexture.createView();

    const encoder = device.createCommandEncoder();
    let currentPass = null;
    let currentPassTarget = -999; // sentinel: no pass active
    let currentPassHasDepth = false;
    const passStarted = {}; // track which targets have been cleared
    let defaultDrawIndex = 0;

    // Detect screen target: last command's dst is the final output (screen)
    const lastCmd = drawCommands[drawCommands.length - 1];
    const screenTargetId = lastCmd.dstImageId | 0;
    gpu._screenTargetId = screenTargetId;


    for (let i = 0; i < drawCommands.length; i++) {
      const cmd = drawCommands[i];
      const targetId = cmd.dstImageId | 0;
      const needsDepth = cmd.isCustom && isStride32(cmd.shaderSource);

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
        };
        if (depthAttachment != null) {
          passDesc.depthStencilAttachment = depthAttachment;
        }

        currentPass = encoder.beginRenderPass(passDesc);
        currentPassTarget = targetId;
        currentPassHasDepth = needsDepth;
        passStarted[targetId] = true;
      }

      const isScreenPass = targetId === 0 || targetId === (gpu._screenTargetId | 0);
      const passFormat = isScreenPass ? safeFormat : "rgba8unorm";
      if (cmd.isCustom) {
        drawCustomCommand(gpu, device, currentPass, cmd, passFormat);
      } else {
        drawDefaultCommand(gpu, device, currentPass, cmd, defaultDrawIndex, cache, passFormat);
        defaultDrawIndex++;
      }
    }

    // End final pass
    if (currentPass != null) {
      currentPass.end();
    }

    device.queue.submit([encoder.finish()]);

    // Clean up temporary buffers
    if (gpu._pendingBufferCleanup != null) {
      for (const buf of gpu._pendingBufferCleanup) {
        if (buf != null && typeof buf.destroy === "function") {
          try { buf.destroy(); } catch (_) {}
        }
      }
      gpu._pendingBufferCleanup = null;
    }

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
  };
}
