import {test,expect} from '@playwright/test';
import {readFileSync} from 'node:fs';
const reference=JSON.parse(readFileSync(new URL('../tests/render-reference.json',import.meta.url)));
async function boot(page){
 await page.addInitScript(()=>{globalThis.shaderSources=[];const create=GPUDevice.prototype.createShaderModule;GPUDevice.prototype.createShaderModule=function(d){shaderSources.push(d.code);return create.call(this,d)}});
 await page.goto('/');await expect(page.getByRole('button',{name:'出撃する',exact:true})).toBeEnabled();
}
test('display transform matches original Three.js ACES Filmic color patches',async({page})=>{
 await boot(page);
 const pixels=await page.evaluate(async samples=>{
  const device=__kaguraWebRuntime.webgpu.device;
  const source=shaderSources.find(s=>s.includes('fn aces_filmic'))??shaderSources.find(s=>s.includes('let a = 2.51;'));
  const filmic=source.includes('fn aces_filmic');
  const colors=samples.map(s=>`vec3<f32>(${s.rgb.map(v=>v.toFixed(8)).join(',')})`).join(',');
  const code=source+`\n@vertex fn reference_vs(@builtin(vertex_index) i:u32)->@builtin(position) vec4<f32>{let p=array<vec2<f32>,3>(vec2(-1,-1),vec2(3,-1),vec2(-1,3));return vec4(p[i],0,1);}
  @fragment fn reference_fs(@builtin(position) p:vec4<f32>)->@location(0) vec4<f32>{let colors=array<vec3<f32>,${samples.length}>(${colors});let linear=${filmic?'aces_filmic':'tonemap'}(colors[u32(p.x)]);return vec4(select(1.055*pow(max(linear,vec3(0)),vec3(1.0/2.4))-.055,linear*12.92,linear<=vec3(.0031308)),1);}`;
  const module=device.createShaderModule({code});
  const pipeline=device.createRenderPipeline({layout:'auto',vertex:{module,entryPoint:'reference_vs'},fragment:{module,entryPoint:'reference_fs',targets:[{format:'rgba8unorm'}]}});
  const output=device.createTexture({size:[samples.length,1],format:'rgba8unorm',usage:GPUTextureUsage.RENDER_ATTACHMENT|GPUTextureUsage.COPY_SRC});
  const encoder=device.createCommandEncoder(),pass=encoder.beginRenderPass({colorAttachments:[{view:output.createView(),loadOp:'clear',storeOp:'store'}]});pass.setPipeline(pipeline);pass.draw(3);pass.end();
  const read=device.createBuffer({size:256,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});encoder.copyTextureToBuffer({texture:output},{buffer:read,bytesPerRow:256},[samples.length,1]);device.queue.submit([encoder.finish()]);await read.mapAsync(GPUMapMode.READ);const bytes=Array.from(new Uint8Array(read.getMappedRange()).slice(0,samples.length*4));read.unmap();read.destroy();output.destroy();return bytes;
 },reference.toneSamples);
 for(const [i,s] of reference.toneSamples.entries())for(let c=0;c<3;c++)expect(Math.abs(pixels[i*4+c]-s.pixel[c]),JSON.stringify(s.rgb)).toBeLessThanOrEqual(1);
});

