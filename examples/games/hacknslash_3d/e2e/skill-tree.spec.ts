import { test, expect } from "@playwright/test";
import { captureGameFrame } from "../../../../scripts/capture-web.mjs";

const hud = (page) => page.evaluate(() => globalThis.__ashenHud);
test("older saves receive earned tree points once and retain learned skills", async ({
  page,
}) => {
  await page.goto("/?mute=1");
  await page.evaluate(() =>
    localStorage.setItem(
      "hacknslash3d_save",
      "1|0|0||||1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0||4|0|100|0||cleaver",
    ),
  );
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async () => (await hud(page)).mode).toBe("playing");
  expect((await hud(page)).skill_points).toBe(6);
  await page.reload();
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async () => (await hud(page)).mode).toBe("playing");
  expect((await hud(page)).skill_points).toBe(6);
  expect((await hud(page)).nodes[0].level).toBe(1);
});

test("tree inspects locked nodes, allocates real stats once, and persists the build", async ({
  page,
}, info) => {
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.goto("/?snapshot=playing&frames=0&seed=42&mute=1");
  await page.keyboard.press("KeyK");
  await expect(page.locator("[data-tree-node]")).toHaveCount(19);
  const detail = page.getByRole("complementary", {
    name: "選択したスキルの詳細",
  });
  const start = await hud(page);
  const frame = await page.evaluate(
    () => globalThis.__hacknslash3dRuntime.frame,
  );
  await page.locator('[data-tree-node="5"]').click();
  await expect(detail).toContainText("前提スキルが必要");
  await expect(detail.getByRole("button", { name: /習得する/ })).toBeDisabled();
  expect((await hud(page)).skill_points).toBe(3);
  await page.locator('[data-tree-node="3"]').click();
  await expect(detail).toContainText("最大体力 +3");
  expect((await hud(page)).max_hp).toBe(start.max_hp);
  await detail.getByRole("button", { name: /習得する/ }).click();
  await expect.poll(async () => (await hud(page)).skill_points).toBe(2);
  expect((await hud(page)).max_hp).toBe(start.max_hp + 3);
  await page.locator('[data-tree-node="4"]').click();
  await detail.getByRole("button", { name: /習得する/ }).click();
  await expect.poll(async () => (await hud(page)).skill_points).toBe(0);
  await page.locator('[data-tree-node="5"]').click();
  await expect(detail).toContainText("SP不足");
  await expect(detail.locator(".tree-requirements .met")).toHaveCount(2);
  expect(
    await page.evaluate(() => globalThis.__hacknslash3dRuntime.frame),
  ).toBe(frame);
  await captureGameFrame(page, {
    path: info.outputPath("skill-tree-desktop.png"),
  });
  await page.goto("/?seed=42&mute=1");
  await page.locator('[data-save-slot="0"]').click();
  await expect.poll(async () => (await hud(page)).mode).toBe("playing");
  await page.keyboard.press("KeyK");
  await expect(page.locator('[data-tree-node="3"]')).toHaveAttribute(
    "aria-label",
    /Lv 1\/5/,
  );
  await expect(page.locator('[data-tree-node="4"]')).toHaveAttribute(
    "aria-label",
    /Lv 1\/3/,
  );
  expect((await hud(page)).skill_points).toBe(0);
  expect(errors).toEqual([]);
});

