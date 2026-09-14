import { test, expect } from "@playwright/test";
import { captureGameFrame } from "../../../../scripts/capture-web.mjs";

const stoppedState = (page) =>
  page.evaluate(() => ({
    hero: globalThis.__ashenHunt,
    frame: globalThis.__hacknslash3dRuntime.frame,
    charge: globalThis.__ashenHud.charge,
    chargeFrame: globalThis.__ashenHud.charge_frame,
    skills: globalThis.__ashenHud.skills,
  }));

test("Escape freezes combat, animation, camera and clocks, and pause submenus remain stopped", async ({
  page,
}, info) => {
  const errors: string[] = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page.goto("/?snapshot=playing&frames=0&seed=42&mute=1");
  const dashStrike = page.locator("#dash-strike-button");
  await expect(dashStrike).toHaveAccessibleName("突進斬り");
  await expect(dashStrike).toBeEnabled();
  await dashStrike.click();
  await expect
    .poll(() => page.evaluate(() => globalThis.__ashenHud.charging))
    .toBe(true);
  await page.keyboard.press("Escape");
  const menu = page.getByRole("dialog", {
    name: "一時停止メニュー",
    exact: true,
  });
  await expect(menu).toBeVisible();
  const resume = menu.getByRole("button", { name: /冒険を再開する/ });
  await expect(resume).toBeFocused();
  const before = await stoppedState(page);
  expect(before.hero.paused).toBe(true);
  await page.keyboard.down("KeyW");
  await page.keyboard.down("KeyQ");
  await page.keyboard.down("KeyJ");
  await page.mouse.move(40, 400);
  await page.mouse.wheel(0, -220);
  await page.waitForTimeout(250);
  await page.keyboard.up("KeyW");
  await page.keyboard.up("KeyQ");
  await page.keyboard.up("KeyJ");
  expect(await stoppedState(page)).toEqual(before);
  await page.evaluate(() =>
    window.dispatchEvent(
      new KeyboardEvent("keydown", {
        code: "Escape",
        key: "Escape",
        repeat: true,
        bubbles: true,
      }),
    ),
  );
  await expect(menu).toBeVisible();
  await page.keyboard.press("Shift+Tab");
  await expect(
    menu.getByRole("button", { name: "サウンド", exact: true }),
  ).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(resume).toBeFocused();
  await menu.getByRole("button", { name: /装備袋/ }).click();
  await expect(
    page.getByRole("heading", { name: "装備袋", exact: true }),
  ).toBeVisible();
  expect((await stoppedState(page)).frame).toBe(before.frame);
  await page.keyboard.press("Escape");
  await expect(menu).toBeVisible();
  await menu.getByRole("button", { name: /技と成長/ }).click();
  await expect(
    page.getByRole("heading", { name: "技と成長", exact: true }),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "一時停止メニューに戻る", exact: true })
    .click();
  await expect(menu).toBeVisible();
  expect(await stoppedState(page)).toEqual(before);
  await menu.getByRole("button", { name: "サウンド", exact: true }).click();
  await expect(
    menu.getByRole("button", { name: "サウンド", exact: true }),
  ).toHaveAttribute("aria-pressed", "true");
  await captureGameFrame(page, { path: info.outputPath("pause-menu.png") });
  await page.keyboard.press("Escape");
  await expect(menu).toHaveCount(0);
  await expect
    .poll(() => page.evaluate(() => globalThis.__ashenHunt.paused))
    .toBe(false);
  await expect
    .poll(() => page.evaluate(() => globalThis.__hacknslash3dRuntime.frame))
    .toBeGreaterThan(before.frame);
  expect(errors).toEqual([]);
});

test.describe("touch pause menu", () => {
  test.use({
    viewport: { width: 390, height: 844 },
    hasTouch: true,
    isMobile: true,
    deviceScaleFactor: 1,
  });
  test("pause and resume by touch with portrait and landscape layouts", async ({
    page,
  }, info) => {
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    await page.goto("/?snapshot=playing&frames=0&seed=42&mute=1");
    await page
      .getByRole("button", { name: "一時停止メニュー", exact: true })
      .tap();
    const menu = page.getByRole("dialog", {
      name: "一時停止メニュー",
      exact: true,
    });
    await expect(menu).toBeVisible();
    const before = await stoppedState(page);
    for (const viewport of [
      { width: 390, height: 844 },
      { width: 844, height: 390 },
      { width: 320, height: 640 },
    ]) {
      await page.setViewportSize(viewport);
      for (const button of await menu.locator("button,select").all()) {
        const rect = (await button.boundingBox())!;
        expect(rect.x).toBeGreaterThanOrEqual(0);
        expect(rect.y).toBeGreaterThanOrEqual(0);
        expect(rect.x + rect.width).toBeLessThanOrEqual(viewport.width);
        expect(rect.y + rect.height).toBeLessThanOrEqual(viewport.height);
      }
      expect((await stoppedState(page)).frame).toBe(before.frame);
      await captureGameFrame(page, {
        path: info.outputPath(`pause-${viewport.width}.png`),
      });
    }
    await menu.getByRole("button", { name: /冒険を再開する/ }).tap();
    await expect(menu).toHaveCount(0);
    await expect
      .poll(() => page.evaluate(() => globalThis.__hacknslash3dRuntime.frame))
      .toBeGreaterThan(before.frame);
    expect((await stoppedState(page)).hero.attacks).toBe(before.hero.attacks);
    expect(errors).toEqual([]);
  });
});
