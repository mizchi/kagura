import { test, expect } from "@playwright/test";
import { PNG } from "pngjs";
import { fileURLToPath } from "node:url";
const file = fileURLToPath(
  new URL(
    "../../../examples/games/hacknslash_3d/motions/enemies.kgrmotion",
    import.meta.url,
  ),
);
const resource = "motions/enemies.kgrmotion";
const open = async (page) => {
  await page.goto("/");
  await page
    .getByLabel("Examples", { exact: true })
    .selectOption("hacknslash_3d");
  await expect(page.getByRole("status")).toContainText("Opened project");
  await page.getByRole("button", { name: resource, exact: true }).click();
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-ready",
    "true",
  );
};

test("motion viewer selects real models, scrubs poses, steps and plays without changing the scene", async ({
  page,
}, info) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await open(page);
  const before = await page.evaluate(() => kagura.snapshot());
  await page
    .getByLabel("Motion model", { exact: true })
    .selectOption("skeleton");
  await page.getByLabel("Motion weapon", { exact: true }).selectOption("bow");
  await expect(page.getByLabel("Motion clip", { exact: true })).toHaveValue(
    "bow_shot",
  );
  await page.evaluate(() => kagura.motions.seek(0.2));
  await page.getByLabel("Motion model", { exact: true }).selectOption("goblin");
  const equipped = await page.evaluate(() => kagura.motions.snapshot());
  expect(equipped.model).toBe("goblin");
  expect(equipped.weapon).toBe("bow");
  expect(equipped.transport.clip).toBe("bow_shot");
  expect(equipped.transport.time).toBe(0.2);
  expect(equipped.clips.map((clip) => clip.id)).toEqual(["bow_shot", "charge"]);
  await expect(
    page.getByLabel("Motion clip", { exact: true }).locator("option"),
  ).toHaveCount(2);
  const invalid = await page.evaluate(() => {
    try {
      kagura.motions.selectClip("punch");
    } catch (error) {
      return error.message;
    }
  });
  expect(invalid).toContain("selected weapon");
  expect(await page.evaluate(() => kagura.motions.snapshot())).toEqual(
    equipped,
  );
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-frame",
    "12",
  );
  const a = PNG.sync.read(
    await page.getByLabel("Motion viewport", { exact: true }).screenshot(),
  );
  await page
    .getByRole("button", { name: "Release · 0.60s", exact: true })
    .click();
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-frame",
    "36",
  );
  const b = PNG.sync.read(
    await page.getByLabel("Motion viewport", { exact: true }).screenshot(),
  );
  let changed = 0;
  for (let i = 0; i < a.data.length; i += 4)
    if (
      Math.abs(a.data[i] - b.data[i]) +
        Math.abs(a.data[i + 1] - b.data[i + 1]) +
        Math.abs(a.data[i + 2] - b.data[i + 2]) >
      80
    )
      changed++;
  expect(changed, "actual GPU skin poses differ").toBeGreaterThan(400);
  await page
    .getByRole("button", { name: "Previous motion frame", exact: true })
    .click();
  expect(
    (await page.evaluate(() => kagura.motions.snapshot())).transport.frame,
  ).toBe(35);
  await page
    .getByRole("button", { name: "Next motion frame", exact: true })
    .click();
  expect(
    (await page.evaluate(() => kagura.motions.snapshot())).transport.frame,
  ).toBe(36);
  await page.getByLabel("Show motion skeleton", { exact: true }).check();
  expect((await page.evaluate(() => kagura.motions.snapshot())).skeleton).toBe(
    true,
  );
  await page
    .getByRole("button", { name: "Motion camera side", exact: true })
    .click();
  await page.getByLabel("Motion speed", { exact: true }).selectOption("2");
  await page.getByLabel("Loop motion", { exact: true }).uncheck();
  await page.getByRole("button", { name: "Play motion", exact: true }).click();
  await expect
    .poll(
      async () =>
        (await page.evaluate(() => kagura.motions.snapshot())).transport
          .playing,
    )
    .toBe(false);
  const end = await page.evaluate(() => kagura.motions.snapshot());
  expect(end.transport.time).toBe(end.transport.duration);
  await page
    .getByRole("button", { name: "Rewind motion", exact: true })
    .click();
  await page.getByRole("button", { name: "Play motion", exact: true }).click();
  await expect
    .poll(
      async () =>
        (await page.evaluate(() => kagura.motions.snapshot())).transport.time,
    )
    .toBeGreaterThan(0.05);
  await page.getByRole("button", { name: "Pause motion", exact: true }).click();
  const paused = (await page.evaluate(() => kagura.motions.snapshot()))
    .transport.time;
  await page.waitForTimeout(120);
  expect(
    (await page.evaluate(() => kagura.motions.snapshot())).transport.time,
  ).toBe(paused);
  const after = await page.evaluate(() => kagura.snapshot());
  expect(after.document).toEqual(before.document);
  expect(after.revision).toBe(before.revision);
  await page
    .getByRole("button", { name: "Motion camera orbit", exact: true })
    .click();
  await page.evaluate(() => kagura.motions.seek(0.56));
  await page
    .getByLabel("Motion viewer workspace", { exact: true })
    .screenshot({ path: info.outputPath("motion-viewer.png") });
  await page.getByRole("tab", { name: "Project", exact: true }).click();
  await expect(page.getByLabel("Motion viewport", { exact: true })).toHaveCount(
    0,
  );
  expect((await page.evaluate(() => kagura.motions.snapshot())).state).toBe(
    "idle",
  );
  expect(errors).toEqual([]);
});

