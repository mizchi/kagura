import { test, expect, type Page } from "@playwright/test";

async function trackFrames(page: Page) {
  await page.addInitScript(() => {
    const state = globalThis as any;
    const request = requestAnimationFrame.bind(window),
      cancel = cancelAnimationFrame.bind(window);
    state.__sessionFrames = new Set<number>();
    window.requestAnimationFrame = (callback) => {
      const id = request((time) => {
        state.__sessionFrames.delete(id);
        callback(time);
      });
      state.__sessionFrames.add(id);
      return id;
    };
    window.cancelAnimationFrame = (id) => {
      state.__sessionFrames.delete(id);
      cancel(id);
    };
  });
}

test("ready GPU publishes a scene and shutdown leaves no scheduled frame", async ({
  page,
}) => {
  await trackFrames(page);
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.goto("/");
  await page.waitForFunction(() => !!(globalThis as any).__kaguraUISnapshot);
  const ready = await page.evaluate(() => {
    const state = globalThis as any;
    return {
      ready: !!state.__kaguraWebRuntime?.webgpu?.device,
      error: state.__kaguraWebRuntime?.webgpu?.lastError,
      pending: state.__sessionFrames.size,
    };
  });
  expect(ready.ready).toBe(true);
  expect(ready.error).toBe("");
  expect(ready.pending).toBeGreaterThan(0);
  await page.evaluate(() => window.dispatchEvent(new Event("beforeunload")));
  await expect
    .poll(() => page.evaluate(() => (globalThis as any).__sessionFrames.size))
    .toBe(0);
  expect(errors).toEqual([]);
});

test("failed GPU reports startup failure without running or scheduling the game", async ({
  page,
}) => {
  await trackFrames(page);
  await page.addInitScript(() => {
    let runtime: any;
    Object.defineProperty(globalThis, "__kaguraWebRuntime", {
      configurable: true,
      get: () => runtime,
      set: (value) => {
        runtime = value;
        if (value?.webgpu)
          Object.defineProperty(value.webgpu, "lastError", {
            configurable: true,
            get: () => "injected GPU startup failure",
            set: () => {},
          });
      },
    });
  });
  const messages: string[] = [];
  page.on("console", (message) => messages.push(message.text()));
  await page.goto("/");
  await expect
    .poll(() =>
      messages.some((message) =>
        message.includes("injected GPU startup failure"),
      ),
    )
    .toBe(true);
  expect(
    await page.evaluate(() => !!(globalThis as any).__kaguraUISnapshot),
  ).toBe(false);
  await expect
    .poll(() => page.evaluate(() => (globalThis as any).__sessionFrames.size))
    .toBe(0);
});
