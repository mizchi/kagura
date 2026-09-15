import { test, expect } from "@playwright/test";
import { readFile } from "node:fs/promises";

async function open(page) {
  await page.goto("/");
  await page
    .getByRole("button", { name: "Open 3D modeling", exact: true })
    .click();
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
}
const state = (page) => page.evaluate(() => kagura.modeling.snapshot());

test("shared preset URLs override saved drafts without overwriting them or adding undo history", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await open(page);
  const initial = (await state(page)).document;
  const draft = await page.evaluate(async () => {
    kagura.modeling.request({ op: "add", kind: "cube" });
    await kagura.modeling.save();
    return kagura.modeling.snapshot().document;
  });
  const shared = "/?mode=modeling&model=kawaiiko";
  await page.goto(shared);
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
  expect((await state(page)).document).toEqual(initial);
  expect((await state(page)).canUndo).toBe(false);
  expect((await state(page)).revision).toBe(0);
  await page
    .getByRole("button", { name: "Add model sphere", exact: true })
    .click();
  await page.reload();
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
  expect((await state(page)).document).toEqual(initial);
  await page.goto("/?mode=modeling");
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
  await expect.poll(async () => (await state(page)).document).toEqual(draft);
  // Explicit Save on a share link can replace the draft using its current etag.
  await page.goto(shared);
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
  await page.getByRole("button", { name: "Save model", exact: true }).click();
  await expect(page.locator(".modeling-message")).toContainText("Saved");
  await open(page);
  await expect.poll(async () => (await state(page)).document).toEqual(initial);
  expect(errors).toEqual([]);
});

test("unknown model links report an error without opening another model", async ({
  page,
}) => {
  await page.goto("/?mode=modeling&model=missing");
  await expect(page.locator("footer [role=status]")).toContainText(
    "Unknown modeling model",
  );
  expect(await page.evaluate(() => kagura.modeling.active())).toBe(false);
  await expect(
    page.getByLabel("3D scene viewport", { exact: true }),
  ).toBeVisible();
});

test("physical Blender keys preview, constrain, cancel, undo and save without touching the scene", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await open(page);
  const scene = await page.evaluate(() => kagura.snapshot());
  const before = await state(page);
  const canvas = page.getByLabel("Modeling viewport", { exact: true });
  await page
    .getByRole("button", { name: "Select model beak", exact: true })
    .click();
  // Dvorak produces "i" at physical G; use code, never the produced character.
  await canvas.dispatchEvent("keydown", {
    key: "i",
    code: "KeyG",
    bubbles: true,
  });
  await page.keyboard.press("KeyX");
  await page.keyboard.press("Digit1");
  await page.keyboard.press("Enter");
  expect(
    (await state(page)).document.nodes.find((n) => n.id === "beak").position[0],
  ).toBe(1);
  await page.keyboard.press("KeyG");
  await page.keyboard.press("KeyY");
  await page.keyboard.press("Digit2");
  await page.keyboard.press("Escape");
  expect(
    (await state(page)).document.nodes.find((n) => n.id === "beak").position[1],
  ).toBe(before.document.nodes.find((n) => n.id === "beak").position[1]);
  await page.getByRole("button", { name: "Undo model", exact: true }).click();
  expect((await state(page)).document).toEqual(before.document);
  await page.getByRole("button", { name: "Redo model", exact: true }).click();
  await page.getByRole("button", { name: "Save model", exact: true }).click();
  await expect(page.locator(".modeling-message")).toContainText("Saved");
  const saved = (await state(page)).document;
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(scene);
  await page.reload();
  await page
    .getByRole("button", { name: "Open 3D modeling", exact: true })
    .click();
  await expect.poll(async () => (await state(page)).document).toEqual(saved);
  await page
    .getByRole("button", { name: "Close modeling", exact: true })
    .click();
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toHaveCount(0);
  await expect(
    page.getByLabel("3D scene viewport", { exact: true }),
  ).toBeVisible();
  expect(await page.evaluate(() => kagura.workspace.active("hierarchy"))).toBe(
    "default",
  );
  expect(errors).toEqual([]);
});

