import { test, expect } from "@playwright/test";

test("a different schema controls row creation, booleans, enums and cross-table references", async ({
  page,
}) => {
  await page.goto("/e2e/fixtures/master-data.html");
  const d = page.getByRole("dialog", { name: "マスターデータ", exact: true });
  await expect(d).toBeVisible();
  await d.getByRole("checkbox", { name: "使用可能（sword）" }).uncheck();
  await d
    .getByRole("combobox", { name: "分類（sword）" })
    .selectOption("armor");
  await d.getByRole("button", { name: "行を追加" }).click();
  await expect(d.getByRole("textbox", { name: "名前（row_1）" })).toHaveValue(
    "新しい道具",
  );
  await expect(
    d.getByRole("combobox", { name: "希少度（row_1）", exact: true }),
  ).toBeDisabled();
  await d
    .getByRole("checkbox", { name: "希少度を未設定（row_1）", exact: true })
    .uncheck();
  await d
    .getByRole("combobox", { name: "希少度（row_1）", exact: true })
    .selectOption("rare");
  await d
    .getByRole("checkbox", { name: "取引可能を未設定（row_1）", exact: true })
    .uncheck();
  await d
    .getByRole("checkbox", { name: "取引可能（row_1）", exact: true })
    .check();
  await d.getByRole("button", { name: /編成/ }).click();
  await d.getByRole("combobox", { name: "道具（boss）" }).selectOption("row_1");
  await d.getByRole("button", { name: /道具/ }).first().click();
  await d
    .locator("tr[data-row=sword]")
    .getByRole("button", { name: "削除" })
    .click();
  await d.getByRole("button", { name: "次のPlayに反映" }).click();
  const data = await page.evaluate(async () =>
    JSON.parse(
      await (await masterDataFixture.project.resource("master")).text(),
    ),
  );
  expect(data.tables.items).toHaveLength(1);
  expect(data.tables.encounters[0].item).toBe("row_1");
  expect(data.tables.items[0].rarity).toBe("rare");
  expect(data.tables.items[0].tradable).toBe(true);
});

test("the master table stays inside the phone dialog with keyboard access and local scrolling", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/e2e/fixtures/master-data.html?game=fathom");
  const d = page.getByRole("dialog", { name: "マスターデータ", exact: true });
  await expect(d).toBeVisible();
  expect(
    await d.evaluate((el) => el.getBoundingClientRect().top),
  ).toBeGreaterThanOrEqual(66);
  const width = await page.evaluate(() => ({
    page: document.documentElement.scrollWidth,
    width: innerWidth,
    dialog: document.querySelector("dialog").getBoundingClientRect().width,
  }));
  expect(width.page).toBe(width.width);
  expect(width.dialog).toBeLessThanOrEqual(width.width);
  await d.getByRole("button", { name: /遠征ルール/ }).click();
  const input = d.getByRole("spinbutton", {
    name: "B1遭遇間隔（歩）（expedition）",
    exact: true,
  });
  await input.fill("12");
  await input.press("Tab");
  await d.getByRole("button", { name: "次のPlayに反映" }).click();
  await page.screenshot({ path: "output/master-data/phone.png" });
  await page.keyboard.press("Escape");
  await expect(d).not.toBeVisible();
});

test("a writable project saves the validated master resource through the same UI", async ({
  page,
}) => {
  await page.goto("/e2e/fixtures/master-data.html?writable=1");
  const d = page.getByRole("dialog", { name: "マスターデータ", exact: true });
  await expect(d).toBeVisible();
  const name = d.getByRole("textbox", { name: "名前（sword）", exact: true });
  await name.fill("銀の剣");
  await name.press("Tab");
  await d.getByRole("button", { name: "フォルダへ保存", exact: true }).click();
  await expect(d.locator(".master-data-status")).toContainText("反映済み");
  const saved = await page.evaluate(async () => {
    const p = await masterDataFixture.project.reopen();
    try {
      return JSON.parse(await (await p.resource("master")).text());
    } finally {
      p.dispose();
    }
  });
  expect(saved.tables.items[0].name).toBe("銀の剣");
  await page.screenshot({ path: "output/master-data/generic.png" });
});
