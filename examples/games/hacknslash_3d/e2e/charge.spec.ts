import { test, expect } from "@playwright/test";
import { PNG } from "pngjs";
import { captureGameFrame } from "../../../../scripts/capture-web.mjs";

for (const mobile of [false, true]) {
  test(`charge is usable with ${mobile ? "touch" : "physical Dvorak C"}, locks equipment and cancels with dodge`, async ({
    page,
  }, info) => {
    await page.setViewportSize(
      mobile ? { width: 390, height: 844 } : { width: 1280, height: 900 },
    );
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    await page.goto("/?snapshot=playing&frames=0&seed=42&mute=1");
    const button = page.getByRole("button", { name: "突進", exact: true });
    await expect(button).toBeEnabled();
    await page.waitForFunction(() => globalThis.__ashenHunt !== undefined);
    const start = await page.evaluate(() => globalThis.__ashenHunt);
    if (mobile) await button.click();
    else
      await page.evaluate(() => {
        const canvas = document.querySelector("canvas");
        canvas.dispatchEvent(
          new KeyboardEvent("keydown", {
            key: "j",
            code: "KeyC",
            bubbles: true,
          }),
        );
        canvas.dispatchEvent(
          new KeyboardEvent("keyup", { key: "j", code: "KeyC", bubbles: true }),
        );
      });
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHunt.animation))
      .toBe("charging");
    await expect(
      page.getByLabel("プレーヤーの武器", { exact: true }),
    ).toBeDisabled();
    await expect(button).toBeDisabled();
    await expect
      .poll(() =>
        page.evaluate(
          ({ x, y }) =>
            Math.hypot(
              globalThis.__ashenHunt.x - x,
              globalThis.__ashenHunt.y - y,
            ),
          start,
        ),
      )
      .toBeGreaterThan(5);
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHud.charging))
      .toBe(false);
    await expect(button).toBeDisabled();
    await expect(button).toBeEnabled();
    await button.click();
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHud.charging))
      .toBe(true);
    await page.getByRole("button", { name: "回避", exact: true }).click();
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHunt.animation))
      .toBe("dodging");
    await expect
      .poll(() => page.evaluate(() => globalThis.__ashenHud.charging))
      .toBe(false);
    const box = await button.boundingBox();
    expect(box.x).toBeGreaterThanOrEqual(0);
    expect(box.y).toBeGreaterThanOrEqual(0);
    expect(box.x + box.width).toBeLessThanOrEqual(mobile ? 390 : 1280);
    await captureGameFrame(page, {
      path: info.outputPath("charge-controls.png"),
    });
    expect(errors).toEqual([]);
  });
}

test("enemy and hunter charge articulate anticipation, drive and recovery in game", async ({
  page,
}, info) => {
  const shots: PNG[] = [];
  for (const frame of [0, 8, 16, 32]) {
    await page.goto(`/?snapshot=charge&frames=${frame}&seed=42&mute=1`);
    await page.waitForFunction(
      () => globalThis.__ashenHunt?.animation === "charging",
    );
    shots.push(
      PNG.sync.read(
        await captureGameFrame(page, {
          path: info.outputPath(`charge-${frame}.png`),
        }),
      ),
    );
  }
  for (let frame = 1; frame < shots.length; frame++) {
    const a = shots[frame - 1],
      b = shots[frame],
      changed = [0, 0];
    for (let y = Math.floor(b.height * 0.25); y < b.height * 0.72; y++)
      for (let x = Math.floor(b.width * 0.22); x < b.width * 0.78; x++) {
        const i = (y * b.width + x) * 4;
        if (
          Math.abs(a.data[i] - b.data[i]) +
            Math.abs(a.data[i + 1] - b.data[i + 1]) +
            Math.abs(a.data[i + 2] - b.data[i + 2]) >
          70
        )
          changed[x < b.width * 0.5 ? 0 : 1]++;
      }
    for (const count of changed) expect(count).toBeGreaterThan(250);
  }
});
