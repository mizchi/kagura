// Local WebGPU rendering for WASM host.
// Canonical implementation is now in MoonBit: src/gfx_webgpu/

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

export function ensureGpuPipeline(gpu, device, format) {
  if (gpu._pipeline != null && gpu._pipelineFormat === format) return true;
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
    const vertexBufferLayout = {
      arrayStride: 16,
      attributes: [
        { shaderLocation: 0, offset: 0, format: "float32x2" },
        { shaderLocation: 1, offset: 8, format: "float32x2" },
      ],
    };
    const blend = {
      color: { srcFactor: "src-alpha", dstFactor: "one-minus-src-alpha", operation: "add" },
      alpha: { srcFactor: "one", dstFactor: "one-minus-src-alpha", operation: "add" },
    };
    gpu._pipeline = device.createRenderPipeline({
      layout: pipelineLayout,
      vertex: { module: shaderModule, entryPoint: "vs_main", buffers: [vertexBufferLayout] },
      fragment: { module: shaderModule, entryPoint: "fs_main", targets: [{ format, blend }] },
      primitive: { topology: "triangle-list", cullMode: "none" },
    });
    gpu._pipelineFormat = format;
    gpu._uniformBGL = uniformBGL;
    gpu._texBGL = texBGL;
    gpu._defaultTexture = device.createTexture({
      size: { width: 1, height: 1 },
      format: "rgba8unorm",
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST,
    });
    device.queue.writeTexture(
      { texture: gpu._defaultTexture },
      new Uint8Array([255, 255, 255, 255]),
      { bytesPerRow: 4 },
      { width: 1, height: 1 },
    );
    gpu._defaultTexView = gpu._defaultTexture.createView();
    gpu._defaultSampler = device.createSampler({ magFilter: "nearest", minFilter: "nearest" });
    gpu._drawResourceCache = null;
    return true;
  } catch (_) {
    gpu._pipeline = null;
    gpu._pipelineFormat = "";
    return false;
  }
}

export function renderGpu(gpu, device, context, clearColor, format) {
  if (device == null || context == null) return false;
  try {
    const safeFormat = typeof format === "string" && format.length > 0 ? format : "bgra8unorm";
    if (!ensureGpuPipeline(gpu, device, safeFormat)) return false;
    context.configure({ device, format: safeFormat, alphaMode: "opaque" });
    const [r, g, b, a] = clearColor;
    const drawCommands = Array.isArray(gpu.commands) ? gpu.commands : [];
    const texture = context.getCurrentTexture();
    const view = texture.createView();
    const encoder = device.createCommandEncoder();
    const pass = encoder.beginRenderPass({
      colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: "clear", storeOp: "store" }],
    });
    if (drawCommands.length > 0) {
      if (gpu._drawResourceCache == null) {
        gpu._drawResourceCache = {
          vertexBuffers: [], indexBuffers: [], uniformBuffers: [],
          uniformBindGroups: [], uniformBindBuffers: [],
          textureBindGroups: [], textureBindImageIds: [], textureBindRevisions: [],
        };
      }
      const cache = gpu._drawResourceCache;
      const ensureBuf = (slots, idx, minSize, usage) => {
        const sz = Math.max(16, minSize | 0);
        let e = slots[idx];
        if (e == null || (e.size | 0) < sz) {
          if (e?.buffer?.destroy) try { e.buffer.destroy(); } catch (_) {}
          e = { size: sz, buffer: device.createBuffer({ size: sz, usage }) };
          slots[idx] = e;
        }
        return e;
      };
      for (let i = 0; i < drawCommands.length; i++) {
        const cmd = drawCommands[i];
        if (!cmd.vertexData?.length || !cmd.indices?.length) continue;
        const vb = ensureBuf(cache.vertexBuffers, i, cmd.vertexData.byteLength, GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST);
        device.queue.writeBuffer(vb.buffer, 0, cmd.vertexData);
        const ib = ensureBuf(cache.indexBuffers, i, cmd.indices.byteLength, GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST);
        device.queue.writeBuffer(ib.buffer, 0, cmd.indices);
        const ub = ensureBuf(cache.uniformBuffers, i, 16, GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST);
        device.queue.writeBuffer(ub.buffer, 0, new Float32Array([cmd.uniformR, cmd.uniformG, cmd.uniformB, cmd.uniformA]));
        let uniformBG = cache.uniformBindGroups[i];
        if (uniformBG == null || cache.uniformBindBuffers[i] !== ub.buffer) {
          uniformBG = device.createBindGroup({ layout: gpu._uniformBGL, entries: [{ binding: 0, resource: { buffer: ub.buffer } }] });
          cache.uniformBindGroups[i] = uniformBG;
          cache.uniformBindBuffers[i] = ub.buffer;
        }
        let texView = gpu._defaultTexView, texSampler = gpu._defaultSampler;
        let imgId = 0, rev = -1;
        if (gpu.textures != null && cmd.srcImageId > 0) {
          const te = gpu.textures.get(cmd.srcImageId);
          if (te) { texView = te.view; texSampler = te.sampler; imgId = cmd.srcImageId; rev = te.revision | 0; }
        }
        let texBG = cache.textureBindGroups[i];
        if (texBG == null || cache.textureBindImageIds[i] !== imgId || cache.textureBindRevisions[i] !== rev) {
          texBG = device.createBindGroup({ layout: gpu._texBGL, entries: [{ binding: 0, resource: texView }, { binding: 1, resource: texSampler }] });
          cache.textureBindGroups[i] = texBG;
          cache.textureBindImageIds[i] = imgId;
          cache.textureBindRevisions[i] = rev;
        }
        pass.setPipeline(gpu._pipeline);
        pass.setBindGroup(0, uniformBG);
        pass.setBindGroup(1, texBG);
        pass.setVertexBuffer(0, vb.buffer);
        pass.setIndexBuffer(ib.buffer, "uint32");
        pass.drawIndexed(cmd.indices.length);
      }
    }
    pass.end();
    device.queue.submit([encoder.finish()]);
    gpu.commands = [];
    return true;
  } catch (e) {
    console.error("renderGpu error:", e);
    return false;
  }
}
