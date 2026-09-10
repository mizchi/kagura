import {test, expect} from '@playwright/test';

async function boot(page) {
  await page.addInitScript(() => {
    globalThis.shaderSources = [];
    const create = GPUDevice.prototype.createShaderModule;
    GPUDevice.prototype.createShaderModule = function (descriptor) {
      globalThis.shaderSources.push(descriptor.code);
      return create.call(this, descriptor);
    };
  });
  await page.goto('/');
  await expect(page.getByRole('button', {name: '出撃する', exact: true})).toBeEnabled();
}

test('uncovered shadow texels contain far depth, not black occluders', async ({page}) => {
  await boot(page);
  const depths = await page.evaluate(async () => {
    const gpu = __kaguraWebRuntime.webgpu, device=gpu.device;
    const shadow = gpu._renderTargets.get(901);
    const code = `@group(0) @binding(0) var shadow: texture_2d<f32>;
      @vertex fn vs(@builtin(vertex_index) i:u32)->@builtin(position) vec4<f32>{
        let p=array<vec2<f32>,3>(vec2(-1,-1),vec2(3,-1),vec2(-1,3));return vec4(p[i],0,1);}
      @fragment fn fs(@builtin(position) p:vec4<f32>)->@location(0) vec4<f32>{
        return textureLoad(shadow,vec2<i32>(p.xy)*vec2<i32>(textureDimensions(shadow)/32u),0);}`;
    const module=device.createShaderModule({code});
    const pipeline=device.createRenderPipeline({layout:'auto',vertex:{module,entryPoint:'vs'},fragment:{module,entryPoint:'fs',targets:[{format:'rgba8unorm'}]}});
    const output=device.createTexture({size:[32,32],format:'rgba8unorm',usage:GPUTextureUsage.RENDER_ATTACHMENT|GPUTextureUsage.COPY_SRC});
    const encoder=device.createCommandEncoder(), pass=encoder.beginRenderPass({colorAttachments:[{view:output.createView(),loadOp:'clear',storeOp:'store',clearValue:[0,0,0,1]}]});
    pass.setPipeline(pipeline);pass.setBindGroup(0,device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[{binding:0,resource:shadow.view}]}));pass.draw(3);pass.end();
    const read=device.createBuffer({size:256*32,usage:GPUBufferUsage.MAP_READ|GPUBufferUsage.COPY_DST});encoder.copyTextureToBuffer({texture:output},{buffer:read,bytesPerRow:256},[32,32]);device.queue.submit([encoder.finish()]);await read.mapAsync(GPUMapMode.READ);
    const bytes=new Uint8Array(read.getMappedRange()), reds=[];for(let y=0;y<32;y++)for(let x=0;x<32;x++)reds.push(bytes[y*256+x*4]);const depths=[];for(let y=0;y<32;y++)for(let x=0;x<32;x++){const i=y*256+x*4;depths.push((bytes[i]*65536+bytes[i+1]*256+bytes[i+2])/16777215);}
    const sorted=[...new Set(depths)].sort((a,b)=>a-b);const fineDepth=sorted.some((v,i)=>i>0&&v-sorted[i-1]<1/65535);
    read.unmap();read.destroy();output.destroy();
    return {min:Math.min(...reds),max:Math.max(...reds),fineDepth,error:gpu.lastError};
  });
  expect(depths.error).toBe('');
  expect(depths.max).toBe(255);
  expect(depths.min).toBeGreaterThan(0);
  expect(depths.fineDepth).toBe(true);
  expect(depths.min).toBeLessThan(250); // casters still write depth
});

// Scan the real floating-point scene before final screen conversion can hide NaN.
// A bad destination color also survives alpha blending over an opaque model
// (NaN * 0), making floor markings appear to ignore depth on Metal.
test('actual road markings and roofs contain no non-finite scene colors', async ({page}) => {
  await boot(page);
  const result = await page.evaluate(async () => {
    const gpu = __kaguraWebRuntime.webgpu, device = gpu.device;
    const adapter = await navigator.gpu.requestAdapter();
    const target = gpu._renderTargets.get(900);
    device.pushErrorScope('validation');
    const module = device.createShaderModule({code:`
      @group(0) @binding(0) var scene: texture_2d<f32>;
      @group(0) @binding(1) var<storage, read_write> invalid: atomic<u32>;
      @compute @workgroup_size(8,8) fn main(@builtin(global_invocation_id) p:vec3<u32>) {
        if(any(p.xy >= textureDimensions(scene))) { return; }
        let bits = bitcast<vec4<u32>>(textureLoad(scene, vec2<i32>(p.xy), 0));
        if(any((bits & vec4<u32>(0x7f800000u)) == vec4<u32>(0x7f800000u))) {
          atomicAdd(&invalid, 1u);
        }
      }`});
    const pipeline = device.createComputePipeline({layout:'auto',compute:{module,entryPoint:'main'}});
    const count = device.createBuffer({size:4,usage:GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_SRC});
    const read = device.createBuffer({size:4,usage:GPUBufferUsage.MAP_READ|GPUBufferUsage.COPY_DST});
    const encoder = device.createCommandEncoder(), pass = encoder.beginComputePass();
    pass.setPipeline(pipeline);
    pass.setBindGroup(0,device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[
      {binding:0,resource:target.view},{binding:1,resource:{buffer:count}},
    ]}));
    pass.dispatchWorkgroups(Math.ceil(target.width/8),Math.ceil(target.height/8));pass.end();
    encoder.copyBufferToBuffer(count,0,read,0,4);device.queue.submit([encoder.finish()]);
    await read.mapAsync(GPUMapMode.READ);const invalid = new Uint32Array(read.getMappedRange())[0];
    read.unmap();read.destroy();count.destroy();
    const error = await device.popErrorScope();
    return {invalid,error:error?.message,vendor:adapter.info.vendor,architecture:adapter.info.architecture};
  });
  if(process.env.IRON_YARD_GPU==='metal') expect(result.vendor).toBe('apple');
  expect(result.error).toBeUndefined();
  expect(result.invalid, `${result.vendor} / ${result.architecture}`).toBe(0);
});