test("mesh picking, face extrusion, JSON roundtrip and GLB export preserve editable geometry", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await open(page);
  await page
    .getByRole("button", { name: "Add model cube", exact: true })
    .click();
  const cube = (await state(page)).document.nodes.at(-1);
  // Isolate the new mesh via the same validated document import API used by files.
  await page.evaluate((cube) => {
    const doc = kagura.modeling.snapshot().document;
    kagura.modeling.request({
      op: "replace",
      document: { ...doc, nodes: [cube], expressions: [] },
    });
  }, cube);
  await page
    .getByRole("button", { name: "Model front view", exact: true })
    .click();
  const canvas = page.getByLabel("Modeling viewport", { exact: true });
  await canvas.focus();
  await page.keyboard.press("KeyF");
  await page.keyboard.press("Tab");
  const rect = await canvas.boundingBox();
  // Pick the visible top-left cube corner in the framed orthographic view.
  await page.mouse.click(
    rect.x + rect.width / 2 - rect.height * 0.22,
    rect.y + rect.height / 2 - rect.height * 0.22,
  );
  expect((await state(page)).vertices).toEqual([3]);
  await page.keyboard.press("KeyG");
  await page.keyboard.press("KeyY");
  await page.keyboard.press("Digit1");
  await page.keyboard.press("Enter");
  expect((await state(page)).document.nodes[0].vertices[3][1]).toBe(1.5);
  await page.getByRole("button", { name: "Undo model", exact: true }).click();
  await canvas.focus();
  await page.keyboard.press("Digit3");
  await page.mouse.click(rect.x + rect.width / 2, rect.y + rect.height / 2);
  expect((await state(page)).face).toBe(0);
  await page.keyboard.press("KeyE");
  await page.keyboard.press("Digit1");
  await page.keyboard.press("Enter");
  const doc = (await state(page)).document;
  expect(doc.nodes[0].vertices).toHaveLength(12);
  expect(doc.nodes[0].faces).toHaveLength(10);
  const downloading = page.waitForEvent("download");
  await page
    .getByRole("button", { name: "Export model GLB", exact: true })
    .click();
  const download = await downloading;
  const bytes = await readFile(await download.path());
  expect(bytes.toString("ascii", 0, 4)).toBe("glTF");
  const json = JSON.parse(
    bytes.toString("utf8", 20, 20 + bytes.readUInt32LE(12)).trim(),
  );
  expect(json.nodes.map((n) => n.name)).toContain(cube.id);
  expect(
    json.nodes.some((n) => /grid|camera|selection/i.test(n.name ?? "")),
  ).toBe(false);
  const primitive = json.meshes[0].primitives[0];
  // Export splits triangle corners to preserve flat shading in glTF viewers.
  expect(json.accessors[primitive.attributes.POSITION].count).toBe(60);
  expect(json.accessors[primitive.attributes.NORMAL].count).toBe(60);
  const jsonDownload = page.waitForEvent("download");
  await page
    .getByRole("button", { name: "Export model JSON", exact: true })
    .click();
  const serialized = await readFile(await (await jsonDownload).path());
  expect(JSON.parse(serialized)).toEqual(doc);
  await page.getByLabel("Import model JSON", { exact: true }).setInputFiles({
    name: "model.kgrmodel",
    mimeType: "application/json",
    buffer: serialized,
  });
  expect((await state(page)).document).toEqual(doc);
  const original = await state(page);
  await page.getByLabel("Import model JSON", { exact: true }).setInputFiles({
    name: "broken.kgrmodel",
    mimeType: "application/json",
    buffer: Buffer.from('{"version":99}'),
  });
  expect((await state(page)).document).toEqual(original.document);
  expect(errors).toEqual([]);
});

