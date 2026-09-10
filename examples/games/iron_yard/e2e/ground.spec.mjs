import {test,expect} from '@playwright/test';

test('real floor markings remain behind real models when opaque draw order is reversed',async({page})=>{
 await page.goto('/');await expect(page.getByRole('button',{name:'出撃する',exact:true})).toBeEnabled();
 await page.evaluate(()=>{
  const render=__kaguraGfx.render;
  __kaguraGfx.render=(gpu,...args)=>{globalThis.capturedFrame={gpu,args,commands:gpu.commands.map(c=>({...c,uniformDwords:c.uniformDwords.slice(),srcImageIds:c.srcImageIds?.slice()})),render};return render(gpu,...args)};
 });
 await page.waitForFunction(()=>globalThis.capturedFrame);
 const result=await page.evaluate(async()=>{
  const {gpu,args,commands,render}=capturedFrame,device=gpu.device;
  __kaguraGfx.render=()=>{gpu.commands=[];return true};
  device.pushErrorScope('validation');
  const before=commands.filter(c=>c.dstImageId===901);
  const opaque=commands.filter(c=>c.dstImageId===900&&c.blendMode===0);
  const after=commands.filter(c=>c.dstImageId!==901&&c.dstImageId!==900);
  const target=gpu._renderTargets.get(900),size=target.width*target.height*4;
  const module=device.createShaderModule({code:`
    @group(0) @binding(0) var scene:texture_2d<f32>;
    @group(0) @binding(1) var<storage,read_write> pixels:array<u32>;
    @compute @workgroup_size(8,8) fn main(@builtin(global_invocation_id) p:vec3<u32>){
      let size=textureDimensions(scene);if(any(p.xy>=size)){return;}
      pixels[p.y*size.x+p.x]=pack4x8unorm(textureLoad(scene,vec2<i32>(p.xy),0));
    }`});
  const pipeline=device.createComputePipeline({layout:'auto',compute:{module,entryPoint:'main'}});
  const output=device.createBuffer({size,usage:GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_SRC});
  async function draw(draws){
    gpu.commands=[...before,...draws,...after];render(gpu,...args);
    const encoder=device.createCommandEncoder(),pass=encoder.beginComputePass();pass.setPipeline(pipeline);
    pass.setBindGroup(0,device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[{binding:0,resource:target.view},{binding:1,resource:{buffer:output}}]}));
    pass.dispatchWorkgroups(Math.ceil(target.width/8),Math.ceil(target.height/8));pass.end();
    const read=device.createBuffer({size,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});encoder.copyBufferToBuffer(output,0,read,0,size);device.queue.submit([encoder.finish()]);await read.mapAsync(GPUMapMode.READ);const bytes=new Uint8Array(read.getMappedRange()).slice();read.unmap();read.destroy();return bytes;
  }
  const forward=await draw(opaque),reverse=await draw([...opaque].reverse());
  let changed=0,total=0;
  // Actual STRIX and deployment ring, excluding HUD (which is DOM).
  for(let y=Math.floor(target.height*.60);y<target.height*.9;y++)for(let x=Math.floor(target.width*.32);x<target.width*.62;x++){
    const i=(y*target.width+x)*4;total++;
    if(Math.max(...[0,1,2].map(c=>Math.abs(forward[i+c]-reverse[i+c])))>2)changed++;
  }
  output.destroy();const error=await device.popErrorScope();return {changed,total,opaque:opaque.length,error:error?.message};
 });
 expect(result.error).toBeUndefined();expect(result.opaque).toBeGreaterThan(100);
 // Shared/coplanar triangle boundaries can differ by a few pixels.
 expect(result.changed/result.total).toBeLessThan(.005);
});
