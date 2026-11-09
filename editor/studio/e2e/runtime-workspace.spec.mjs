import { test, expect } from "@playwright/test";

test("runtime layout focuses logical objects, live state and history; restores authoring on stop", async ({
  page,
}) => {
  await page.goto("/");
  await page
    .getByLabel("Examples", { exact: true })
    .selectOption("flappy_bird");
  await expect(page.getByRole("status")).toContainText("Opened project");
  const authored = await page.evaluate(() => kagura.snapshot());
  const controls = page.getByRole("group", {
    name: "Project controls",
    exact: true,
  });
  await controls.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
  );
  await expect(page.locator(".studio")).toHaveClass(/runtime-layout/);
  await expect(page.getByLabel("Hierarchy scene", { exact: true })).toHaveValue(
    "scenes/training.mbt",
  );
  await expect(
    page
      .locator(".runtime-bar")
      .getByRole("group", { name: "Project controls" }),
  ).toHaveCount(1);
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  await page
    .getByRole("button", { name: "Select Bird in game", exact: true })
    .click();
  await expect(page.getByLabel("Bird Y", { exact: true })).toBeEnabled();
  await expect(page.locator('[data-scene-id="world/body"]')).toBeHidden();
  await page.getByLabel("Bird Y", { exact: true }).fill("80");
  await page.getByRole("button", { name: "Apply Y", exact: true }).click();
  await expect(page.getByLabel("Runtime history")).toContainText("Bird");
  await page
    .getByRole("button", { name: "Undo runtime edit", exact: true })
    .click();
  await expect(page.getByLabel("Bird Y", { exact: true })).toHaveValue("120");
  await page.getByLabel("Bird Y", { exact: true }).fill("81");
  await page.getByRole("button", { name: "Apply Y", exact: true }).click();
  await page.locator(".runtime-status").click();
  await page.keyboard.press("Control+z");
  await expect(page.getByLabel("Bird Y", { exact: true })).toHaveValue("120");
  await controls.getByRole("button", { name: "Step", exact: true }).click();
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
  const metrics = await page.evaluate(() => {
    const r = (s) => document.querySelector(s).getBoundingClientRect();
    return {
      hierarchy: r(".hierarchy").height,
      inspector: r(".inspector").height,
      workspace: r(".workspace").height,
      tree: r(".runtime-hierarchy").height,
      treeBottom: r(".runtime-hierarchy").bottom,
      subjectBottom: r(".graph-subject").bottom,
      toolsInCenter:
        document.querySelector('[data-column="1"] .agent') !== null,
    };
  });
  expect(metrics.hierarchy).toBeGreaterThan(metrics.workspace * 0.95);
  expect(metrics.inspector).toBeGreaterThan(metrics.workspace * 0.95);
  expect(metrics.tree).toBeGreaterThan(metrics.workspace * 0.8);
  expect(metrics.subjectBottom).toBeLessThanOrEqual(metrics.treeBottom);
  expect(metrics.toolsInCenter).toBe(true);
  const scale = await page.locator(".game-frame").evaluate((f) => {
    const c = f.contentDocument.querySelector("canvas");
    return { logical: c.width, display: f.getBoundingClientRect().width };
  });
  expect(scale.logical).toBe(320);
  expect(scale.display).toBeGreaterThan(320);
  await controls.getByRole("button", { name: "Stop", exact: true }).click();
  await expect(page.locator(".studio")).not.toHaveClass(/runtime-layout/);
  await expect(page.locator('[data-column="2"] .agent')).toHaveCount(1);
});

