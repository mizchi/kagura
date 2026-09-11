#!/usr/bin/env node

/**
 * Browser-free visual regression gate.
 *
 *   just frame-vrt              # compare every manifest entry to its baseline
 *   just frame-vrt-update       # re-pin the baselines after an intended change
 *   node scripts/frame-vrt.mjs ui_demo --no-build
 *
 * The frames come from the engine's headless path through the CPU rasterizer,
 * so they are pure arithmetic: no GPU, no driver, no compositor, byte-identical
 * run to run and process to process (verified before the first baselines were
 * pinned). That is the difference between this and `e2e/vrt.spec.ts`, which CI
 * can only run with `--update-snapshots` because the Linux canvas capture is
 * transparent and the Dawn readback never completes.
 *
 * The comparison is `vlmkit diff png`, and for an example that publishes a UI
 * snapshot it is handed the elements payload, so a failure names the UI node
 * that moved rather than a bare rectangle.
 */

import { execFileSync } from "node:child_process";
import { copyFileSync, existsSync, mkdirSync, readdirSync, rmSync } from "node:fs";
import { dirname, join, relative } from "node:path";

import { FRAME_VRT_ENTRIES } from "./frame-vrt-manifest.mjs";
import {
  baselinePathFor,
  blankFrameVerdict,
  formatFrameVrtReport,
  frameVrtUsage,
  normalizeEntries,
  parseFrameVrtArgs,
  parsePaletteShares,
  regressionVerdict,
  selectEntries,
} from "./frame-vrt-utils.mjs";
import { prepareBundle, renderExampleState } from "./render-frame.mjs";
import { parseVlmkitDiff } from "./vlm-ui-review-utils.mjs";

const REPO_ROOT = dirname(import.meta.dirname);
const DEFAULT_BASELINE_DIR = join(REPO_ROOT, "e2e", "frame-vrt-snapshots");
const DEFAULT_OUT_DIR = join(REPO_ROOT, "output", "frame-vrt");

/**
 * Per-pixel sensitivity handed to `vlmkit diff png`.
 *
 * Not the same knob as this script's `--threshold`, which is the share of the
 * frame allowed to change. This is pixelmatch's perceptual YIQ distance, and
 * vlmkit defaults it to 0.1 -- a sane default for browser screenshots, where
 * antialiasing and subpixel text jitter between runs and must be forgiven.
 *
 * It is the wrong default here, and dangerously so. Measured on this
 * repository: recoloring every button in `ui_demo` from #4a4a6a to #4a6a4a
 * changes 19.92% of the frame, and at 0.1 vlmkit reports **0.00%, no changes**.
 * A gate built on that default would pass a screen full of green buttons.
 *
 * The CPU rasterizer has no jitter to forgive -- the same commands produce the
 * same bytes, verified across processes -- so every differing pixel counts.
 */
const PIXEL_SENSITIVITY = "0";

function runVlmkit(args) {
  try {
    return execFileSync("pnpm", ["exec", "vlmkit", ...args], {
      cwd: REPO_ROOT,
      encoding: "utf8",
    });
  } catch (error) {
    // vlmkit exits non-zero when a diff crosses its own threshold; the report
    // is still on stdout, and a difference is exactly what is being measured.
    if (typeof error.stdout === "string" && error.stdout !== "") return error.stdout;
    throw error;
  }
}

