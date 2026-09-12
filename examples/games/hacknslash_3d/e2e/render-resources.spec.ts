import {test, expect} from '@playwright/test';

test('terrain uses retained GPU geometry and camera depth runs only for SSAO', async ({page}) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(String(error)));
  for (const ssao of [false, true]) {
    await page.goto(`/?snapshot=playing&frames=0&mute=1&perf=1&ssao=${ssao ? 1 : 0}`);
    await page.waitForFunction(() => globalThis.__hacknslash3dProfile?.worldFrame > 10);
    const state = await page.evaluate(() => {
      const gpu = globalThis.__kaguraWebRuntime.webgpu;
      const terrain = gpu.commands.filter(command =>
        command.isCustom && command.dstImageId === 300 && command.blendMode === 0 && command.vertexData.length > 16000);
      return {
        terrainCount: terrain.length,
        retained: terrain.every(command => command.sharedGeometry && command.immutableGeometry),
        depthCount: gpu.commands.filter(command => command.dstImageId === 305).length,
        ssao: globalThis.__hacknslash3dProfile.ssaoEnabled,
      };
    });
    expect(state.terrainCount).toBeGreaterThan(0);
    expect(state.retained).toBe(true);
    expect(state.depthCount).toBe(ssao ? 1 : 0);
    expect(state.ssao).toBe(ssao);
  }
  expect(errors).toEqual([]);
});
