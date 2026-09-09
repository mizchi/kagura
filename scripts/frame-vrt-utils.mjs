/**
 * Pure helpers for the browser-free visual regression gate.
 *
 * Split out from the runner so the decisions -- what counts as a blank frame,
 * what counts as a regression, where a baseline lives -- can be tested without
 * building a MoonBit example or shelling out to vlmkit.
 */

import { join } from "node:path";

/** Default share of the frame one color may occupy before it reads as blank. */
export const DEFAULT_MAX_TOP_SHARE = 0.995;

/** Default minimum number of dominant colors a real frame shows. */
export const DEFAULT_MIN_COLORS = 2;

/**
 * A manifest entry, filled in. `key` is the artifact stem: an example with no
 * state keeps its own name, so the common case reads as `ui_demo.png`.
 */
export function normalizeEntry(entry) {
  if (typeof entry?.example !== "string" || entry.example === "") {
    throw new Error("a frame-vrt entry needs an `example`");
  }
  const state = entry.state ?? null;
  const cursor = entry.cursor ?? null;
  if (cursor != null && (!Array.isArray(cursor) || cursor.length !== 2)) {
    throw new Error(`${entry.example}: \`cursor\` wants [x, y]`);
  }
  const frames = entry.frames ?? 1;
  if (!Number.isInteger(frames) || frames < 0) {
    throw new Error(`${entry.example}: \`frames\` wants a non-negative integer`);
  }
  return {
    example: entry.example,
    state,
    key: state == null ? entry.example : `${entry.example}.${state}`,
    frames,
    width: entry.width ?? null,
    height: entry.height ?? null,
    cursorX: cursor == null ? null : cursor[0],
    cursorY: cursor == null ? null : cursor[1],
    keys: entry.keys ?? [],
    allowUniform: entry.allowUniform ?? null,
  };
}

/** Reject duplicate keys up front: two entries writing one baseline is a bug. */
export function normalizeEntries(entries) {
  const normalized = entries.map(normalizeEntry);
  const seen = new Set();
  for (const entry of normalized) {
    if (seen.has(entry.key)) {
      throw new Error(`duplicate frame-vrt entry: ${entry.key}`);
    }
    seen.add(entry.key);
  }
  return normalized;
}

export function baselinePathFor(baselineDir, entry) {
  return join(baselineDir, `${entry.key}.png`);
}

/**
 * Read the dominant-color table out of `vlmkit check palette`.
 *
 * The share column is what matters: a frame whose top color covers all of it
 * is blank whatever that color happens to be.
 */
export function parsePaletteShares(stdout) {
  const shares = [];
  for (const line of stdout.split(/\r?\n/)) {
    const match = /^\|\s*`(#[0-9a-fA-F]{3,8})`\s*\|\s*([0-9.]+)%\s*\|/.exec(line.trim());
    if (match != null) {
      shares.push({ hex: match[1].toLowerCase(), share: Number(match[2]) / 100 });
    }
  }
  return shares;
}

/**
 * Is this frame worth pinning?
 *
 * The repository's own history is the argument for this check: 18 of 19
 * committed baselines were pure black, so the visual gate passed forever while
 * verifying nothing. A baseline that cannot fail is worse than none, because it
 * reads as coverage.
 */
export function blankFrameVerdict(
  shares,
  { minColors = DEFAULT_MIN_COLORS, maxTopShare = DEFAULT_MAX_TOP_SHARE, allowUniform = null } = {},
) {
  if (shares.length === 0) {
    return { ok: false, reason: "vlmkit reported no colors for this frame" };
  }
  const top = shares[0];
  const uniform = shares.length < minColors || top.share >= maxTopShare;
  if (!uniform) {
    return { ok: true, reason: null };
  }
  if (allowUniform != null) {
    return { ok: true, reason: `uniform, allowed: ${allowUniform}` };
  }
  return {
    ok: false,
    reason:
      `the frame is essentially one color (${top.hex} at ${(top.share * 100).toFixed(1)}%, ` +
      `${shares.length} dominant color(s)). A baseline that cannot fail is not coverage -- ` +
      "fix the render, or set `allowUniform` on the entry with a reason",
  };
}

