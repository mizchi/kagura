#!/usr/bin/env node

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

import { copyKaguraRootExtras } from "./blender-roundtrip-utils.mjs";

function usage() {
  console.error(
    "Usage: node tools/modeling3d/scripts/gltf-patch-kagura-extras.mjs <source.glb> <target.glb> [output.glb]",
  );
}

const sourceArg = process.argv[2];
const targetArg = process.argv[3];
const outputArg = process.argv[4] ?? targetArg;
if (!sourceArg || !targetArg) {
  usage();
  process.exit(1);
}

const sourcePath = resolve(process.cwd(), sourceArg);
const targetPath = resolve(process.cwd(), targetArg);
const outputPath = resolve(process.cwd(), outputArg);
if (!existsSync(sourcePath)) {
  console.error(`Source GLB not found: ${sourcePath}`);
  process.exit(1);
}
if (!existsSync(targetPath)) {
  console.error(`Target GLB not found: ${targetPath}`);
  process.exit(1);
}

const patched = copyKaguraRootExtras(
  readFileSync(sourcePath),
  readFileSync(targetPath),
);
writeFileSync(outputPath, patched);
console.log(`patched_kagura_extras: ${outputPath}`);
