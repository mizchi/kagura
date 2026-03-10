#!/usr/bin/env node

import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

import {
  compareInspectionToGltf,
  blenderToGltfLocation,
  blenderToGltfScale,
  extractExpectedNodesFromGltf,
  extractInspectionJson,
  parseGlbJson,
  resolveBlenderExecutable,
  summarizeComparison,
  summarizeInspection,
} from "./blender-roundtrip-utils.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));

function usage() {
  console.error(
    "Usage: node tools/modeling3d/scripts/blender-roundtrip-check.mjs <inspected.glb> [expected.glb]",
  );
}

const inputPath = process.argv[2];
const expectedPathArg = process.argv[3];
if (!inputPath) {
  usage();
  process.exit(1);
}

const glbPath = resolve(process.cwd(), inputPath);
const expectedGlbPath = resolve(process.cwd(), expectedPathArg ?? inputPath);
if (!existsSync(glbPath)) {
  console.error(`GLB not found: ${glbPath}`);
  process.exit(1);
}
if (!existsSync(expectedGlbPath)) {
  console.error(`Expected GLB not found: ${expectedGlbPath}`);
  process.exit(1);
}

const blenderExecutable = resolveBlenderExecutable({ existsSync });
if (blenderExecutable == null) {
  console.error("blender command is not available in PATH or /Applications");
  process.exit(2);
}
const blenderCheck = spawnSync(blenderExecutable, ["--version"], {
  encoding: "utf8",
});
if (blenderCheck.status !== 0) {
  console.error("blender executable could not be started");
  process.exit(2);
}

const inspectScript = resolve(__dirname, "blender_inspect_glb.py");
const result = spawnSync(
  blenderExecutable,
  [
    "--background",
    "--factory-startup",
    "--python",
    inspectScript,
    "--",
    glbPath,
  ],
  { encoding: "utf8" },
);

if (result.status !== 0) {
  process.stderr.write(result.stderr || result.stdout || "blender failed\n");
  process.exit(result.status ?? 1);
}

const inspection = extractInspectionJson(result.stdout);
for (const object of inspection.objects ?? []) {
  object.gltf_space_location = blenderToGltfLocation(object.location);
  object.gltf_space_scale = blenderToGltfScale(object.scale);
}
const expected = extractExpectedNodesFromGltf(parseGlbJson(readFileSync(expectedGlbPath)));
const comparison = compareInspectionToGltf(inspection, expected);
const summary = summarizeInspection(inspection);
console.log(summary.text);
console.log(`expected_source: ${expectedGlbPath}`);
console.log(summarizeComparison(comparison));
console.log(JSON.stringify({ inspection, expected, comparison, summary }));
