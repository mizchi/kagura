import {test,expect} from '@playwright/test';

test('compute skinning reuses actual GPU resources and applies changed bones exactly once',async({page})=>{
  await page.goto('/?snapshot=camp&seed=42&mute=1');
  const result=await page.evaluate(async()=>{
    const {renderGpu,releaseGpuResources}=await import('@kagura-web/kagura-gfx.js');
    const adapter=await navigator.gpu.requestAdapter();
    const device=await adapter.requestDevice();
    const errors=[];
    device.addEventListener('uncapturederror',e=>errors.push(e.error.message));
    const canvas=new OffscreenCanvas(64,64),context=canvas.getContext('webgpu');
    const gpu={context,commands:[],textures:new Map()};
    const floats=new Float32Array(1084);
    for(const base of [0,16,60])for(const i of [0,5,10,15])floats[base+i]=1;
    floats[56]=1;
    const vertices=new Float32Array(48);
    [[-.6,-.3],[-.2,-.3],[-.4,.3]].forEach(([x,y],i)=>{
      vertices[i*16]=x;vertices[i*16+1]=y;vertices[i*16+4]=1;vertices[i*16+12]=1;
    });
    const command={isCustom:true,shaderId:891,shaderSource:`
      struct Uniforms {
        mvp: mat4x4<f32>, model: mat4x4<f32>,
        normal0:vec4<f32>,normal1:vec4<f32>,normal2:vec4<f32>,
        light_dir:vec4<f32>,light_color:vec4<f32>,ambient:vec4<f32>,
        num_bones:vec4<f32>,bone_matrices:array<mat4x4<f32>,64>,
      };
      @group(0) @binding(0) var<uniform> uniforms:Uniforms;
      struct VertexInput {
        @location(0) position:vec3<f32>,@location(1) normal:vec3<f32>,@location(2) uv:vec2<f32>,
        @location(3) joints:vec4<f32>,@location(4) weights:vec4<f32>,
      };
      @vertex fn vs_main(v:VertexInput)->@builtin(position) vec4<f32> {
        var p=vec4<f32>(v.position,1.0);
        if (!(uniforms.num_bones.y > 0.5)){p=uniforms.bone_matrices[0]*p;}
        return uniforms.mvp*p;
      }
      @fragment fn fs_main()->@location(0) vec4<f32>{return vec4<f32>(0,1,0,1);}
    `,vertexData:vertices,indices:new Uint32Array([0,1,2]),uniformDwords:new Int32Array(floats.buffer),
      immutableGeometry:true,vertexStride:16,srcImageIds:[],dstImageId:0,dstWidth:64,dstHeight:64,blendMode:0,instanceCount:1};
    const readback=device.createBuffer({size:64*256,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});
    const draw=async()=>{
      gpu.commands=[command];
      if(!renderGpu(gpu,device,context,[0,0,0,1],'rgba8unorm'))throw new Error('render failed');
      const encoder=device.createCommandEncoder();
      encoder.copyTextureToBuffer({texture:context.getCurrentTexture()},{buffer:readback,bytesPerRow:256},[64,64]);
      device.queue.submit([encoder.finish()]);
      await readback.mapAsync(GPUMapMode.READ);
      const bytes=new Uint8Array(readback.getMappedRange());let count=0,sumX=0;
      for(let y=0;y<64;y++)for(let x=0;x<64;x++)if(bytes[y*256+x*4+1]>200){count++;sumX+=x;}
      readback.unmap();
      return {count,x:sumX/count};
    };
    const initial=await draw();
    const slot=gpu._drawResourceCache.skinnedDraws[0];
    const buffers=[slot.input.buffer,slot.output.buffer,slot.computeUniform.buffer,slot.renderUniform.buffer];
    const binding=slot.bindGroup;
    const unchanged=await draw();
    floats[72]=.5;const moved=await draw();
    const reused=buffers.every((b,i)=>b===[slot.input.buffer,slot.output.buffer,slot.computeUniform.buffer,slot.renderUniform.buffer][i])&&binding===slot.bindGroup;
    const bypassFlag=floats[57];
    releaseGpuResources(gpu);readback.destroy();
    await device.queue.onSubmittedWorkDone();device.destroy();
    return {initial,unchanged,moved,reused,bypassFlag,errors};
  });
  expect(result.initial.count).toBeGreaterThan(50);
  expect(result.unchanged).toEqual(result.initial);
  expect(result.moved.count).toBe(result.initial.count);
  expect(result.moved.x-result.initial.x).toBeCloseTo(16,0);
  expect(result.reused).toBe(true);
  expect(result.bypassFlag).toBe(0);
  expect(result.errors).toEqual([]);
});