test("facial presets blend without editing neutral and can be sculpted, saved and exported as morphs", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page.goto("/?mode=modeling&model=kawaiiko");
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
  const initial = await state(page);
  expect(initial.document.nodes.some((n) => n.id === "brow.left")).toBe(true);
  await page
    .getByRole("button", { name: "Frame expression face", exact: true })
    .click();
  await page
    .getByRole("button", { name: "Preview expression angry", exact: true })
    .click();
  expect((await state(page)).document).toEqual(initial.document);
  expect((await state(page)).previewNodes).not.toEqual(initial.document.nodes);
  const blink = page.getByLabel("Expression weight blink", { exact: true });
  await blink.fill("0.5");
  expect((await state(page)).weights).toEqual({ angry: 1, blink: 0.5 });
  await page.screenshot({ path: test.info().outputPath("kawaiiko-angry.png") });
  await page
    .getByRole("button", { name: "Neutral expression", exact: true })
    .click();
  expect((await state(page)).previewNodes).toEqual(initial.document.nodes);
  await page
    .getByLabel("Expression name", { exact: true })
    .fill("片眉を上げる");
  await page
    .getByRole("button", { name: "New expression", exact: true })
    .click();
  await page
    .getByRole("button", { name: "Select model brow.left", exact: true })
    .click();
  await page.keyboard.press("KeyG");
  await page.keyboard.press("KeyY");
  await page.keyboard.press("Digit0");
  await page.keyboard.press("Period");
  await page.keyboard.press("Digit1");
  await page.keyboard.press("Enter");
  await expect(
    page.getByRole("button", { name: "Save expression", exact: true }),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "Save expression", exact: true })
    .click();
  const saved = (await state(page)).document;
  expect(saved.nodes).toEqual(initial.document.nodes);
  expect(saved.expressions.at(-1).name).toBe("片眉を上げる");
  const download = page.waitForEvent("download");
  await page
    .getByRole("button", { name: "Export model GLB", exact: true })
    .click();
  const bytes = await readFile(await (await download).path());
  const gltf = JSON.parse(
    bytes.toString("utf8", 20, 20 + bytes.readUInt32LE(12)).trim(),
  );
  const brow = gltf.nodes.find((n) => n.name === "brow.left");
  const mesh = gltf.meshes[brow.mesh];
  expect(mesh.extras.targetNames).toContain("custom.1");
  expect(mesh.primitives[0].targets).toHaveLength(saved.expressions.length);
  expect(mesh.primitives[0].targets[0]).toHaveProperty("POSITION");
  expect(mesh.primitives[0].targets[0]).toHaveProperty("NORMAL");
  await page.getByRole("button", { name: "Save model", exact: true }).click();
  await expect(page.locator("footer [role=status]")).toContainText("Saved");
  await page.goto("/?mode=modeling");
  await expect(
    page.getByLabel("Modeling viewport", { exact: true }),
  ).toBeVisible();
  expect((await state(page)).document).toEqual(saved);
  expect((await state(page)).weights).toEqual({});
  await page
    .getByRole("button", { name: "Preview expression happy", exact: true })
    .click();
  await page.screenshot({ path: test.info().outputPath("kawaiiko-happy.png") });
  expect(errors).toEqual([]);
});

test("kawaiiko renders within a bounded viewport and reopening releases GPU objects", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await open(page);
  await page
    .getByRole("button", { name: "Select model body", exact: true })
    .click();
  await page.screenshot({
    path: test.info().outputPath("kawaiiko-studio.png"),
  });
  const initial = await page.evaluate(() => kagura.modeling.stats());
  expect(initial.triangles).toBeLessThan(10000);
  expect(initial.drawCalls).toBeLessThan(45);
  for (let i = 0; i < 3; i++) {
    await page
      .getByRole("button", { name: "Close modeling", exact: true })
      .click();
    await page
      .getByRole("button", { name: "Open 3D modeling", exact: true })
      .click();
    await expect(
      page.getByLabel("Modeling viewport", { exact: true }),
    ).toHaveCount(1);
    await expect
      .poll(() => page.evaluate(() => kagura.modeling.stats().geometries))
      .toBe(initial.geometries);
  }
  await page.setViewportSize({ width: 900, height: 720 });
  await expect
    .poll(() => page.evaluate(() => document.documentElement.scrollWidth))
    .toBe(900);
  await expect
    .poll(() => page.evaluate(() => document.documentElement.scrollHeight))
    .toBe(720);
  expect(errors).toEqual([]);
});