test("a 3D game can pause, inspect declared fields and resume without full state replacement", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByLabel("Examples", { exact: true }).selectOption("arena3d");
  await expect(page.getByRole("status")).toContainText("Opened project");
  const controls = page.getByRole("group", {
    name: "Project controls",
    exact: true,
  });
  await controls.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
  );
  await expect(page.getByLabel("Runtime observation")).toContainText(
    "Runtime fields",
  );
  expect((await page.evaluate(() => kagura.runtime.observe())).source).toBe(
    "scene",
  );
  await expect(
    controls.getByRole("button", { name: "Pause", exact: true }),
  ).toBeEnabled();
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  await expect(page.getByLabel("Runtime observation")).toContainText("Paused");
  const paused = await page.evaluate(() => kagura.runtime.observe());
  await page.evaluate(
    () =>
      new Promise((resolve) => {
        let frames = 0;
        const tick = () =>
          ++frames === 12 ? resolve() : requestAnimationFrame(tick);
        requestAnimationFrame(tick);
      }),
  );
  expect(await page.evaluate(() => kagura.runtime.observe())).toEqual(paused);
  await page.getByRole("button", { name: "Player", exact: true }).click();
  await expect(
    page.getByLabel("Player Position X", { exact: true }),
  ).toHaveValue(String(paused.state.player[0]));
  await expect(
    page.getByLabel("Player Position X", { exact: true }),
  ).toBeEnabled();
  await expect(
    page.getByLabel("Player Velocity Y", { exact: true }),
  ).toHaveValue(String(paused.state.playerVelocity[1]));
  expect(
    await page.evaluate(
      () =>
        kagura.graph().subjects.find((s) => s.id === "player").visuals.length,
    ),
  ).toBeGreaterThan(0);
  const body = paused.inspection.subjects.find((s) => s.id.startsWith("prop:"));
  await page.getByRole("button", { name: body.name, exact: true }).click();
  await expect(
    page.getByLabel(body.name + " Position X", { exact: true }),
  ).toHaveValue(String(body.fields.find((f) => f.id === "position.x").value));
  await expect(
    page.getByRole("button", { name: "Apply Position X", exact: true }),
  ).toBeEnabled();
  await expect(
    page.getByLabel(body.name + " Sleeping", { exact: true }),
  ).toBeDisabled();
  await page.getByRole("button", { name: "Render nodes", exact: true }).click();
  await page.locator('[data-subject="player"] > summary').click();
  await expect
    .poll(() => page.evaluate(() => kagura.graph().selection?.id))
    .toBe("player");
  await page
    .locator(".game-frame")
    .evaluate((f) => f.contentWindow.kaguraSceneRuntime.transition("second"));
  await expect
    .poll(() => page.evaluate(() => kagura.graph().selection))
    .toBeNull();
  await expect(
    page.getByLabel(body.name + " Position X", { exact: true }),
  ).toHaveCount(0);
  await controls.getByRole("button", { name: "Resume", exact: true }).click();
  await expect
    .poll(() => page.evaluate(() => kagura.runtime.observe().state.frameCount))
    .toBeGreaterThan(paused.state.frameCount);
  await expect(
    controls.getByRole("button", { name: "Step", exact: true }),
  ).toBeDisabled();
  await expect(
    page.getByRole("button", { name: "Apply state", exact: true }),
  ).toHaveCount(0);
});

