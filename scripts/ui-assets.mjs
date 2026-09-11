#!/usr/bin/env node

/**
 * Run `vlmkit check asset` over a declared manifest.
 *
 * An empty `assets` list is a successful no-op: not every example ships
 * sprites, and a missing gate that fails closed would block those. A listed
 * file that cannot be checked is a defect.
 */

import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

import { EXAMPLE_ROOT, findExampleDir } from "./example-dirs.mjs";

function usage() {
  return [
    "Usage: node scripts/ui-assets.mjs <example> [options]",
    "",
    "Reads editor/assets.json from the example. Each entry is one",
    "`vlmkit check asset` invocation.",
    "",
    "Options:",
    "  --advisory    Print findings but exit 0",
    "  -h, --help    Show this help",
  ].join("\n");
}

function loadManifest(exampleDir) {
  const path = resolve(exampleDir, "editor/assets.json");
  if (!existsSync(path)) return { path, assets: [] };
  const manifest = JSON.parse(readFileSync(path, "utf8"));
  if (manifest.version !== 1 || !Array.isArray(manifest.assets)) {
    throw new Error("Expected version 1 assets manifest");
  }
  return { path, assets: manifest.assets };
}

function assetArgs(entry, exampleDir) {
  if (typeof entry?.file !== "string" || entry.file === "") throw new Error("asset entry needs a file");
  const args = [resolve(exampleDir, entry.file)];
  if (entry.slot) args.push("--slot", String(entry.slot));
  if (entry.expectTransparent) args.push("--expect-transparent");
  if (entry.againstBg) args.push("--against-bg", String(entry.againstBg));
  if (entry.pagePalette) args.push("--page-palette", resolve(exampleDir, entry.pagePalette));
  return args;
}

export function runAssetManifest(example, { advisory = false } = {}) {
  const exampleDir = findExampleDir(example, [EXAMPLE_ROOT.examples]);
  if (exampleDir == null) throw new Error(`unknown example: ${example}`);
  const { path, assets } = loadManifest(exampleDir);
  const results = [];
  for (const entry of assets) {
    const args = assetArgs(entry, exampleDir);
    try {
      execFileSync("pnpm", ["exec", "vlmkit", "check", "asset", ...args], {
        cwd: resolve(import.meta.dirname, ".."),
        encoding: "utf8",
      });
      results.push({ file: entry.file, ok: true });
    } catch (error) {
      results.push({ file: entry.file, ok: false, detail: error.stdout || error.message });
    }
  }
  return { example, manifest: path, results, ok: results.every((entry) => entry.ok), advisory };
}

function main(argv) {
  const options = { example: null, advisory: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "-h" || arg === "--help") {
      process.stdout.write(`${usage()}\n`);
      return 0;
    }
    if (arg === "--advisory") options.advisory = true;
    else if (arg.startsWith("--")) throw new Error(`unknown option: ${arg}`);
    else if (options.example === null) options.example = arg;
    else throw new Error(`unexpected extra argument: ${arg}`);
  }
  if (options.example === null) throw new Error(`missing <example>\n\n${usage()}`);
  const report = runAssetManifest(options.example, options);
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  if (options.advisory) return 0;
  return report.ok ? 0 : 1;
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  try {
    process.exitCode = main(process.argv.slice(2));
  } catch (error) {
    process.stderr.write(`ui-assets: ${error.message}\n`);
    process.exitCode = 2;
  }
}
