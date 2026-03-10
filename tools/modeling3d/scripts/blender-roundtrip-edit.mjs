#!/usr/bin/env node

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

import { buildBlenderEditRecipe } from "./blender-edit-profiles.mjs";
import {
  copyKaguraRootExtras,
  extractExpectedNodesFromGltf,
  parseGlbJson,
  resolveBlenderExecutable,
} from "./blender-roundtrip-utils.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));

function usage() {
  console.error(
    "Usage: node tools/modeling3d/scripts/blender-roundtrip-edit.mjs <input.glb> <output.glb> [profile]",
  );
}

const inputPath = process.argv[2];
const outputPath = process.argv[3];
const profile = process.argv[4] ?? "pedestal_move_recolor";
if (!inputPath || !outputPath) {
  usage();
  process.exit(1);
}

const glbInputPath = resolve(process.cwd(), inputPath);
const glbOutputPath = resolve(process.cwd(), outputPath);
if (!existsSync(glbInputPath)) {
  console.error(`GLB not found: ${glbInputPath}`);
  process.exit(1);
}

const blenderExecutable = resolveBlenderExecutable({ existsSync });
if (blenderExecutable == null) {
  console.error("blender command is not available in PATH or /Applications");
  process.exit(2);
}

const editScript = resolve(__dirname, "blender_edit_glb.py");
const expected = extractExpectedNodesFromGltf(parseGlbJson(readFileSync(glbInputPath)));
const recipe = buildBlenderEditRecipe(expected, profile);
const result = spawnSync(
  blenderExecutable,
  [
    "--background",
    "--factory-startup",
    "--python",
    editScript,
    "--",
    glbInputPath,
    glbOutputPath,
    profile,
  ],
  {
    encoding: "utf8",
    env: {
      ...process.env,
      KAGURA_EDIT_RECIPE: JSON.stringify(recipe),
    },
  },
);

if (result.status !== 0) {
  process.stderr.write(result.stderr || result.stdout || "blender edit failed\n");
  process.exit(result.status ?? 1);
}
if (!existsSync(glbOutputPath)) {
  process.stderr.write(result.stdout || "");
  process.stderr.write(result.stderr || "");
  console.error(`edited GLB was not created: ${glbOutputPath}`);
  process.exit(1);
}

const patched = copyKaguraRootExtras(
  readFileSync(glbInputPath),
  readFileSync(glbOutputPath),
);
writeFileSync(glbOutputPath, patched);

process.stdout.write(result.stdout);
process.stdout.write(`patched_kagura_extras: ${glbOutputPath}\n`);
