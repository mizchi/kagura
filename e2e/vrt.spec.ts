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
