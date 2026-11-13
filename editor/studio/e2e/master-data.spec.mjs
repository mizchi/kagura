import { test, expect } from "@playwright/test";
import { mkdir } from "node:fs/promises";

async function openEditor(page) {
  await page.goto("/");
  await page
    .getByLabel("Examples", { exact: true })
    .selectOption("dungeon_rpg");
  await expect(page.getByRole("status")).toContainText("Opened project");
  await page
    .getByRole("button", { name: "マスターデータ", exact: true })
    .click();
  return page.getByRole("dialog", { name: "マスターデータ", exact: true });
}
async function edit(control, value) {
  await control.fill(String(value));
  await control.press("Tab");
}
const play = (page) =>
  page
    .getByRole("group", { name: "Project controls", exact: true })
    .getByRole("button", { name: "Play", exact: true })
    .click();
async function ready(page) {
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
    { timeout: 40000 },
  );
  await expect(
    page.frameLocator(".game-frame").locator("#fathom"),
  ).toBeVisible();
}
test("table edits validate, apply on the next Play, and produce real enemy stats and composition", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  const dialog = await openEditor(page);
  const hp = dialog.getByRole("spinbutton", {
    name: "HP（guardian）",
    exact: true,
  });
  await edit(hp, 0);
  await expect(hp).toHaveAttribute("aria-invalid", "true");
  await expect(
    dialog.getByRole("button", { name: "次のPlayに反映" }),
  ).toBeDisabled();
  await mkdir("output/master-data", { recursive: true });
  await page.screenshot({ path: "output/master-data/validation.png" });
  await dialog.getByRole("button", { name: "元に戻す", exact: true }).click();
  await expect(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
  ).toHaveValue("54");
  await edit(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
    70,
  );
  await edit(
    dialog.getByRole("textbox", { name: "名前（guardian）", exact: true }),
    "赤い守護者",
  );
  await dialog.getByRole("button", { name: /遭遇編成/ }).click();
  for (const id of ["b1_a", "b1_b"])
    await dialog
      .getByRole("combobox", { name: `敵1（${id}）`, exact: true })
      .selectOption("guardian");
  await dialog.getByRole("button", { name: "次のPlayに反映" }).click();
  await expect(
    dialog.getByRole("button", { name: "次のPlayに反映" }),
  ).toBeDisabled();
  await mkdir("output/master-data", { recursive: true });
  await page.screenshot({ path: "output/master-data/encounters.png" });
  await dialog.getByRole("button", { name: "マスターデータを閉じる" }).click();
  await play(page);
  await ready(page);
  const frame = page.frameLocator(".game-frame");
  await frame
    .getByRole("button", { name: "迷宮へ入る →", exact: true })
    .click();
  for (const key of [
    "d",
    "w",
    "w",
    "w",
    "w",
    "a",
    "w",
    "w",
    "Enter",
    "w",
    "w",
    "w",
    "w",
  ])
    await page.keyboard.press(key);
  await expect
    .poll(() => page.evaluate(() => kagura.runtime.observe().state.mode))
    .toBe("battle");
  const state = await page.evaluate(() => kagura.runtime.observe().state);
  expect(state.battle.foes[0].name).toBe("赤い守護者");
  expect(state.battle.foes[0].maxHp).toBe(70);
  await page
    .getByRole("button", { name: "マスターデータ", exact: true })
    .click();
  await dialog.getByRole("button", { name: /^敵/ }).first().click();
  await edit(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
    90,
  );
  await dialog.getByRole("button", { name: "次のPlayに反映" }).click();
  expect(
    (await page.evaluate(() => kagura.runtime.observe().state)).battle.foes[0]
      .maxHp,
  ).toBe(70);
  await dialog.getByRole("button", { name: "マスターデータを閉じる" }).click();
  await page
    .getByRole("group", { name: "Project controls", exact: true })
    .getByRole("button", { name: "Stop", exact: true })
    .click();
  await play(page);
  await ready(page);
  expect(
    await frame
      .locator("#fathom")
      .evaluate(
        () =>
          fathom.agent
            .masterData()
            .tables.enemies.find((e) => e.id === "guardian").hp,
      ),
  ).toBe(90);
  expect(errors).toEqual([]);
});
test("import and export preserve the table document and reject broken references without dropping edits", async ({
  page,
}) => {
  const dialog = await openEditor(page);
  await edit(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
    71,
  );
  const download = page.waitForEvent("download");
  await dialog.getByRole("button", { name: "JSON書出" }).click();
  const file = await download;
  const stream = await file.createReadStream();
  let text = "";
  for await (const chunk of stream) text += chunk;
  const exported = JSON.parse(text);
  expect(exported.tables.enemies.find((e) => e.id === "guardian").hp).toBe(71);
  const broken = structuredClone(exported);
  broken.tables.encounters[0].enemy1 = "missing";
  await dialog
    .getByLabel("マスターデータJSONを読み込む")
    .setInputFiles({
      name: "broken.json",
      mimeType: "application/json",
      buffer: Buffer.from(JSON.stringify(broken)),
    });
  await expect(dialog.getByRole("alert")).toContainText("Invalid");
  await expect(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
  ).toHaveValue("71");
  exported.tables.enemies.find((e) => e.id === "guardian").hp = 72;
  await dialog
    .getByLabel("マスターデータJSONを読み込む")
    .setInputFiles({
      name: "valid.json",
      mimeType: "application/json",
      buffer: Buffer.from(JSON.stringify(exported)),
    });
  await expect(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
  ).toHaveValue("72");
  const profile = {
    schemaVersion: 1,
    game: "dungeon_rpg",
    parameters: {
      enemyHpScale: 1.5,
      enemyDamageScale: 1.25,
      encounterSteps: 12,
    },
  };
  await dialog
    .getByLabel("マスターデータJSONを読み込む")
    .setInputFiles({
      name: "profile.json",
      mimeType: "application/json",
      buffer: Buffer.from(JSON.stringify(profile)),
    });
  await expect(
    dialog.getByRole("spinbutton", { name: "HP（guardian）", exact: true }),
  ).toHaveValue("72");
  await page.screenshot({ path: "output/master-data/enemies.png" });
  await dialog.getByRole("button", { name: /遠征ルール/ }).click();
  await expect(
    dialog.getByRole("spinbutton", {
      name: "敵HP倍率（expedition）",
      exact: true,
    }),
  ).toHaveValue("1.5");
});