async function main(argv) {
  const options = parseFrameVrtArgs(argv);
  if (options.help) {
    process.stdout.write(`${frameVrtUsage()}\n`);
    return 0;
  }
  const baselineDir = options.baselineDir ?? DEFAULT_BASELINE_DIR;
  const outDir = options.outDir ?? DEFAULT_OUT_DIR;
  const entries = selectEntries(normalizeEntries(FRAME_VRT_ENTRIES), options.only);
  if (entries.length === 0) {
    process.stderr.write("nothing to do: the manifest is empty\n");
    return 1;
  }

  const { renderHeadlessFrame } = await import("../assets/web/kagura-headless-frame.js");
  mkdirSync(outDir, { recursive: true });
  if (options.update) mkdirSync(baselineDir, { recursive: true });

  // One build per example, however many states it contributes.
  const bundles = new Map();
  const results = [];

  for (const entry of entries) {
    if (!bundles.has(entry.example)) {
      bundles.set(entry.example, prepareBundle(entry.example, { build: options.build }).bundlePath);
    }
    const { frame, meta, written } = await renderExampleState({
      exampleName: entry.example,
      bundlePath: bundles.get(entry.example),
      outDir,
      state: { ...entry, name: entry.state ?? "default" },
      renderHeadlessFrame,
    });

    // A frame missing part of its scene must never become a baseline: it would
    // pin the absence and pass forever.
    if (meta.skipped_commands > 0) {
      results.push({
        key: entry.key,
        status: "failed",
        detail:
          `${meta.skipped_commands} draw command(s) skipped -- the CPU rasterizer draws 2D ` +
          "geometry only, so this example does not belong in the manifest",
      });
      continue;
    }

    const shares = parsePaletteShares(runVlmkit(["check", "palette", written.png]));
    const blank = blankFrameVerdict(shares, { allowUniform: entry.allowUniform });
    if (!blank.ok) {
      results.push({ key: entry.key, status: "failed", detail: blank.reason });
      continue;
    }

    const baseline = baselinePathFor(baselineDir, entry);
    if (options.update) {
      copyFileSync(written.png, baseline);
      results.push({
        key: entry.key,
        status: "updated",
        detail: `${meta.width}x${meta.height}, ${meta.drawn_triangles} triangles ` +
          `in ${meta.draw_commands} command(s)` +
          (blank.reason == null ? "" : ` (${blank.reason})`),
      });
      continue;
    }

    if (!existsSync(baseline)) {
      results.push({
        key: entry.key,
        status: "failed",
        detail: `no baseline at ${relative(REPO_ROOT, baseline)} -- run \`just frame-vrt-update\``,
      });
      continue;
    }
    const diffArgs = ["diff", "png", baseline, written.png, "--threshold", PIXEL_SENSITIVITY];
    if (written.elements != null) diffArgs.push("--elements-json", written.elements);
    const diff = parseVlmkitDiff(runVlmkit(diffArgs));
    const verdict = regressionVerdict(diff, { threshold: options.threshold });
    results.push({
      key: entry.key,
      status: verdict.ok ? "ok" : "failed",
      detail: verdict.ok ? null : verdict.detail,
    });
  }

  if (options.update) pruneOrphanBaselines(baselineDir, entries, options.only);

  process.stdout.write(formatFrameVrtReport(results, { update: options.update }));
  const failed = results.some((result) => result.status === "failed");
  if (failed && !options.update) {
    process.stdout.write(
      "\nA failure here means the rendered frame changed. Look at the frames in " +
        `${relative(REPO_ROOT, outDir)} next to the baselines; if the change is intended, ` +
        "re-pin with `just frame-vrt-update`.\n",
    );
  }
  return failed ? 1 : 0;
}

/**
 * Drop baselines no entry claims any more, so a renamed or removed example
 * cannot leave a stale PNG behind pretending to be covered. Skipped when the
 * run was filtered, since then the other baselines are legitimately untouched.
 */
function pruneOrphanBaselines(baselineDir, entries, only) {
  if (only.length > 0 || !existsSync(baselineDir)) return;
  const wanted = new Set(entries.map((entry) => `${entry.key}.png`));
  for (const name of readdirSync(baselineDir)) {
    if (name.endsWith(".png") && !wanted.has(name)) {
      rmSync(join(baselineDir, name));
      process.stdout.write(`removed  ${name} (no manifest entry)\n`);
    }
  }
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  main(process.argv.slice(2)).then(
    (code) => {
      process.exitCode = code;
    },
    (error) => {
      process.stderr.write(`${error.message}\n`);
      process.exitCode = 1;
    },
  );
}