test("generic editor imports motion files without a game extension and disposes on close", async ({
  page,
}) => {
  await page.goto("/");
  await page.waitForFunction(() => globalThis.kagura?.motions);
  const before = await page.evaluate(() => kagura.snapshot());
  await page.getByRole("tab", { name: "Motions", exact: true }).click();
  await page
    .getByLabel("Import motion asset", { exact: true })
    .setInputFiles(file);
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-ready",
    "true",
  );
  await page
    .getByLabel("Motion model", { exact: true })
    .selectOption("skeleton");
  await page.getByLabel("Motion weapon", { exact: true }).selectOption("focus");
  await expect(page.getByLabel("Motion clip", { exact: true })).toHaveValue(
    "cast_spell",
  );
  await page.getByLabel("Motion time", { exact: true }).fill("1.25");
  expect(
    (await page.evaluate(() => kagura.motions.snapshot())).transport.time,
  ).toBe(1.25);
  expect((await page.evaluate(() => kagura.snapshot())).document).toEqual(
    before.document,
  );
  await page
    .getByRole("button", { name: "Close motion viewer", exact: true })
    .click();
  await expect(page.getByLabel("Motion viewport", { exact: true })).toHaveCount(
    0,
  );
});

test("superseded loads and project switches cannot leave a stale motion renderer", async ({
  page,
}) => {
  await open(page);
  const result = await page.evaluate(async (path) => {
    const a = kagura.motions.preview(path).catch((e) => e.name);
    const b = kagura.motions.preview(path);
    return [await a, await b];
  }, resource);
  expect(result[0]).toBe("AbortError");
  expect(result[1].state).toBe("ready");
  await expect(page.getByLabel("Motion viewport", { exact: true })).toHaveCount(
    1,
  );
  await page
    .getByLabel("Examples", { exact: true })
    .selectOption("model_assets");
  await expect(page.getByRole("status")).toContainText("Opened project");
  await expect(page.getByLabel("Motion viewport", { exact: true })).toHaveCount(
    0,
  );
  expect((await page.evaluate(() => kagura.motions.snapshot())).state).toBe(
    "idle",
  );
});

test("hunter resource previews the same five playable weapon sets", async ({
  page,
}, info) => {
  const errors = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.goto("/");
  await page
    .getByLabel("Examples", { exact: true })
    .selectOption("hacknslash_3d");
  await expect(page.getByRole("status")).toContainText("Opened project");
  await page
    .getByRole("button", { name: "motions/hunter.kgrmotion", exact: true })
    .click();
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-ready",
    "true",
  );
  await expect(page.getByLabel("Motion model", { exact: true })).toHaveValue(
    "hunter",
  );
  const picker = page.getByLabel("Motion weapon", { exact: true });
  await expect(picker.locator("option")).toHaveCount(5);
  for (const weapon of [
    "cleaver_flintlock",
    "spear",
    "knuckles",
    "focus",
    "bow",
  ]) {
    await picker.selectOption(weapon);
    await expect(page.getByLabel("Motion clip", { exact: true })).toHaveValue(
      weapon + "_attack",
    );
    await page.evaluate(() => {
      const state = kagura.motions.snapshot();
      kagura.motions.seek(state.clips[0].events[0].time - 1 / 60);
    });
    await page
      .getByLabel("Motion viewer workspace", { exact: true })
      .screenshot({ path: info.outputPath("hunter-" + weapon + ".png") });
  }
  await page
    .getByRole("button", { name: "Release · 0.50s", exact: true })
    .click();
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-frame",
    "30",
  );
  await page.getByLabel("Motion clip", { exact: true }).selectOption("charge");
  await page
    .getByRole("button", { name: "Launch · 0.20s", exact: true })
    .click();
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-frame",
    "12",
  );
  await page
    .getByRole("button", { name: "Brake · 0.40s", exact: true })
    .click();
  await expect(page.locator(".motion-stage")).toHaveAttribute(
    "data-frame",
    "24",
  );
  await page
    .getByLabel("Motion viewer workspace", { exact: true })
    .screenshot({ path: info.outputPath("hunter-charge.png") });
  expect(errors).toEqual([]);
});
