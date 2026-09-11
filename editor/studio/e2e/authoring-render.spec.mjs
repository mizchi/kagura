import { test, expect } from '@playwright/test';
test('Kagura authoring hides game HUD and its orbit camera keeps the sky fully covered', async ({ page }) => {
  await page.goto('/');
  await page.getByLabel('Examples', { exact: true }).selectOption('iron_yard');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await expect(page.getByLabel('IRON YARD シーンプレビュー')).toHaveAttribute('data-ready', 'true', {
    timeout: 30000,
  });
  const frame = page.frameLocator('.iron-scene-canvas');
  await expect(frame.locator('.hud')).toBeHidden();
  await expect(frame.locator('.weapon-readout')).toBeHidden();
  await page.getByRole('button', { name: 'hangar-a', exact: true }).click();
  const audit = (shadow = false) =>
    frame.locator('body').evaluate(async (_, shadow) => {
      const gpu = __kaguraWebRuntime.webgpu,
        device = gpu.device,
        target = gpu._renderTargets.get(shadow ? 901 : 900);
      device.pushErrorScope('validation');
      const module = device.createShaderModule({
        code: `
   @group(0) @binding(0) var scene:texture_2d<f32>;
   @group(0) @binding(1) var<storage,read_write> count:atomic<u32>;
   @compute @workgroup_size(8,8) fn main(@builtin(global_invocation_id) p:vec3<u32>){
    let size=textureDimensions(scene);if(p.x>=size.x||p.y>=size.y/${shadow ? 1 : 10}u){return;}
    let color=textureLoad(scene,vec2<i32>(p.xy),0);
    if(${shadow ? 'any(color<vec4<f32>(0.99))' : 'all(color.rgb<vec3<f32>(0.01))||color.a<0.99'}){atomicAdd(&count,1u);}
   }`,
      });
      const pipeline = device.createComputePipeline({
          layout: 'auto',
          compute: { module, entryPoint: 'main' },
        }),
        count = device.createBuffer({ size: 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC }),
        read = device.createBuffer({ size: 4, usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ });
      const encoder = device.createCommandEncoder(),
        pass = encoder.beginComputePass();
      pass.setPipeline(pipeline);
      pass.setBindGroup(
        0,
        device.createBindGroup({
          layout: pipeline.getBindGroupLayout(0),
          entries: [
            { binding: 0, resource: target.view },
            { binding: 1, resource: { buffer: count } },
          ],
        }),
      );
      pass.dispatchWorkgroups(Math.ceil(target.width / 8), Math.ceil(target.height / (shadow ? 8 : 80)));
      pass.end();
      encoder.copyBufferToBuffer(count, 0, read, 0, 4);
      device.queue.submit([encoder.finish()]);
      await read.mapAsync(GPUMapMode.READ);
      const holes = new Uint32Array(read.getMappedRange())[0];
      read.unmap();
      read.destroy();
      count.destroy();
      return { holes, error: (await device.popErrorScope())?.message };
    }, shadow);
  const result = await audit();
  expect(result.error).toBeUndefined();
  expect(result.holes).toBe(0);
  await page.screenshot({ path: '/tmp/kgr-editor-final.png' });
  await page.getByRole('button', { name: '攻撃・エフェクト', exact: true }).click();
  await expect(frame.locator('body')).toBeVisible();
  // The empty action stage must not retain the previous scene's shadow casters.
  await expect.poll(async () => (await audit(true)).holes).toBe(0);
  await page.screenshot({ path: '/tmp/kgr-action-final.png' });
});
