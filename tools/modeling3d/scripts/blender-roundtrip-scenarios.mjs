#!/usr/bin/env node

import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { basename, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

import {
  compareInspectionToGltf,
  extractExpectedNodesFromGltf,
  extractInspectionJson,
  parseGlbJson,
  summarizeComparison,
} from "./blender-roundtrip-utils.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));

const SCENARIOS = [
  "pedestal_move_recolor",
  "guide_orb_delete",
  "blender_helper_add",
  "clay_head_stamp_count_increment",
  "pedestal_kind_mismatch",
  "roundtrip_diff_bundle",
];

function usage() {
  console.error(
    "Usage: node tools/modeling3d/scripts/blender-roundtrip-scenarios.mjs <source.glb> [output-dir]",
  );
}

const inputArg = process.argv[2];
const outputArg = process.argv[3] ?? "output/playwright/blender-roundtrip-scenarios";
if (!inputArg) {
  usage();
  process.exit(1);
}

const sourcePath = resolve(process.cwd(), inputArg);
const outputDir = resolve(process.cwd(), outputArg);
if (!existsSync(sourcePath)) {
  console.error(`GLB not found: ${sourcePath}`);
  process.exit(1);
}
mkdirSync(outputDir, { recursive: true });

const editScript = resolve(__dirname, "blender-roundtrip-edit.mjs");
const checkScript = resolve(__dirname, "blender-roundtrip-check.mjs");
const sourceName = basename(sourcePath, ".glb");
const expected = extractExpectedNodesFromGltf(parseGlbJson(readFileSync(sourcePath)));
const results = [];

for (const profile of SCENARIOS) {
  const editedPath = resolve(outputDir, `${sourceName}-${profile}.glb`);
  const editResult = spawnSync(
    process.execPath,
    [editScript, sourcePath, editedPath, profile],
    { encoding: "utf8" },
  );
  if (editResult.status !== 0) {
    process.stderr.write(editResult.stderr || editResult.stdout || `edit failed: ${profile}\n`);
    process.exit(editResult.status ?? 1);
  }
  const checkResult = spawnSync(
    process.execPath,
    [checkScript, editedPath, sourcePath],
    { encoding: "utf8" },
  );
  if (checkResult.status !== 0) {
    process.stderr.write(checkResult.stderr || checkResult.stdout || `check failed: ${profile}\n`);
    process.exit(checkResult.status ?? 1);
  }
  const payload = extractInspectionJson(checkResult.stdout);
  const comparison =
    payload?.comparison ?? compareInspectionToGltf(payload?.inspection, expected);
  const summary = summarizeComparison(comparison);
  results.push({
    profile,
    editedPath,
    comparison,
    summary,
  });
}

console.log(JSON.stringify({ sourcePath, outputDir, results }, null, 2));
