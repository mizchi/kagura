import { test, expect } from "@playwright/test";
import { exampleRecording } from "./fixtures/experience-data.mjs";

const upload = (locator, data) =>
  locator.setInputFiles({
    name: "recording.json",
    mimeType: "application/json",
    buffer: Buffer.from(JSON.stringify(data)),
  });
test("Studio rebuilds reports from recordings, compares baselines, and links evidence without losing a valid report on bad input", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "体験レポート", exact: true }).click();
  const d = page.getByRole("dialog", { name: "体験レポート", exact: true });
  await expect(d).toBeVisible();
  await upload(d.getByLabel("今回の体験記録JSON"), exampleRecording());
  await expect(
    d.getByRole("row").filter({ hasText: "解決と入力の対応率" }),
  ).toContainText("100 %");
  await expect(d.getByRole("table", { name: "体験指標" })).toContainText(
    "プレイヤー役への入力",
  );
  await expect(d.getByRole("table", { name: "体験指標" })).toContainText(
    "未計測",
  );
  await upload(
    d.getByLabel("基準の体験記録JSON"),
    exampleRecording({ bulk: true, id: "baseline" }),
  );
  await expect(d.locator(".experience-summary")).toContainText("input");
  const row = d.getByRole("row").filter({ hasText: "解決あたりのコマンド数" });
  await expect(row).toContainText("2");
  await expect(row).toContainText("+1");
  const broken = exampleRecording();
  broken.events[0].type = "unsupported";
  await upload(d.getByLabel("今回の体験記録JSON"), broken);
  await expect(d.getByRole("alert")).toContainText("Invalid");
  await expect(row).toContainText("+1");
  await row.getByRole("button", { name: /証拠/ }).click();
  await expect(d.getByRole("table", { name: "体験イベント" })).toBeVisible();
  await expect(d.getByLabel("イベントの詳細")).toContainText("input.accepted");
  await d.getByRole("button", { name: "ループとアーク", exact: true }).click();
  await expect(d.getByRole("table", { name: "体験の区間" })).toContainText(
    "初提示",
  );
  await page.screenshot({ path: "output/experience/timeline.png" });
  await d.getByRole("button", { name: "指標", exact: true }).click();
  await page.screenshot({ path: "output/experience/report.png" });
  const download = page.waitForEvent("download");
  await d.getByRole("button", { name: "レポートを書出" }).click();
  expect((await download).suggestedFilename()).toBe("experience-report.json");
});

test("phone report keeps tables locally scrollable and supports keyboard dismissal", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/e2e/fixtures/experience.html");
  const d = page.getByRole("dialog", { name: "体験レポート", exact: true });
  await expect(d).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth)).toBe(
    390,
  );
  await d.getByRole("button", { name: "イベント", exact: true }).click();
  const search = d.getByRole("searchbox");
  await search.fill("e1");
  await expect(d.getByRole("table", { name: "体験イベント" })).toContainText(
    "loop.start",
  );
  await page.screenshot({ path: "output/experience/phone.png" });
  await page.keyboard.press("Escape");
  await expect(d).not.toBeVisible();
});

test("a short phone viewport can bring a full metric row into view", async ({
  page,
}) => {
  await page.setViewportSize({ width: 320, height: 480 });
  await page.goto("/e2e/fixtures/experience.html");
  const row = page.getByRole("row").filter({ hasText: "理解した割合" });
  const label = row.locator("td").first();
  await label.scrollIntoViewIfNeeded();
  await expect(label).toBeInViewport({ ratio: 0.8 });
  await page.screenshot({ path: "output/experience/short-phone.png" });
});

test("report keyboard shortcuts do not edit the scene behind the dialog", async ({
  page,
}) => {
  await page.goto("/");
  await page.waitForFunction(()=>typeof globalThis.kagura?.snapshot==='function');
  const before = await page.evaluate(() => {
    const s = kagura.snapshot();
    kagura.dispatch({
      expectedRevision: s.revision,
      commands: [
        {
          op: "node.rename",
          id: s.document.nodes[0].id,
          name: "Background scene",
        },
      ],
    });
    return kagura.snapshot();
  });
  await page.getByRole("button", { name: "体験レポート", exact: true }).click();
  await page
    .getByRole("dialog", { name: "体験レポート", exact: true })
    .getByRole("button", { name: "指標", exact: true })
    .focus();
  await page.keyboard.press("Control+z");
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(before);
});
