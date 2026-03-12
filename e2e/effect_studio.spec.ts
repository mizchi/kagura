import { expect, test } from "@playwright/test";

type EffectStudioContext = {
  json: string;
  summary: string;
  parsed: {
    name: string;
    tracks: Array<{ id: string }>;
    patch_bundle: {
      target_file: string;
      track_targets: Array<{ track_id: string }>;
    };
    exports: {
      bundle_filename: string;
      review_filename: string;
    };
  } | null;
};

type EffectStudioExports = {
  downloadBundle: () => void;
  downloadReview: () => void;
};

type EffectStudioDownload = {
  filename: string;
  text: string;
};

async function waitForEffectStudioContext(page: import("@playwright/test").Page) {
  await page.goto("/vrt/effect_studio");
  await page.waitForFunction(
    () => Boolean((window as { __kaguraEffectStudioContext?: EffectStudioContext }).__kaguraEffectStudioContext?.parsed),
    null,
    { timeout: 15_000 },
  );
  return await page.evaluate(() => {
    return (window as { __kaguraEffectStudioContext?: EffectStudioContext }).__kaguraEffectStudioContext!;
  });
}

async function waitForEffectStudioExports(page: import("@playwright/test").Page) {
  await page.waitForFunction(
    () => {
      const exports = (window as { __kaguraEffectStudioExports?: EffectStudioExports }).__kaguraEffectStudioExports;
      return exports != null && typeof exports.downloadBundle === "function" && typeof exports.downloadReview === "function";
    },
    null,
    { timeout: 15_000 },
  );
}

test("effect_studio publishes AI patch bundle context", async ({ page }) => {
  const context = await waitForEffectStudioContext(page);

  expect(context.parsed).not.toBeNull();
  expect(context.parsed?.name).toBe("forge_burst");
  expect(context.parsed?.tracks.length).toBeGreaterThan(0);
  expect(context.parsed?.patch_bundle.target_file).toBe("tools/effect-studio/src/effect_doc.mbt");
  expect(context.parsed?.patch_bundle.track_targets[0]?.track_id).toBe("core_flash");
  expect(context.parsed?.exports.bundle_filename).toBe("forge_burst-effect-bundle.json");
  expect(context.parsed?.exports.review_filename).toBe("forge_burst-effect-review.md");
});

test("effect_studio downloads bundle JSON and review markdown", async ({ page }) => {
  await waitForEffectStudioContext(page);
  await waitForEffectStudioExports(page);

  await page.evaluate(() => {
    (window as { __kaguraEffectStudioExports: EffectStudioExports }).__kaguraEffectStudioExports.downloadBundle();
  });
  await page.waitForFunction(
    () => (window as { __kaguraEffectStudioDownload?: EffectStudioDownload }).__kaguraEffectStudioDownload?.filename === "forge_burst-effect-bundle.json",
    null,
    { timeout: 5_000 },
  );
  const bundle = await page.evaluate(() => {
    return (window as { __kaguraEffectStudioDownload?: EffectStudioDownload }).__kaguraEffectStudioDownload!;
  });
  expect(bundle.filename).toBe("forge_burst-effect-bundle.json");
  const bundleText = bundle.text;
  expect(bundleText).toContain("\"target_file\":\"tools/effect-studio/src/effect_doc.mbt\"");
  expect(bundleText).toContain("\"track_targets\":[");

  await page.evaluate(() => {
    (window as { __kaguraEffectStudioExports: EffectStudioExports }).__kaguraEffectStudioExports.downloadReview();
  });
  await page.waitForFunction(
    () => (window as { __kaguraEffectStudioDownload?: EffectStudioDownload }).__kaguraEffectStudioDownload?.filename === "forge_burst-effect-review.md",
    null,
    { timeout: 5_000 },
  );
  const review = await page.evaluate(() => {
    return (window as { __kaguraEffectStudioDownload?: EffectStudioDownload }).__kaguraEffectStudioDownload!;
  });
  expect(review.filename).toBe("forge_burst-effect-review.md");
  const reviewText = review.text;
  expect(reviewText).toContain("# Effect Studio AI Review");
  expect(reviewText).toContain("core_flash");
});
