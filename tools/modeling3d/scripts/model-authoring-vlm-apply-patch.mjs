#!/usr/bin/env node

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

import { applyRoundtripPatchToModelDoc } from "./model-authoring-vlm-apply-patch-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-apply-patch.mjs \\",
      "  --target tools/modeling3d/examples/model_authoring/src/model_doc.mbt \\",
      "  --patch output/.../vlm_clay_totem_roundtrip_patch.mbt \\",
      "  [--write]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    write: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    switch (arg) {
      case "--target":
        options.target = argv[index + 1];
        index += 1;
        break;
      case "--patch":
        options.patch = argv[index + 1];
        index += 1;
        break;
      case "--write":
        options.write = true;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  if (!options.target || !options.patch) {
    throw new Error("--target and --patch are required");
  }
  return options;
}

function resolveRequiredFile(pathArg, label) {
  const path = resolve(process.cwd(), pathArg);
  if (!existsSync(path)) {
    throw new Error(`${label} not found: ${path}`);
  }
  return path;
}

try {
  const options = parseArgs(process.argv.slice(2));
  const targetPath = resolveRequiredFile(options.target, "Target file");
  const patchPath = resolveRequiredFile(options.patch, "Patch file");
  const original = readFileSync(targetPath, "utf8");
  const updated = applyRoundtripPatchToModelDoc(
    original,
    readFileSync(patchPath, "utf8"),
  );
  const changed = updated !== original;
  if (options.write) {
    writeFileSync(targetPath, updated);
  }
  console.log(
    JSON.stringify(
      {
        mode: options.write ? "write" : "dry-run",
        target: targetPath,
        patch: patchPath,
        changed,
        preview: options.write ? null : updated,
      },
      null,
      2,
    ),
  );
} catch (error) {
  usage();
  console.error(String(error.message ?? error));
  process.exit(1);
}