/**
 * Compare a rendered frame against its baseline. `changedRatio` is vlmkit's.
 *
 * A null ratio means vlmkit printed no measurement, and that fails: an
 * unreadable report is an unrun comparison, not a clean one.
 */
export function regressionVerdict(diff, { threshold = 0 } = {}) {
  if (diff.changedRatio == null) {
    return { ok: false, detail: "vlmkit printed no diff measurement -- the comparison did not run" };
  }
  if (diff.changedRatio <= threshold) {
    return { ok: true, detail: null };
  }
  const parts = [`${(diff.changedRatio * 100).toFixed(2)}% of pixels changed`];
  if (diff.selectors.length > 0) parts.push(`at ${diff.selectors[0]}`);
  else if (diff.regions.length > 0) parts.push(`at ${diff.regions[0]}`);
  return { ok: false, detail: parts.join(" ") };
}

export function formatFrameVrtReport(results, { update = false } = {}) {
  const lines = [];
  let failed = 0;
  for (const result of results) {
    if (result.status === "failed") failed += 1;
    const label = {
      ok: "ok      ",
      updated: "updated ",
      failed: "FAILED  ",
      skipped: "skipped ",
    }[result.status];
    lines.push(`${label} ${result.key}${result.detail == null ? "" : `: ${result.detail}`}`);
  }
  const verb = update ? "updated" : "checked";
  lines.push("");
  lines.push(
    failed === 0
      ? `frame VRT: ${results.length} ${verb}, all clean`
      : `frame VRT: ${failed} of ${results.length} FAILED`,
  );
  return `${lines.join("\n")}\n`;
}

export function frameVrtUsage() {
  return [
    "Usage: node scripts/frame-vrt.mjs [options] [example ...]",
    "",
    "Renders each manifest entry through the CPU rasterizer -- no browser, no",
    "GPU, no Playwright -- and compares it against a committed baseline.",
    "The frames are pure arithmetic, so this can actually gate.",
    "",
    "Options:",
    "  --update           Write the baselines instead of comparing",
    "  --threshold <n>    Allowed changed-pixel ratio (default 0, i.e. exact)",
    "  --baseline-dir <d> Where the baselines live",
    "  --out-dir <d>      Where the freshly rendered frames go",
    "  --no-build         Use the existing _build output",
    "  -h, --help         Show this help",
    "",
    "A bare name filters to that example's entries.",
  ].join("\n");
}

export function parseFrameVrtArgs(argv) {
  const options = {
    update: false,
    threshold: 0,
    baselineDir: null,
    outDir: null,
    build: true,
    only: [],
    help: false,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = () => {
      const value = argv[++i];
      if (value === undefined) throw new Error(`${arg} needs a value`);
      return value;
    };
    switch (arg) {
      case "-h":
      case "--help":
        options.help = true;
        break;
      case "--update":
        options.update = true;
        break;
      case "--threshold": {
        const value = Number(next());
        if (!Number.isFinite(value) || value < 0 || value > 1) {
          throw new Error("--threshold wants a ratio between 0 and 1");
        }
        options.threshold = value;
        break;
      }
      case "--baseline-dir":
        options.baselineDir = next();
        break;
      case "--out-dir":
        options.outDir = next();
        break;
      case "--no-build":
        options.build = false;
        break;
      default:
        if (arg.startsWith("-")) throw new Error(`unknown option: ${arg}`);
        options.only.push(arg);
    }
  }
  return options;
}

/** Apply a bare-name filter, and refuse a name the manifest does not carry. */
export function selectEntries(entries, only) {
  if (only.length === 0) return entries;
  const selected = entries.filter((entry) => only.includes(entry.example));
  const missing = only.filter((name) => !entries.some((entry) => entry.example === name));
  if (missing.length > 0) {
    throw new Error(`not in the frame-vrt manifest: ${missing.join(", ")}`);
  }
  return selected;
}
