import { test, expect } from "@playwright/test";

const VRT_EXAMPLES = [
  "scene_demo",
  "flappy_bird",
  "survivor",
  "ui_demo",
  "action_rpg",
  "fps_demo",
  "arena3d",
  "collision3d_demo",
  "physics2d_demo",
  "physics3d_demo",
  "postfx_demo",
  "shadow3d_demo",
  "skeletal_anim",
  "ragdoll_demo",
  "obj_viewer",
  "gltf_viewer",
  "fetch_image",
  "hacknslash_3d",
];

for (const name of VRT_EXAMPLES) {
  test(`VRT: ${name} renders`, async ({ page }) => {
    await page.goto(`/vrt/${name}`);
    // Wait for kagura runtime initialization + a few frames
    await page.waitForFunction(
      () =>
        (globalThis as { __kaguraWebRuntime?: { webgpu?: { presentScheduled?: boolean } } })
          .__kaguraWebRuntime?.webgpu?.presentScheduled !== undefined,
      { timeout: 15_000 },
    );
    await page.waitForTimeout(500);
    const canvas = page.locator("#app");
    await expect(canvas).toHaveScreenshot(`${name}.png`, {
      maxDiffPixelRatio: 0.01,
    });
  });
}

// Snapshot mode tests: render specific game states via URL params
// tick: number of rendered frames to wait before capture (ensures PostFX pipeline runs)
const SNAPSHOT_TESTS = [
  { name: "hacknslash_3d", params: "?snapshot=playing&frames=60&tick=5", tick: 5, suffix: "playing" },
];

for (const { name, params, tick, suffix } of SNAPSHOT_TESTS) {
  test(`VRT: ${name} ${suffix}`, async ({ page }) => {
    await page.goto(`/vrt/${name}${params}`);
    await page.waitForFunction(
      () =>
        (globalThis as { __kaguraWebRuntime?: { webgpu?: { presentScheduled?: boolean } } })
          .__kaguraWebRuntime?.webgpu?.presentScheduled !== undefined,
      { timeout: 15_000 },
    );
    if (tick > 0) {
      // Wait until the game has rendered the required number of frames
      await page.waitForFunction(
        (target) =>
          ((globalThis as { __kaguraSnapshotTick?: number }).__kaguraSnapshotTick ?? 0) >= target,
        tick,
        { timeout: 10_000 },
      );
    } else {
      await page.waitForTimeout(500);
    }
    const canvas = page.locator("#app");
    await expect(canvas).toHaveScreenshot(`${name}-${suffix}.png`, {
      maxDiffPixelRatio: 0.01,
    });
  });
}
