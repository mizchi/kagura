import { expect, test } from "@playwright/test";

// Pins the browser-side facts behind the wasm async driver
// (lib/web/kagura-wasm-driver.js), which is otherwise only covered on Node's
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

    console.log(
      `[offscreen-worker] main ${probe.main.fps}fps p50=${probe.main.p50IntervalMs}ms p95=${probe.main.p95IntervalMs}ms | ` +
        `guest ${probe.worker.fps}fps p50=${probe.worker.p50IntervalMs}ms p95=${probe.worker.p95IntervalMs}ms | ` +
        `serviced ${((probe.draws2d / probe.mainFrames) * 100).toFixed(1)}%`,
    );

    // The guest keeps up with the clock. Relative, not an absolute fps: the
    // headless frame rate is whatever the machine gives us. The few frames it
    // misses are the ones that tick during the awaited WebGPU setup, before it
    // is parked and listening.
    expect(probe.draws2d / probe.mainFrames).toBeGreaterThan(0.85);
    // And no systematic stall: the wake latency should be noise next to a
    // frame, not a frame of its own.
    expect(probe.worker.p95IntervalMs).toBeLessThan(probe.main.p50IntervalMs * 2);

    // And the draws landed in the bitmap the worker owns. Gating on the
    // worker's own readback rather than a screenshot, for the same reason the
    // VRT does: headless Linux canvas screenshots come back transparent.
    expect(probe.readback.nonTransparentRatio).toBeGreaterThan(0.99);
    expect(probe.readback.greenRatio).toBeGreaterThan(0.99);
  });

  test("driving the guest does not cost the main thread frame rate", async ({ page }) => {
    // Same rAF loop with and without the worker, so the handshake's cost shows
    // up as a difference rather than an absolute number.
    const run = async (mode: string) => {
      await page.goto(`/e2e/fixtures/offscreen-worker-probe.html?mode=${mode}&durationMs=1200`);
      await page.waitForFunction(() => globalThis.__probe != null, null, { timeout: 20_000 });
      return await page.evaluate(() => (globalThis.__probe as any).main);
    };

    const baseline = await run("baseline");
    const driving = await run("worker");
    console.log(
      `[offscreen-worker] main-thread fps baseline=${baseline.fps} driving=${driving.fps} ` +
        `(p95 ${baseline.p95IntervalMs}ms -> ${driving.p95IntervalMs}ms)`,
    );

    expect(baseline.fps).toBeGreaterThan(0);
    // Measured at 1.000 on headless Chromium (5x1500ms). The margin is for
    // slower machines, not for an expected regression.
    expect(driving.fps / baseline.fps).toBeGreaterThan(0.8);
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
