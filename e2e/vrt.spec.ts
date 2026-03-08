import { test, expect } from "@playwright/test";

// VRT examples categorized by rendering pipeline.
// Categories help diagnose failures:
//   2d-scene:  @scene declarative API (sprite, text, shape)
//   2d-game:   full game loop (scene + input + audio)
//   3d-render: 3D pipeline (mesh, lighting, shadow)
//   3d-postfx: 3D + post-processing (bloom, tonemap, FXAA)
//   asset:     asset loading integration
interface VrtEntry {
  name: string;
  category: "2d-scene" | "2d-game" | "3d-render" | "3d-postfx" | "asset";
}

const VRT_EXAMPLES: VrtEntry[] = [
  { name: "scene_demo", category: "2d-scene" },
  { name: "ui_demo", category: "2d-scene" },
  { name: "flappy_bird", category: "2d-game" },
  { name: "survivor", category: "2d-game" },
  { name: "action_rpg", category: "2d-game" },
  { name: "fps_demo", category: "2d-game" },
  { name: "physics2d_demo", category: "2d-game" },
  { name: "arena3d", category: "3d-render" },
  { name: "collision3d_demo", category: "3d-render" },
  { name: "physics3d_demo", category: "3d-render" },
  { name: "skeletal_anim", category: "3d-render" },
  { name: "ragdoll_demo", category: "3d-render" },
  { name: "obj_viewer", category: "3d-render" },
  { name: "gltf_viewer", category: "3d-render" },
  { name: "shadow3d_demo", category: "3d-postfx" },
  { name: "postfx_demo", category: "3d-postfx" },
  { name: "hacknslash_3d", category: "3d-postfx" },
  { name: "fetch_image", category: "asset" },
];

async function waitForKaguraReady(page: import("@playwright/test").Page) {
  await page.waitForFunction(
    () =>
      (globalThis as { __kaguraWebRuntime?: { webgpu?: { presentScheduled?: boolean } } })
        .__kaguraWebRuntime?.webgpu?.presentScheduled !== undefined,
    { timeout: 15_000 },
  );
}

for (const { name, category } of VRT_EXAMPLES) {
  test(`VRT [${category}]: ${name} renders`, async ({ page }) => {
    await page.goto(`/vrt/${name}`);
    await waitForKaguraReady(page);
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
    await waitForKaguraReady(page);
    if (tick > 0) {
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