test.describe("touch skill tree", () => {
  test.use({
    viewport: { width: 390, height: 844 },
    isMobile: true,
    hasTouch: true,
    deviceScaleFactor: 1,
  });
  test("learned spells and counter appear as usable touch skills", async ({
    page,
  }, info) => {
    await page.goto("/?mute=1");
    await page.evaluate(() =>
      localStorage.setItem(
        "hacknslash3d_save",
        "1|0|0||||1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0||4|0|100|0||cleaver",
      ),
    );
    await page.locator('[data-save-slot="0"]').tap();
    await expect.poll(async () => (await hud(page)).mode).toBe("playing");
    await page.getByRole("button", { name: "技と成長", exact: true }).tap();
    for (const [branch, id] of [
      [/呪術/, 6],
      [/呪術/, 9],
      [/刃術/, 10],
    ] as const) {
      await page
        .locator(".tree-branches")
        .getByRole("button", { name: branch })
        .tap();
      await page.locator(`[data-tree-node="${id}"]`).tap();
      await page
        .locator(".tree-detail")
        .getByRole("button", { name: /習得する/ })
        .tap();
      await expect(page.locator(`[data-tree-node="${id}"]`)).toHaveClass(
        /learned/,
      );
    }
    await page.getByRole("button", { name: "閉じる", exact: true }).tap();
    await expect(page.locator(".learned-arts button")).toHaveCount(3);
    for (const name of ["連鎖雷撃", "追尾の呪弾", "反撃の構え"]) {
      await page
        .locator(".learned-arts")
        .getByRole("button", { name, exact: true })
        .tap();
      await expect
        .poll(
          async () =>
            (await hud(page)).extra_skills.find((s) => s.name === name)
              .remaining,
        )
        .toBeGreaterThan(0);
    }
    await page.setViewportSize({ width: 320, height: 640 });
    const dock = (await page.locator(".action-dock").boundingBox())!;
    expect(dock.x).toBeGreaterThanOrEqual(0);
    expect(dock.y).toBeGreaterThanOrEqual(0);
    expect(dock.x + dock.width).toBeLessThanOrEqual(320);
    expect(dock.y + dock.height).toBeLessThanOrEqual(640);
    await captureGameFrame(page, {
      path: info.outputPath("learned-skills-mobile.png"),
    });
  });
  test("branches and requirements are reachable on narrow and rotated screens", async ({
    page,
  }, info) => {
    await page.goto("/?snapshot=playing&frames=0&seed=42&mute=1");
    await page
      .getByRole("button", { name: "一時停止メニュー", exact: true })
      .tap();
    await page
      .getByRole("dialog")
      .getByRole("button", { name: /技と成長/ })
      .tap();
    await expect(page.locator("[data-tree-node]")).toHaveCount(19);
    const branches = page.locator(".tree-branches");
    await branches.getByRole("button", { name: /生存/ }).tap();
    await page.locator('[data-tree-node="5"]').tap();
    const detail = page.locator(".tree-detail");
    await expect(detail).toContainText("前提スキルが必要");
    await detail.getByRole("button", { name: /急所狙い/ }).tap();
    await expect(page.locator('[data-tree-node="4"]')).toHaveAttribute(
      "aria-pressed",
      "true",
    );
    await detail.getByRole("button", { name: /習得する/ }).tap();
    await expect.poll(async () => (await hud(page)).skill_points).toBe(1);
    expect((await hud(page)).paused).toBe(true);
    for (const viewport of [
      { width: 390, height: 844 },
      { width: 844, height: 390 },
      { width: 320, height: 640 },
    ]) {
      await page.setViewportSize(viewport);
      await branches.getByRole("button", { name: /呪術/ }).tap();
      await page.locator('[data-tree-node="12"]').tap();
      const node = await page.locator('[data-tree-node="12"]').boundingBox();
      expect(node!.x).toBeGreaterThanOrEqual(0);
      expect(node!.x + node!.width).toBeLessThanOrEqual(viewport.width);
      await page.locator(".hunter-panel").evaluate((el) => (el.scrollTop = 0));
      await captureGameFrame(page, {
        path: info.outputPath(`skill-tree-${viewport.width}.png`),
      });
    }
    await page
      .getByRole("button", { name: "一時停止メニューに戻る", exact: true })
      .tap();
    await expect(
      page.getByRole("dialog", { name: "一時停止メニュー", exact: true }),
    ).toBeVisible();
  });
});
