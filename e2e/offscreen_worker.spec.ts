import { expect, test } from "@playwright/test";

// Pins the browser-side facts behind the wasm async driver
// (lib/web/wasm-async-driver.mjs), which is otherwise only covered on Node's
// worker_threads.
//
// The design question this answers: a `moonbitlang/async` guest blocks the
// thread it runs on, so can a frame loop still drive it, and can it still
// draw? The answers are "yes, from another thread" and "yes, via
// OffscreenCanvas" -- but not for the reason one might assume. A worker *does*
// have `requestAnimationFrame`; it is simply never reached while the guest
// holds the thread. OffscreenCanvas supplies the drawing surface, not the
// clock.

test.describe("offscreen worker frame clock", () => {
  test("a blocked worker is driven by the main thread and renders", async ({ page }) => {
    const consoleErrors: string[] = [];
    page.on("pageerror", (error) => consoleErrors.push(String(error)));

    await page.goto("/e2e/fixtures/offscreen-worker-probe.html");

    // SharedArrayBuffer needs cross-origin isolation; serve-wasm-smoke.mjs sets
    // COOP/COEP for this fixture. Without it the probe cannot run at all.
    expect(await page.evaluate(() => globalThis.__crossOriginIsolated)).toBe(true);

    await page.waitForFunction(() => globalThis.__probe != null, null, { timeout: 20_000 });
    const probe = await page.evaluate(() => globalThis.__probe as any);
    expect(consoleErrors, consoleErrors.join("\n")).toHaveLength(0);
    expect(probe.type, JSON.stringify(probe)).toBe("done");

    console.log(`[offscreen-worker] ${JSON.stringify(probe)}`);

    expect(probe.caps.isOffscreen).toBe(true);

    // A dedicated worker does implement AnimationFrameProvider, and it fires
    // fine while the thread still yields -- during the awaited WebGPU setup.
    expect(probe.caps.hasWorkerRaf).toBe(true);
    // But not once during the blocking window, where a free loop would have
    // managed tens of frames. This is why the clock lives on the other thread.
    expect(probe.rafDuringBlock).toBe(0);
    expect(probe.blockedMs).toBeGreaterThan(300);

    // The main thread's rAF reached the parked worker through Atomics.
    expect(probe.mainFrames).toBeGreaterThan(0);
    expect(probe.draws2d).toBeGreaterThan(0);
    expect(probe.workerDraws).toBe(probe.draws2d);

    // And the draws landed in the bitmap the worker owns. Gating on the
    // worker's own readback rather than a screenshot, for the same reason the
    // VRT does: headless Linux canvas screenshots come back transparent.
    expect(probe.readback.nonTransparentRatio).toBeGreaterThan(0.99);
    expect(probe.readback.greenRatio).toBeGreaterThan(0.99);
  });

  test("WebGPU acquired before blocking still submits from the blocked worker", async ({ page }) => {
    await page.goto("/e2e/fixtures/offscreen-worker-probe.html");
    await page.waitForFunction(() => globalThis.__probe != null, null, { timeout: 20_000 });
    const probe = await page.evaluate(() => globalThis.__probe as any);

    test.skip(
      !probe.caps.hasWebGPU || probe.caps.gpuAdapter !== true,
      `no WebGPU adapter in this browser: ${JSON.stringify(probe.caps)}`,
    );

    // `requestAdapter`/`requestDevice` are Promise-based, so they have to
    // complete before the thread parks; everything a frame needs after that
    // (encoder, render pass, submit) is synchronous, which is what makes
    // rendering reachable from a blocked thread.
    expect(probe.gpuError, `WebGPU failed mid-loop: ${probe.gpuError}`).toBeNull();
    expect(probe.drawsGpu).toBeGreaterThan(0);
    expect(probe.drawsGpu).toBe(probe.draws2d);
  });
});