test("paused Player edits preserve the world, reject stale tokens and continue on resume", async ({
  page,
}) => {
  test.setTimeout(60000);
  await page.goto("/");
  await page.getByLabel("Examples", { exact: true }).selectOption("arena3d");
  await expect(page.getByRole("status")).toContainText("Opened project");
  const renamed = await page.evaluate(() => {
    const snapshot = kagura.snapshot();
    return kagura.dispatch({
      expectedRevision: snapshot.revision,
      commands: [
        {
          op: "node.rename",
          id: snapshot.document.nodes[0].id,
          name: "Authored player test",
        },
      ],
    });
  });
  expect(renamed.ok).toBe(true);
  const authored = await page.evaluate(() => kagura.snapshot());
  const controls = page.getByRole("group", {
    name: "Project controls",
    exact: true,
  });
  await controls.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
    { timeout: 30000 },
  );
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  await page.getByRole("button", { name: "Player", exact: true }).click();
  const before = await page.evaluate(() => kagura.runtime.observe());
  const token = await page.evaluate(() => kagura.runtime.fields.inspect());
  await page.getByLabel("Player Position Y", { exact: true }).fill("4");
  await page
    .getByRole("button", { name: "Apply Position Y", exact: true })
    .click();
  await expect(
    page.getByLabel("Player Position Y", { exact: true }),
  ).toHaveValue("4");
  const moved = await page.evaluate(() => kagura.runtime.observe());
  expect(moved.state.player[1]).toBe(4);
  expect(moved.state.playerVelocity).toEqual(before.state.playerVelocity);
  expect(moved.state.frameCount).toBe(before.state.frameCount);
  expect(
    moved.state.physics.filter((b) => b.id !== moved.state.playerBodyId),
  ).toEqual(
    before.state.physics.filter((b) => b.id !== before.state.playerBodyId),
  );
  expect(
    moved.inspection.subjects.every((s) =>
      s.fields.every((f) => f.access === "readonly"),
    ),
  ).toBe(true);
  const stale = await page.evaluate((old) => {
    try {
      kagura.runtime.fields.edit(
        { subject: "player", field: "position.x", value: 8 },
        old,
      );
    } catch (error) {
      return error.message;
    }
  }, token);
  expect(stale).toContain("revision conflict");
  const revision = (await page.evaluate(() => kagura.runtime.fields.inspect()))
    .revision;
  await page.getByLabel("Player Position Y", { exact: true }).fill("10001");
  await page
    .getByRole("button", { name: "Apply Position Y", exact: true })
    .click();
  await expect(page.getByRole("status")).toContainText("10000 m");
  expect(
    (await page.evaluate(() => kagura.runtime.fields.inspect())).revision,
  ).toBe(revision);
  expect(
    (await page.evaluate(() => kagura.runtime.observe())).state.player[1],
  ).toBe(4);
  await page.getByLabel("Player Velocity Y", { exact: true }).fill("6");
  await page
    .getByRole("button", { name: "Apply Velocity Y", exact: true })
    .click();
  await expect(
    page.getByLabel("Player Velocity Y", { exact: true }),
  ).toHaveValue("6");
  await expect(page.getByLabel("Runtime history")).toContainText(
    "Player / Position Y",
  );
  await page.locator(".runtime-status").click();
  for (const shortcut of [
    "Control+z",
    "Meta+z",
    "Control+Shift+z",
    "Meta+Shift+z",
  ]) {
    await page.keyboard.press(shortcut);
    expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
  }
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
  await page
    .getByRole("button", { name: "Capture observation", exact: true })
    .click();
  await expect(
    page.getByLabel("Player Position Y", { exact: true }),
  ).toBeDisabled();
  await page
    .getByRole("button", { name: "Live observation", exact: true })
    .click();
  await expect(
    page.getByLabel("Player Position Y", { exact: true }),
  ).toBeEnabled();
  const edited = await page.evaluate(() => kagura.runtime.fields.inspect());
  await controls.getByRole("button", { name: "Resume", exact: true }).click();
  await expect
    .poll(() => page.evaluate(() => kagura.runtime.observe().state.player[1]))
    .toBeGreaterThan(4);
  await controls.getByRole("button", { name: "Restart", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
    { timeout: 30000 },
  );
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  const oldSession = await page.evaluate((old) => {
    try {
      kagura.runtime.fields.edit(
        { subject: "player", field: "position.x", value: 8 },
        old,
      );
    } catch (error) {
      return error.message;
    }
  }, edited);
  expect(oldSession).toContain("session conflict");
  await page.setViewportSize({ width: 768, height: 650 });
  await page.getByRole("button", { name: "Player", exact: true }).click();
  expect(
    (await page.getByLabel("Player Position Y", { exact: true }).boundingBox())
      .width,
  ).toBeGreaterThanOrEqual(80);
  await expect(
    controls.getByRole("button", { name: "Step", exact: true }),
  ).toBeDisabled();
  await expect(
    controls.getByRole("button", { name: "Checkpoint", exact: true }),
  ).toBeDisabled();
  await controls.getByRole("button", { name: "Stop", exact: true }).click();
  await page.getByRole("status").click();
  await page.keyboard.press("Control+z");
  expect(
    (await page.evaluate(() => kagura.snapshot())).document.nodes[0].name,
  ).not.toBe("Authored player test");
});

