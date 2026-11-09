import { test, expect } from "@playwright/test";

const cases = [
  {
    game: "survivor",
    name: "Player",
    hp: 5,
    extra: ["Projectile weapon", "Damage", 4],
    progress: "frameCount",
  },
  { game: "card_game", name: "Player", hp: 40, extra: ["Run", "Gold", 123] },
  {
    game: "hacknslash_3d",
    name: "Hunter",
    hp: 1,
    extra: ["Hunter", "Guard energy", 33.5],
    progress: "frameCount",
  },
  {
    game: "iron_yard",
    name: "Pilot",
    hp: 500,
    extra: ["Weapons", "Rifle cooldown", 0.5],
    progress: "elapsed",
  },
  {
    game: "emberwing",
    name: "Dragon",
    hp: 4,
    extra: ["Dragon", "Heat", 0.5],
    progress: "time",
  },
];

for (const config of cases) {
  test(`runtime tuning: ${config.game} freezes, validates edits, resumes and invalidates restarts`, async ({
    page,
  }) => {
    test.setTimeout(90000);
    const errors = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await page.goto("/");
    await page
      .getByLabel("Examples", { exact: true })
      .selectOption(config.game);
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
      { timeout: 40000 },
    );
    await expect(
      controls.getByRole("button", { name: "Pause", exact: true }),
    ).toBeEnabled();
    const frame = page.frameLocator(".game-frame");
    if (config.game === "survivor") {
      await frame.locator("canvas").focus();
      await page.keyboard.down("Enter");
      try {
        await expect
          .poll(() => page.evaluate(() => kagura.runtime.observe().state.mode))
          .toBe("playing");
      } finally {
        await page.keyboard.up("Enter");
      }
    } else if (config.game === "card_game") {
      // Hold confirmation until a polled-input frame consumes it, then let the
      // release reach the next scene before confirming again.
      for (const scene of ["character_select", "map"]) {
        const previous = await page.evaluate(
          () => kagura.runtime.observe().state.scene,
        );
        await frame.locator("canvas").focus();
        await page.keyboard.down("Enter");
        try {
          await expect
            .poll(() =>
              page.evaluate(() => kagura.runtime.observe().state.scene),
            )
            .not.toBe(previous);
        } finally {
          await page.keyboard.up("Enter");
        }
        await expect
          .poll(() => page.evaluate(() => kagura.runtime.observe().state.scene))
          .toBe(scene);
        const revision = await page.evaluate(
          () => kagura.runtime.fields.inspect().revision,
        );
        await expect
          .poll(() =>
            page.evaluate(() => kagura.runtime.fields.inspect().revision),
          )
          .toBeGreaterThan(revision + 1);
      }
    } else if (config.game === "emberwing") {
      await expect
        .poll(() =>
          page
            .locator(".game-frame")
            .evaluate((f) => !!f.contentWindow.emberwing),
        )
        .toBe(true);
      await page
        .locator(".game-frame")
        .evaluate((f) => f.contentWindow.emberwing.command("start"));
    }
    await controls.getByRole("button", { name: "Pause", exact: true }).click();
    const before = await page.evaluate(() => kagura.runtime.observe());
    await page.evaluate(
      () =>
        new Promise((resolve) => {
          let n = 0;
          const tick = () =>
            ++n === 8 ? resolve() : requestAnimationFrame(tick);
          requestAnimationFrame(tick);
        }),
    );
    expect(await page.evaluate(() => kagura.runtime.observe())).toEqual(before);
    expect(before.source).toBe("scene");
    expect(
      before.inspection.subjects.every((s) =>
        s.fields.every((f) => f.access === "readonly"),
      ),
    ).toBe(true);
    await page.getByRole("button", { name: config.name, exact: true }).click();
    const hp = page.getByLabel(config.name + " HP", { exact: true });
    await expect(hp).toBeEnabled();
    const token = await page.evaluate(() => kagura.runtime.fields.inspect());
    await hp.fill(String(config.hp));
    await page.getByRole("button", { name: "Apply HP", exact: true }).click();
    await expect(hp).toHaveValue(String(config.hp));
    expect((await page.evaluate(() => kagura.runtime.observe())).state.hp).toBe(
      config.hp,
    );
    if (config.game === "iron_yard") {
      await expect(frame.locator("#ap")).toHaveText(
        String(config.hp).padStart(4, "0"),
      );
      await expect(frame.locator("#menu")).not.toBeVisible();
    } else if (config.game === "emberwing") {
      await expect(frame.locator("#dialog")).toBeHidden();
      await expect(frame.locator("#health")).toHaveAttribute(
        "aria-label",
        `体力 ${config.hp} / 6`,
      );
    } else if (config.game === "hacknslash_3d") {
      await expect
        .poll(() =>
          page
            .locator(".game-frame")
            .evaluate((f) => f.contentWindow.__ashenHunt.paused),
        )
        .toBe(false);
      await expect
        .poll(() =>
          page
            .locator(".game-frame")
            .evaluate((f) => f.contentWindow.__ashenHunt.hp),
        )
        .toBe(config.hp);
    } else if (config.game === "card_game") {
      await expect
        .poll(() =>
          page
            .locator(".game-frame")
            .evaluate((f) =>
              JSON.stringify(
                f.contentWindow.__kaguraUISnapshot?.parsed,
              ).includes("HP 40/80"),
            ),
        )
        .toBe(true);
    }
    const stale = await page.evaluate((old) => {
      try {
        kagura.runtime.fields.edit(
          { subject: "player", field: "hp", value: 1 },
          old,
        );
      } catch (error) {
        return error.message;
      }
    }, token);
    expect(stale).toContain("revision conflict");
    const editedToken = await page.evaluate(() =>
      kagura.runtime.fields.inspect(),
    );
    const history = await page.evaluate(() => kagura.runtime.fields.history());
    await hp.fill("0");
    await page.getByRole("button", { name: "Apply HP", exact: true }).click();
    await expect(page.getByRole("status")).toContainText(
      "Expected finite value",
    );
    expect(await page.evaluate(() => kagura.runtime.fields.inspect())).toEqual(
      editedToken,
    );
    expect(await page.evaluate(() => kagura.runtime.fields.history())).toEqual(
      history,
    );
    await page
      .getByRole("button", { name: config.extra[0], exact: true })
      .click();
    const extra = page.getByLabel(config.extra[0] + " " + config.extra[1], {
      exact: true,
    });
    await extra.fill(String(config.extra[2]));
    await page
      .getByRole("button", { name: "Apply " + config.extra[1], exact: true })
      .click();
    await expect(extra).toHaveValue(String(config.extra[2]));
    await page
      .getByRole("button", { name: "Capture observation", exact: true })
      .click();
    await expect(extra).toBeDisabled();
    await page
      .getByRole("button", { name: "Live observation", exact: true })
      .click();
    await expect(extra).toBeEnabled();
    const paused = await page.evaluate(() => kagura.runtime.fields.inspect());
    await controls.getByRole("button", { name: "Resume", exact: true }).click();
    await expect
      .poll(() => page.evaluate(() => kagura.runtime.fields.inspect().revision))
      .toBeGreaterThan(paused.revision);
    if (config.progress) {
      await expect
        .poll(() =>
          page.evaluate(
            (key) => kagura.runtime.observe().state[key],
            config.progress,
          ),
        )
        .toBeGreaterThan(before.state[config.progress]);
    }
    expect(await page.evaluate(() => kagura.snapshot())).toEqual(authored);
    if (["iron_yard", "emberwing"].includes(config.game)) {
      await controls
        .getByRole("button", { name: "Pause", exact: true })
        .click();
      const old = await page.evaluate(() => kagura.runtime.fields.inspect());
      await page.locator(".game-frame").evaluate((f, game) => {
        if (game === "iron_yard") f.contentWindow.ironYard.reset();
        else f.contentWindow.emberwing.command("restart");
      }, config.game);
      const reset = await page.evaluate(() => kagura.runtime.fields.inspect());
      expect(reset.session).toBe(old.session);
      expect(reset.scope).not.toBe(old.scope);
      expect(reset.revision).toBeGreaterThan(old.revision);
      const conflict = await page.evaluate((token) => {
        try {
          kagura.runtime.fields.edit(
            { subject: "player", field: "hp", value: 1 },
            token,
          );
        } catch (error) {
          return error.message;
        }
      }, old);
      expect(conflict).toContain("conflict");
    }
    await controls
      .getByRole("button", { name: "Restart", exact: true })
      .click();
    await expect(page.locator(".game-frame")).toHaveAttribute(
      "data-ready",
      "true",
      { timeout: 40000 },
    );
    await controls.getByRole("button", { name: "Pause", exact: true }).click();
    const oldSession = await page.evaluate((old) => {
      try {
        kagura.runtime.fields.edit(
          { subject: "player", field: "hp", value: 1 },
          old,
        );
      } catch (error) {
        return error.message;
      }
    }, paused);
    expect(oldSession).toContain("session conflict");
    expect(errors).toEqual([]);
  });
}
