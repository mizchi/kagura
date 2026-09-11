import { test, expect } from "@playwright/test";
import { readFileSync } from "node:fs";

import { EXAMPLE_ROOT, findExampleCategory } from "../scripts/example-dirs.mjs";

// Per-example readback coverage baselines (see vrt-readback-baselines.json).
const READBACK_BASELINES = JSON.parse(
  readFileSync(new URL("./vrt-readback-baselines.json", import.meta.url), "utf8"),
) as { floorRatio: number; examples: Record<string, number> };

// The category in each test title is the example's directory under `examples/`
// -- `games` for a full game loop, `demos-2d` / `demos-3d` for a single feature.
// It comes from the tree rather than a list here so the two cannot disagree,
// and so moving an example is enough to reclassify its test.
const categoryOf = (name: string): string => {
  const category = findExampleCategory(name, [EXAMPLE_ROOT.examples]);
  if (category == null) {
    throw new Error(`VRT example ${name} is not under examples/<category>/`);
  }
  return category;
};

interface KaguraReadyProbe {
  ok: boolean;
  reason?: string;
  lastCompletedFrameMs?: number;
  lastRenderCpuMs?: number;
}

interface VrtReadbackSummary {
  maxChannel: number;
  nonDarkPixelRatio: number;
  nonTransparentPixelRatio: number;
}

const VRT_EXAMPLES: string[] = [
  "scene_demo",
  "ui_demo",
  "flappy_bird",
  "survivor",
  "action_rpg",
  "fps_demo",
  "physics2d_demo",
  "arena3d",
  "collision3d_demo",
  "physics3d_demo",
  "skeletal_anim",
  "ragdoll_demo",
  "shadow3d_demo",
  "postfx_demo",
  "hacknslash_3d",
  "fetch_image",
];

async function waitForKaguraReady(page: import("@playwright/test").Page) {
  const result = await page.waitForFunction(
    () => {
      const root = globalThis as {
        __kaguraGfx?: {
          lastCompletedFrameMs?: () => number;
          lastRenderCpuMs?: () => number;
        };
        __kaguraLastGpu?: unknown;
        __kaguraWebRuntime?: {
          webgpu?: {
            device?: unknown;
            lastError?: string;
          };
        };
      };
      const webgpu = root.__kaguraWebRuntime?.webgpu;
      const lastError = webgpu?.lastError ?? "";
      if (lastError !== "") {
        return { ok: false, reason: lastError };
      }
      const lastCompletedFrameMs = root.__kaguraGfx?.lastCompletedFrameMs?.() ?? 0;
      const lastRenderCpuMs = root.__kaguraGfx?.lastRenderCpuMs?.() ?? 0;
      const hasGpu = root.__kaguraLastGpu != null || webgpu?.device != null;
      if (hasGpu && (lastRenderCpuMs > 0 || lastCompletedFrameMs > 0)) {
        return { ok: true, lastCompletedFrameMs, lastRenderCpuMs };
      }
      return null;
    },
    undefined,
    { timeout: 15_000 },
  );
  const probe = await result.jsonValue() as KaguraReadyProbe;
  if (!probe.ok) {
    throw new Error(`Kagura WebGPU failed to initialize: ${probe.reason ?? "unknown error"}`);
  }
}

async function getVrtReadbackSummary(page: import("@playwright/test").Page) {
  try {
    const result = await page.waitForFunction(
      () => {
        const root = globalThis as {
          __kaguraGfx?: { lastReadbackSummary?: () => VrtReadbackSummary | null };
          __kaguraVrtLastReadback?: VrtReadbackSummary;
        };
        return root.__kaguraGfx?.lastReadbackSummary?.() ??
          root.__kaguraVrtLastReadback ??
          null;
      },
      undefined,
      // Generous: the first readback completes a copyTextureToBuffer + async
      // buffer map, which is slow under software WebGPU on CI runners.
      { timeout: 12_000 },
    );
    return await result.jsonValue() as VrtReadbackSummary;
  } catch (_) {
    // Diagnose why no summary arrived (enabled flag, helper presence, pending).
    const diag = await page.evaluate(() => {
      const root = globalThis as {
        __kaguraVrtReadbackEnabled?: unknown;
        __kaguraGfx?: { lastReadbackSummary?: () => unknown };
        __kaguraVrtLastReadback?: unknown;
      };
      return {
        enabled: root.__kaguraVrtReadbackEnabled === true,
        hasGfx: typeof root.__kaguraGfx?.lastReadbackSummary === "function",
        hasLast: root.__kaguraVrtLastReadback != null,
      };
    }).catch(() => null);
    // eslint-disable-next-line no-console
    console.log(`[vrt-readback] no summary: ${JSON.stringify(diag)}`);
    return null;
  }
}