test("paused crates and balls edit through declared fields without moving the player or authoring scene", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByLabel("Examples", { exact: true }).selectOption("arena3d");
  await expect(page.getByRole("status")).toContainText("Opened project");
  const authored = await page.evaluate(() => kagura.snapshot());
  const controls = page.getByRole("group", {
    name: "Project controls",
    exact: true,
  });
  await controls.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
    { timeout: 30000 },
  );
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  const inspection = await page.evaluate(() => kagura.runtime.fields.inspect());
  const crate = inspection.subjects.find((s) => s.name === "Body crate-0-0");
  const ball = inspection.subjects.find((s) => s.name === "Body ball-0");
  const crateId = Number(crate.id.slice(5));
  const ballId = Number(ball.id.slice(5));
  await page.getByRole("button", { name: crate.name, exact: true }).click();
  const y = page.getByLabel(crate.name + " Position Y", { exact: true });
  await expect(y).toBeEnabled();
  await expect(
    page.getByLabel(crate.name + " Sleeping", { exact: true }),
  ).toBeDisabled();
  const before = await page.evaluate(() => kagura.runtime.observe());
  await y.fill("3");
  await page
    .getByRole("button", { name: "Apply Position Y", exact: true })
    .click();
  await expect(y).toHaveValue("3");
  await page.getByLabel(crate.name + " Velocity Y", { exact: true }).fill("6");
  await page
    .getByRole("button", { name: "Apply Velocity Y", exact: true })
    .click();
  await page.getByRole("button", { name: ball.name, exact: true }).click();
  await page.getByLabel(ball.name + " Velocity X", { exact: true }).fill("2");
  await page
    .getByRole("button", { name: "Apply Velocity X", exact: true })
    .click();
  const edited = await page.evaluate(() => kagura.runtime.observe());
  expect(edited.state.player).toEqual(before.state.player);
  expect(edited.state.playerVelocity).toEqual(before.state.playerVelocity);
  expect(edited.state.frameCount).toBe(before.state.frameCount);
  expect(edited.state.physics.find((b) => b.id === crateId).position[1]).toBe(
    3,
  );
  expect(edited.state.physics.find((b) => b.id === crateId).velocity[1]).toBe(
    6,
  );
  expect(edited.state.physics.find((b) => b.id === ballId).velocity[0]).toBe(2);
  const motion = (state) =>
    state.physics
      .filter((b) => b.id !== crateId && b.id !== ballId)
      .map(({ id, position, velocity }) => ({ id, position, velocity }));
  expect(motion(edited.state)).toEqual(motion(before.state));
  expect(
    edited.inspection.subjects.every((s) =>
      s.fields.every((f) => f.access === "readonly"),
    ),
  ).toBe(true);
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
  await expect(page.getByLabel("Runtime history")).toContainText(
    crate.name + " / Position Y",
  );
  await expect(page.getByLabel("Runtime history")).toContainText(
    ball.name + " / Velocity X",
  );
  await page
    .getByRole("button", { name: "Capture observation", exact: true })
    .click();
  await expect(
    page.getByLabel(ball.name + " Velocity X", { exact: true }),
  ).toBeDisabled();
  await expect(
    page.getByLabel("Runtime observation", { exact: true }),
  ).toContainText("use Live observation for current state");
  await page
    .getByRole("button", { name: "Live observation", exact: true })
    .click();
  await expect(
    page.getByLabel(ball.name + " Velocity X", { exact: true }),
  ).toBeEnabled();
  await expect(
    page.getByLabel("Runtime observation", { exact: true }),
  ).toContainText("Edit declared fields");
  await controls.getByRole("button", { name: "Resume", exact: true }).click();
  await expect
    .poll(() =>
      page.evaluate(
        (id) =>
          kagura.runtime.observe().state.physics.find((b) => b.id === id)
            .position[1],
        crateId,
      ),
    )
    .toBeGreaterThan(3);
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  const token = await page.evaluate(() => kagura.runtime.fields.inspect());
  await page
    .locator(".game-frame")
    .evaluate((f) => f.contentWindow.kaguraSceneRuntime.transition("second"));
  const stale = await page.evaluate(
    ({ token, subject }) => {
      try {
        kagura.runtime.fields.edit(
          { subject, field: "position.y", value: 4 },
          token,
        );
      } catch (error) {
        return error.message;
      }
    },
    { token, subject: crate.id },
  );
  expect(stale).toContain("conflict");
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
});

