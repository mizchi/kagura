import {test,expect} from '@playwright/test';
import {readFileSync} from 'node:fs';
const reference=JSON.parse(readFileSync(new URL('../tests/shadow-reference.json',import.meta.url)));
test('WGSL PCF matches original comparison filtering, disk samples and screen coordinates',async({page})=>{
 await page.addInitScript(()=>{globalThis.shaderSources=[];const create=GPUDevice.prototype.createShaderModule;GPUDevice.prototype.createShaderModule=function(d){shaderSources.push(d.code);return create.call(this,d)}});
 await page.goto('/');await expect(page.getByRole('button',{name:'出撃する',exact:true})).toBeEnabled();
 const pixels=await page.evaluate(async ref=>{
  const device=__kaguraWebRuntime.webgpu.device,source=shaderSources.find(s=>s.includes('fn standard_shadow'));
  if(!source)throw Error('Original PCF has not been ported');
  device.pushErrorScope('validation');
  const buffer=(data,usage)=>{const b=device.createBuffer({size:data.byteLength,usage:usage|GPUBufferUsage.COPY_DST});device.queue.writeBuffer(b,0,data);return b};
  // Rows in WebGPU start at the top; exported WebGL depth rows start at the bottom.
  const packed=new Uint8Array(64*4);
  ref.depths.forEach((d,i)=>{const p=((7-Math.floor(i/8))*8+i%8)*4,n=Math.round(d*16777215);packed.set([n>>>16,(n>>>8)&255,n&255,255],p)});
  const texture=device.createTexture({size:[8,8],format:'rgba8unorm',usage:GPUTextureUsage.TEXTURE_BINDING|GPUTextureUsage.COPY_DST});device.queue.writeTexture({texture},packed,{bytesPerRow:32},[8,8]);
  const calls=ref.samples.map(s=>`vec4<f32>(${s.uv[0]*2-1},${s.uv[1]*2-1},0.5,1)`).join(',');
  const coords=ref.samples.map(s=>`vec2<f32>(${s.position[0]+.5},${33-s.position[1]-.5})`).join(',');
  const module=device.createShaderModule({code:source+`
   @vertex fn test_vs(@builtin(vertex_index)i:u32)->@builtin(position)vec4<f32>{let p=array<vec2<f32>,3>(vec2(-1,-1),vec2(3,-1),vec2(-1,3));return vec4(p[i],0,1);}
   @fragment fn test_fs(@builtin(position)p:vec4<f32>)->@location(0)vec4<f32>{let calls=array<vec4<f32>,${ref.samples.length}>(${calls});let coords=array<vec2<f32>,${ref.samples.length}>(${coords});let s=standard_shadow(calls[u32(p.x)],coords[u32(p.x)]);return vec4(s,s,s,1);}`});
  const pipeline=device.createRenderPipeline({layout:'auto',vertex:{module,entryPoint:'test_vs'},fragment:{module,entryPoint:'test_fs',targets:[{format:'rgba8unorm'}]}});
  const u=new Float32Array(104);u[101]=1/8;u[102]=33;
  const uniform=buffer(u,GPUBufferUsage.UNIFORM);
  const group=device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[{binding:0,resource:{buffer:uniform}},{binding:5,resource:texture.createView()},{binding:6,resource:device.createSampler({minFilter:"linear",magFilter:"linear"})}]});
  const output=device.createTexture({size:[ref.samples.length,1],format:'rgba8unorm',usage:GPUTextureUsage.RENDER_ATTACHMENT|GPUTextureUsage.COPY_SRC});
  const encoder=device.createCommandEncoder(),pass=encoder.beginRenderPass({colorAttachments:[{view:output.createView(),loadOp:'clear',storeOp:'store'}]});pass.setPipeline(pipeline);pass.setBindGroup(0,group);pass.draw(3);pass.end();
  const read=device.createBuffer({size:256,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});encoder.copyTextureToBuffer({texture:output},{buffer:read,bytesPerRow:256},[ref.samples.length,1]);device.queue.submit([encoder.finish()]);await read.mapAsync(GPUMapMode.READ);const pixels=Array.from(new Uint8Array(read.getMappedRange()).slice(0,ref.samples.length*4));read.unmap();[read,uniform,output,texture].forEach(r=>r.destroy());const error=await device.popErrorScope();if(error)throw Error(error.message);return pixels;
 },reference);
 const errors=reference.samples.map((s,i)=>({sample:s,actual:pixels[i*4],difference:Math.abs(pixels[i*4]-s.pixel[0])}));
 expect(errors.filter(e=>e.difference>2)).toEqual([]);
});
