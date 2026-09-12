import {test, expect} from '@playwright/test';

test('terrain uses retained GPU geometry and camera depth runs only for SSAO', async ({page}) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(String(error)));
  for (const ssao of [false, true]) {
    await page.goto(`/?snapshot=playing&frames=0&mute=1&perf=1&ssao=${ssao ? 1 : 0}`);
    await page.waitForFunction(() => globalThis.__hacknslash3dProfile?.worldFrame > 10);
    // The common API must remain usable without the game's diagnostic alias.
    const state = await page.evaluate(() => {
      const gpu = globalThis.__kaguraWebRuntime.webgpu;
      const ssao = globalThis.__hacknslash3dProfile.ssaoEnabled;
      delete globalThis.__hacknslash3dProfile;
      const terrain = gpu.commands.filter(command =>
        command.isCustom && command.dstImageId === 300 && command.blendMode === 0 && command.vertexData.length > 16000);
      return {
        terrainCount: terrain.length,
        retained: terrain.every(command => command.sharedGeometry && command.immutableGeometry),
        depthCount: gpu.commands.filter(command => command.dstImageId === 305).length,
        ssao,
        profile:globalThis.__kaguraProfiler.snapshot(),
      };
    });
    expect(state.terrainCount).toBeGreaterThan(0);
    expect(state.retained).toBe(true);
    expect(state.depthCount).toBe(ssao ? 1 : 0);
    expect(state.ssao).toBe(ssao);
    expect(state.profile.version).toBe(1);
    expect(state.profile.frame).toBeGreaterThan(0);
    expect(state.profile.drawCalls).toBeGreaterThan(0);
    expect(state.profile.drawCallbackMs).toBeGreaterThanOrEqual(0);
    expect(state.profile.sharedGeometryDraws).toBeGreaterThan(0);
  }
  expect(errors).toEqual([]);
});
