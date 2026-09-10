import {waitForRenderer} from './renderer-ready.mjs';
import {test,expect} from '@playwright/test';

test('scene uses resolved 4x MSAA, source pixel ratio and native sRGB sampler settings',async({page})=>{
 await page.goto('/');await expect(page.getByRole('button',{name:'出撃する',exact:true})).toBeEnabled();
 await waitForRenderer(page);
 const info=await page.evaluate(async()=>{
  const gpu=__kaguraWebRuntime.webgpu,scene=gpu._renderTargets.get(900),shadow=gpu._renderTargets.get(901);
  const adapter=await navigator.gpu.requestAdapter();
  return {gpuVendor:adapter.info.vendor,architecture:adapter.info.architecture,samples:scene.samples,shadowSamples:shadow.samples,format:gpu.textures.get(1000).format,
   dpr:__kaguraWebRuntime.dpr,expectedDpr:Math.min(devicePixelRatio,1.5),error:gpu.lastError};
 });
 if(process.env.IRON_YARD_GPU==='metal'){expect(info.gpuVendor).toBe('apple');expect(info.architecture).toContain('metal');}
 expect(info.samples).toBe(4);expect(info.shadowSamples).toBe(1);
 expect(info.format).toBe('rgba8unorm-srgb');expect(info.dpr).toBe(info.expectedDpr);expect(info.error).toBe('');
 await page.setViewportSize({width:933,height:677});
 await expect.poll(()=>page.evaluate(()=>document.querySelector('canvas').width)).toBe(Math.round(933*info.expectedDpr));
});