test("capturing observations freezes selected fields while the game keeps running", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByLabel("Examples", { exact: true }).selectOption("arena3d");
  await expect(page.getByRole("status")).toContainText("Opened project");
  const controls = page.getByRole("group", {
    name: "Project controls",
    exact: true,
  });
  await controls.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
    { timeout: 30000 },
  );
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  await page.getByRole("button", { name: "Game", exact: true }).click();
  const frame = (await page.evaluate(() => kagura.runtime.observe())).state
    .frameCount;
  await page
    .getByRole("button", { name: "Capture observation", exact: true })
    .click();
  await controls.getByRole("button", { name: "Resume", exact: true }).click();
  await expect
    .poll(() => page.evaluate(() => kagura.runtime.observe().state.frameCount))
    .toBeGreaterThan(frame);
  await expect(page.getByLabel("Runtime observation")).toContainText(
    "Captured; game keeps running",
  );
  await expect(
    page.getByLabel("Game Frame count", { exact: true }),
  ).toHaveValue(String(frame));
  await page
    .getByRole("button", { name: "Live observation", exact: true })
    .click();
  await expect
    .poll(async () =>
      Number(
        await page.getByLabel("Game Frame count", { exact: true }).inputValue(),
      ),
    )
    .toBeGreaterThan(frame);
});

for (const [game, source] of [
  ["card_game", "scene"],
  ["survivor", "scene"],
  ["emberwing", "scene"],
  ["hacknslash_3d", "scene"],
  ["iron_yard", "scene"],
]) {
  test("published runtime observation: " + game, async ({ page }) => {
    test.setTimeout(60000);
    await page.goto("/");
    await page.getByLabel("Examples", { exact: true }).selectOption(game);
    await expect(page.getByRole("status")).toContainText("Opened project");
    const controls = page.getByRole("group", {
      name: "Project controls",
      exact: true,
    });
    await controls.getByRole("button", { name: "Play", exact: true }).click();
    await expect(page.locator(".game-frame")).toHaveAttribute(
      "data-ready",
      "true",
      { timeout: 30000 },
    );
    await expect
      .poll(() => page.evaluate(() => kagura.runtime.observe()?.source), {
        timeout: 30000,
      })
      .toBe(source);
    await expect(page.getByLabel("Runtime observation")).toContainText(
      "Runtime fields",
    );
    await expect(page.getByLabel("Runtime observation")).toBeVisible();
    await expect(
      controls.getByRole("button", { name: "Step", exact: true }),
    ).toBeDisabled();
    if (game === "iron_yard") {
      await expect(
        page.getByRole("heading", {
          name: "IRON YARD / Hierarchy",
          exact: true,
        }),
      ).toBeHidden();
      await controls
        .getByRole("button", { name: "Pause", exact: true })
        .click();
      await expect
        .poll(() => page.evaluate(() => kagura.runtime.observe()?.state.phase))
        .toBe("paused");
      await expect(
        controls.getByRole("button", { name: "Resume", exact: true }),
      ).toBeEnabled();
    }
    await controls.getByRole("button", { name: "Stop", exact: true }).click();
    expect(await page.evaluate(() => kagura.runtime.observe())).toBeNull();
    if (game === "iron_yard")
      await expect(
        page.getByRole("heading", {
          name: "IRON YARD / Hierarchy",
          exact: true,
        }),
      ).toBeVisible();
  });
}

test("compact runtime panels preserve drafts, and the page never scrolls", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/");
  await page
    .getByLabel("Examples", { exact: true })
    .selectOption("flappy_bird");
  await expect(page.getByRole("status")).toContainText("Opened project");
  const controls = page.getByRole("group", {
    name: "Project controls",
    exact: true,
  });
  await controls.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator(".game-frame")).toHaveAttribute(
    "data-ready",
    "true",
  );
  await controls.getByRole("button", { name: "Pause", exact: true }).click();
  const panels = page.getByRole("navigation", { name: "Runtime panels" });
  await panels.getByRole("button", { name: "Objects", exact: true }).click();
  await page.getByRole("button", { name: "Bird", exact: true }).click();
  await panels.getByRole("button", { name: "State", exact: true }).click();
  await page.getByLabel("Bird Y", { exact: true }).fill("95");
  await expect
    .poll(() => page.getByLabel("Bird Y", { exact: true }).inputValue(), {
      intervals: [500, 500],
    })
    .toBe("95");
  await page.getByRole("button", { name: "Apply Y", exact: true }).click();
  expect(
    (await page.evaluate(() => kagura.runtime.snapshot())).state.bird_y,
  ).toBe(95);
  expect(
    await page.evaluate(() => ({
      width: document.documentElement.scrollWidth,
      height: document.documentElement.scrollHeight,
    })),
  ).toEqual({ width: 390, height: 844 });
});
