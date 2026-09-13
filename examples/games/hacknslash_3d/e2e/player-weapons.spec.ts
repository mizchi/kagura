import { test, expect } from "@playwright/test";
import { PNG } from "pngjs";
import { captureGameFrame } from "../../../../scripts/capture-web.mjs";

for (const viewport of [
  { width: 1280, height: 900 },
  { width: 390, height: 844 },
]) {
  test(`player equips five weapon animations and remembers selection at ${viewport.width}px`, async ({
    page,
  }, info) => {
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    await page.setViewportSize(viewport);
    await page.goto("/?snapshot=playing&frames=0&seed=42&mute=1");
    const picker = page.getByLabel("プレーヤーの武器", { exact: true });
    await expect(picker.locator("option")).toHaveCount(5);
    const ids = ["cleaver_flintlock", "spear", "knuckles", "focus", "bow"];
    const actions = ["斬撃", "刺突", "殴打", "魔法弾", "射撃"];
    for (let i = 0; i < 5; i++) {
      await picker.selectOption(String(i));
      await expect
        .poll(() => page.evaluate(() => globalThis.__ashenHunt.weapon))
        .toBe(ids[i]);
      await expect(page.locator("#weapon-action")).toHaveText(actions[i]);
      await expect
        .poll(() => page.evaluate(() => globalThis.__ashenHud.attack_remaining))
        .toBe(0);
      const before = await page.evaluate(() => globalThis.__ashenHunt.attacks);
      await page.locator("#attack-button").click();
      await expect
        .poll(() => page.evaluate(() => globalThis.__ashenHunt.attacks))
        .toBeGreaterThan(before);
      await expect(picker).toBeDisabled();
      await expect(picker).toBeEnabled();
    }
    // Physical code remains X even on Dvorak (character q).
    await page.evaluate(() => {
      const canvas = document.querySelector("canvas");
      canvas.dispatchEvent(
        new KeyboardEvent("keydown", { code: "KeyX", key: "q", bubbles: true }),
      );
      setTimeout(
        () =>
          canvas.dispatchEvent(
            new KeyboardEvent("keyup", {
              code: "KeyX",
              key: "q",
              bubbles: true,
            }),
          ),
        80,
      );
    });
    await expect(picker).toHaveValue("0");
    await picker.selectOption("4");
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHunt.weapon))
      .toBe("bow");
    const rect = await picker.boundingBox();
    expect(rect.x).toBeGreaterThanOrEqual(0);
    expect(rect.y).toBeGreaterThanOrEqual(0);
    expect(rect.x + rect.width).toBeLessThanOrEqual(viewport.width);
    expect(rect.y + rect.height).toBeLessThanOrEqual(viewport.height);
    await captureGameFrame(page, { path: info.outputPath("weapons-ui.png") });
    await page.goto("/?seed=42&mute=1");
    await page.getByRole("button", { name: /狩りを始める/ }).click();
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHunt.weapon))
      .toBe("bow");
    await expect(picker).toHaveValue("4");
    expect(errors).toEqual([]);
  });
}

for (const [weapon, frames] of [
  ["spear", [8, 16]],
  ["knuckles", [5, 10]],
  ["focus", [12, 24]],
  ["bow", [29, 30]],
] as const) {
  test(`hunter ${weapon} moves its equipped mesh at contact`, async ({
    page,
  }, info) => {
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    const shots: PNG[] = [];
    for (const frame of frames) {
      await page.goto(
        `/?snapshot=hunter&weapon=${weapon}&frames=${frame}&seed=42&mute=1`,
      );
      await page.waitForFunction(() => globalThis.__ashenHunt?.bones === 17);
      expect(await page.evaluate(() => globalThis.__ashenHunt.weapon)).toBe(
        weapon,
      );
      if (weapon === "bow" || weapon === "focus")
        expect(
          await page.evaluate(() => globalThis.__ashenHunt.projectiles),
        ).toBe(frame === frames[1] ? 1 : 0);
      shots.push(
        PNG.sync.read(
          await captureGameFrame(page, {
            path: info.outputPath(`${weapon}-${frame}.png`),
          }),
        ),
      );
    }
    const [a, b] = shots;
    let changed = 0;
    for (let y = Math.floor(b.height * 0.2); y < b.height * 0.8; y++)
      for (let x = Math.floor(b.width * 0.3); x < b.width * 0.7; x++) {
        const i = (y * b.width + x) * 4;
        if (
          Math.abs(a.data[i] - b.data[i]) +
            Math.abs(a.data[i + 1] - b.data[i + 1]) +
            Math.abs(a.data[i + 2] - b.data[i + 2]) >
          70
        )
          changed++;
      }
    expect(changed, "actual rig and weapon silhouette moves").toBeGreaterThan(
      150,
    );
    expect(errors).toEqual([]);
  });
}
