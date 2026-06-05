import { test, expect } from "@playwright/test";
import { readFileSync } from "node:fs";

// Per-example readback coverage baselines (see vrt-readback-baselines.json).
const READBACK_BASELINES = JSON.parse(
  readFileSync(new URL("./vrt-readback-baselines.json", import.meta.url), "utf8"),
) as { floorRatio: number; examples: Record<string, number> };

// VRT examples categorized by rendering pipeline.
// Categories help diagnose failures:
//   2d-scene:  @scene declarative API (sprite, text, shape)
//   2d-game:   full game loop (scene + input + audio)
//   3d-render: 3D pipeline (mesh, lighting, shadow)
//   3d-postfx: 3D + post-processing (bloom, tonemap, FXAA)
//   asset:     asset loading integration
interface VrtEntry {
  name: string;
  category: "2d-scene" | "2d-game" | "3d-render" | "3d-postfx" | "asset";
}

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

interface CanvasCaptureSummary {
  alphaZeroPixelRatio: number;
}

const VRT_EXAMPLES: VrtEntry[] = [
  { name: "scene_demo", category: "2d-scene" },
  { name: "ui_demo", category: "2d-scene" },
  { name: "flappy_bird", category: "2d-game" },
  { name: "survivor", category: "2d-game" },
  { name: "action_rpg", category: "2d-game" },
  { name: "fps_demo", category: "2d-game" },
  { name: "physics2d_demo", category: "2d-game" },
  { name: "arena3d", category: "3d-render" },
  { name: "collision3d_demo", category: "3d-render" },
  { name: "physics3d_demo", category: "3d-render" },
  { name: "skeletal_anim", category: "3d-render" },
  { name: "ragdoll_demo", category: "3d-render" },
  { name: "obj_viewer", category: "3d-render" },
  { name: "gltf_viewer", category: "3d-render" },
  { name: "shadow3d_demo", category: "3d-postfx" },
  { name: "postfx_demo", category: "3d-postfx" },
  { name: "hacknslash_3d", category: "3d-postfx" },
  { name: "fetch_image", category: "asset" },
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
      { timeout: 2_000 },
    );
    return await result.jsonValue() as VrtReadbackSummary;
  } catch (_) {
    return null;
  }
}

async function getCanvasCaptureSummary(page: import("@playwright/test").Page) {
  return await page.evaluate(() => {
    const canvas = document.querySelector("#app");
    if (!(canvas instanceof HTMLCanvasElement)) return null;
    const probe = document.createElement("canvas");
    probe.width = canvas.width;
    probe.height = canvas.height;
    const ctx = probe.getContext("2d", { willReadFrequently: true });
    if (ctx == null) return null;
    ctx.drawImage(canvas, 0, 0);
    const data = ctx.getImageData(0, 0, probe.width, probe.height).data;
    let alphaZero = 0;
    for (let i = 0; i < data.length; i += 4) {
      if (data[i + 3] === 0) alphaZero += 1;
    }
    const total = data.length / 4;
    return { alphaZeroPixelRatio: total > 0 ? alphaZero / total : 0 };
  }) as CanvasCaptureSummary | null;
}

async function expectCanvasFrame(
  page: import("@playwright/test").Page,
  canvas: ReturnType<import("@playwright/test").Page["locator"]>,
  snapshotName: string,
) {
  const readback = await getVrtReadbackSummary(page);
  const capture = await getCanvasCaptureSummary(page);
  if (readback != null && capture != null && capture.alphaZeroPixelRatio > 0.99) {
    // Headless WebGPU presents a transparent canvas (issue #4), so gate on the
    // GPU-texture readback instead of a screenshot. Stable invariants hold on
    // any backend; coverage is gated by a per-example floor that catches a
    // collapsed/blank/missing render without flaking on Metal-vs-SwiftShader
    // lighting differences.
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
  await expect(canvas).toHaveScreenshot(snapshotName, {
    maxDiffPixelRatio: 0.01,
  });
}

for (const { name, category } of VRT_EXAMPLES) {
  test(`VRT [${category}]: ${name} renders`, async ({ page }) => {
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
