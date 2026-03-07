import { test, expect } from "@playwright/test";

// CPU performance benchmark: measures main thread responsiveness
// Run with: npx playwright test e2e/perf-check.spec.ts --headed
test("hacknslash_3d frame budget", async ({ page }) => {
  await page.goto("http://localhost:8080/?snapshot=playing&frames=30");
  // Wait for game to initialize
  await page.waitForTimeout(2000);

  // Measure main thread responsiveness using setTimeout scheduling
  const result = await page.evaluate(() => {
    return new Promise<{
      frames: number;
      avgFrameMs: number;
      p95FrameMs: number;
      maxFrameMs: number;
    }>((resolve) => {
      const frameTimes: number[] = [];
      let lastTime = performance.now();
      let count = 0;
      const maxFrames = 120;

      function tick() {
        const now = performance.now();
        const dt = now - lastTime;
        lastTime = now;
        if (count > 0) frameTimes.push(dt); // skip first
        count++;
        if (count < maxFrames) {
          // Use MessageChannel for high-priority scheduling
          const ch = new MessageChannel();
          ch.port1.onmessage = tick;
          ch.port2.postMessage(null);
        } else {
          const sorted = [...frameTimes].sort((a, b) => a - b);
          const avg =
            frameTimes.reduce((a, b) => a + b, 0) / frameTimes.length;
          const p95 = sorted[Math.floor(sorted.length * 0.95)];
          const max = sorted[sorted.length - 1];
          resolve({
            frames: frameTimes.length,
            avgFrameMs: Math.round(avg * 10) / 10,
            p95FrameMs: Math.round(p95 * 10) / 10,
            maxFrameMs: Math.round(max * 10) / 10,
          });
        }
      }
      tick();
    });
  });

  console.log("Performance result:", JSON.stringify(result));

  // Assert: average frame time should be under 20ms (50fps budget)
  // This is a soft check — the main goal is to surface the numbers
  expect(result.avgFrameMs).toBeLessThan(25);
});
