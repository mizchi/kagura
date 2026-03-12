import { expect, test } from "@playwright/test";

type HacknslashRuntime = {
  frame: number;
  mode: string;
  enemyCount: number;
  activeEffectCount: number;
  particleEmitterCount: number;
};

async function waitForHacknslashRuntime(page: import("@playwright/test").Page) {
  await page.goto("/vrt/hacknslash_3d?snapshot=playing&frames=10&stress_enemies=64");
  await page.waitForFunction(
    () => {
      const runtime = (window as { __hacknslash3dRuntime?: HacknslashRuntime }).__hacknslash3dRuntime;
      return runtime != null && runtime.mode === "playing" && runtime.frame > 0;
    },
    null,
    { timeout: 15_000 },
  );
  return await page.evaluate(() => {
    return (window as { __hacknslash3dRuntime: HacknslashRuntime }).__hacknslash3dRuntime;
  });
}

async function readHacknslashRuntime(page: import("@playwright/test").Page) {
  return await page.evaluate(() => {
    return (window as { __hacknslash3dRuntime: HacknslashRuntime }).__hacknslash3dRuntime;
  });
}

async function expectEffectActivation(
  page: import("@playwright/test").Page,
  key: string,
) {
  const before = await readHacknslashRuntime(page);
  await page.locator("canvas").click();
  await page.keyboard.press(key);
  await page.waitForFunction(
    (previous) => {
      const runtime = (window as { __hacknslash3dRuntime?: HacknslashRuntime }).__hacknslash3dRuntime;
      if (runtime == null) return false;
      return (
        runtime.activeEffectCount > previous.activeEffectCount ||
        runtime.particleEmitterCount > previous.particleEmitterCount
      );
    },
    before,
    { timeout: 5_000 },
  );
  const after = await readHacknslashRuntime(page);
  expect(after.enemyCount).toBeGreaterThan(0);
  expect(
    after.activeEffectCount > before.activeEffectCount ||
      after.particleEmitterCount > before.particleEmitterCount,
  ).toBeTruthy();
}

test("hacknslash_3d activates chain lightning, splitting fireball, ice nova, and homing missile effects", async ({ page }) => {
  const runtime = await waitForHacknslashRuntime(page);
  expect(runtime.enemyCount).toBeGreaterThan(0);

  await expectEffectActivation(page, "4");
  await expectEffectActivation(page, "5");
  await expectEffectActivation(page, "6");
  await expectEffectActivation(page, "7");
});