async function renderPatches(page,samples){
 return page.evaluate(async samples=>{
  const gpu=__kaguraWebRuntime.webgpu,device=gpu.device;
  device.pushErrorScope('validation');
  const native=samples[0].nativeTexture??false;
  const source=shaderSources.find(s=>s.includes('fn standard_lighting')&&s.includes(`STANDARD_TEXTURE_SRGB = ${native};`));
  if(!source)throw Error('Source-compatible PBR shader is not installed');
  const module=device.createShaderModule({code:source});
  const pipeline=device.createRenderPipeline({layout:'auto',vertex:{module,entryPoint:'vs_main',buffers:[{arrayStride:32,attributes:[{shaderLocation:0,offset:0,format:'float32x3'},{shaderLocation:1,offset:12,format:'float32x3'},{shaderLocation:2,offset:24,format:'float32x2'}]}]},fragment:{module,entryPoint:'fs_main',targets:[{format:'rgba8unorm'}]}});
  const buffer=(data,usage)=>{const b=device.createBuffer({size:data.byteLength,usage:usage|GPUBufferUsage.COPY_DST});device.queue.writeBuffer(b,0,data);return b};
  const vertices=buffer(new Float32Array([-1,-1,0,0,1,0,.5,.5,3,-1,0,0,1,0,.5,.5,-1,3,0,0,1,0,.5,.5]),GPUBufferUsage.VERTEX);
  const width=samples[0].textureWidth??1;
  const white=device.createTexture({size:[width,1],format:native?'rgba8unorm-srgb':'rgba8unorm',usage:GPUTextureUsage.TEXTURE_BINDING|GPUTextureUsage.COPY_DST});device.queue.writeTexture({texture:white},new Uint8Array([255,255,255,255]),{bytesPerRow:4},[1,1]);
  const sampler=device.createSampler({minFilter:'linear',magFilter:'linear'});
  const output=device.createTexture({size:[1,1],format:'rgba8unorm',usage:GPUTextureUsage.RENDER_ATTACHMENT|GPUTextureUsage.COPY_SRC});
  const linear=hex=>[16,8,0].map(shift=>{const v=((hex>>shift)&255)/255;return v<=.04045?v/12.92:((v+.055)/1.055)**2.4});
  const results=[];
  for(const s of samples){
   device.queue.writeTexture({texture:white},new Uint8Array(s.texture ?? [255,255,255,255]),{bytesPerRow:width*4},[width,1]);
   const u=new Float32Array(104);u[0]=u[5]=u[15]=s.distance;u[10]=1;
   for(let i=0;i<4;i++)u[16+i*5]=u[84+i*5]=1;
   u[32]=u[37]=u[42]=1;u.set([35,-65,25],44);u.set(linear(0xfff0d7).map(v=>v*3.2*(s.lightScale??1)),48);u.set(linear(0xe1edff).map(v=>v*1.3*(s.lightScale??1)),52);
   u.set([...s.albedo,1],56);u[60]=s.metallic;u[61]=s.roughness;u.set(s.view.map(v=>v*s.distance),68);
   u.set(linear(0x465154).map(v=>v*1.3*(s.lightScale??1)),72);u[76]=s.environmentIntensity??.55;u[78]=65;u[79]=180;u.set(linear(0xa4b3bd),80);u[96]=1000;
   const uniform=buffer(u,GPUBufferUsage.UNIFORM);
   const group=device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[{binding:0,resource:{buffer:uniform}},{binding:1,resource:white.createView()},{binding:2,resource:sampler},{binding:3,resource:gpu.textures.get(2000).view},{binding:4,resource:sampler},{binding:5,resource:white.createView()},{binding:6,resource:sampler}]});
   const encoder=device.createCommandEncoder(),pass=encoder.beginRenderPass({colorAttachments:[{view:output.createView(),loadOp:'clear',storeOp:'store'}]});pass.setPipeline(pipeline);pass.setBindGroup(0,group);pass.setVertexBuffer(0,vertices);pass.draw(3);pass.end();
   const read=device.createBuffer({size:256,usage:GPUBufferUsage.MAP_READ|GPUBufferUsage.COPY_DST});encoder.copyTextureToBuffer({texture:output},{buffer:read,bytesPerRow:256},[1,1]);device.queue.submit([encoder.finish()]);await read.mapAsync(GPUMapMode.READ);results.push(Array.from(new Uint8Array(read.getMappedRange()).slice(0,4)));read.unmap();read.destroy();uniform.destroy();
  }
  vertices.destroy();white.destroy();output.destroy();const error=await device.popErrorScope();if(error)throw Error(error.message);return results;
 },samples);
}

test('PBR floor, paint, metals and distance fog match original rendered patches',async({page})=>{
 await boot(page);
 const pixels=await renderPatches(page,reference.samples);
 const errors=reference.samples.map((s,i)=>({name:s.name,view:s.view,distance:s.distance,expected:s.pixel,actual:pixels[i],error:Math.max(...s.pixel.map((c,j)=>Math.abs(c-pixels[i][j])))}));
 expect(errors.filter(e=>e.error>2)).toEqual([]);
});


test('sRGB texture and linear material factor agree, and bright reflections retain detail',async({page})=>{
 await boot(page);
 const sample={...reference.samples.find(s=>s.name==='rough-metal'&&s.distance===10),lightScale:0};
 const gray=((128/255+.055)/1.055)**2.4;
 const [factor,texture,low,high]=await renderPatches(page,[
  {...sample,albedo:[gray,gray,gray]},
  {...sample,albedo:[1,1,1],texture:[128,128,128,255]},
  {...sample,environmentIntensity:2}, {...sample,environmentIntensity:8},
 ]);
 for(let c=0;c<3;c++)expect(Math.abs(factor[c]-texture[c])).toBeLessThanOrEqual(1);
 expect(high[0]-low[0]).toBeGreaterThan(8);
});


test('native sRGB filtering decodes before interpolation and agrees with a linear material',async({page})=>{
 await boot(page);
 const sample={...reference.samples.find(s=>s.name==='rough-metal'&&s.distance===10),lightScale:0};
 const [factor]=await renderPatches(page,[{...sample,albedo:[.5,.5,.5]}]);
 const [filtered]=await renderPatches(page,[{...sample,albedo:[1,1,1],nativeTexture:true,textureWidth:2,texture:[0,0,0,255,255,255,255,255]}]);
 for(let c=0;c<3;c++)expect(Math.abs(factor[c]-filtered[c])).toBeLessThanOrEqual(1);
});