async function expectCanvasFrame(
  page: import("@playwright/test").Page,
  canvas: ReturnType<import("@playwright/test").Page["locator"]>,
  snapshotName: string,
) {
  const readback = await getVrtReadbackSummary(page);
  if (readback != null) {
    // Gate on the GPU-texture readback whenever it is available. The headless
    // canvas capture surface is unreliable across backends (transparent on
    // macOS Metal — issue #4 — and platform-specific screenshot baselines do
    // not transfer between macOS and the Linux/SwiftShader CI runner), so the
    // readback is the portable signal. Stable invariants hold on any backend;
    // coverage is gated by a per-example floor that catches a collapsed/blank/
    // missing render while tolerating Metal-vs-SwiftShader lighting/AA diffs.
    const key = snapshotName.replace(/\.png$/, "");
    const expectedNonDark = READBACK_BASELINES.examples[key];
    // eslint-disable-next-line no-console
    console.log(
      `[vrt-readback] ${key}: nonDark=${readback.nonDarkPixelRatio.toFixed(4)} ` +
        `nonTransparent=${readback.nonTransparentPixelRatio.toFixed(4)} maxChannel=${readback.maxChannel} ` +
        `(baseline nonDark=${expectedNonDark ?? "n/a"})`,
    );
    expect(readback.nonTransparentPixelRatio).toBeGreaterThan(0.99);
    expect(readback.maxChannel).toBeGreaterThanOrEqual(64);
    if (typeof expectedNonDark === "number") {
      expect(readback.nonDarkPixelRatio).toBeGreaterThanOrEqual(
        expectedNonDark * READBACK_BASELINES.floorRatio,
      );
    } else {
      expect(readback.nonDarkPixelRatio).toBeGreaterThan(0.001);
    }
    return;
  }
  // Fallback only when readback is unavailable: compare the canvas screenshot
  // (works on surfaces where canvas presentation is reliable).
  await expect(canvas).toHaveScreenshot(snapshotName, {
    maxDiffPixelRatio: 0.01,
  });
}

for (const name of VRT_EXAMPLES) {
  test(`VRT [${categoryOf(name)}]: ${name} renders`, async ({ page }) => {
    await page.goto(`/vrt/${name}`);
    await waitForKaguraReady(page);
    await page.waitForTimeout(500);
    const canvas = page.locator("#app");
    await expectCanvasFrame(page, canvas, `${name}.png`);
  });
}

// Snapshot mode tests: render specific game states via URL params
// tick: number of rendered frames to wait before capture (ensures PostFX pipeline runs)
const SNAPSHOT_TESTS = [
  { name: "hacknslash_3d", params: "?snapshot=playing&frames=60&tick=5", tick: 5, suffix: "playing" },
];

for (const { name, params, tick, suffix } of SNAPSHOT_TESTS) {
  test(`VRT: ${name} ${suffix}`, async ({ page }) => {
    await page.goto(`/vrt/${name}${params}`);
    await waitForKaguraReady(page);
    if (tick > 0) {
      await page.waitForFunction(
        (target) =>
          ((globalThis as { __kaguraSnapshotTick?: number }).__kaguraSnapshotTick ?? 0) >= target,
        tick,
        { timeout: 10_000 },
      );
    } else {
      await page.waitForTimeout(500);
    }
    const canvas = page.locator("#app");
    await expectCanvasFrame(page, canvas, `${name}-${suffix}.png`);
  });
}
