#!/usr/bin/env node

import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import { spawnSync } from "node:child_process";

import {
  buildVlmCloseLoopPlan,
  extractJsonDocument,
  shouldApplyBundlePatch,
  summarizeBundlePatchPayload,
} from "./model-authoring-vlm-close-loop-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-close-loop.mjs \\",
      "  (--edit-profile <profile> | --import-glb <edited.glb>) \\",
      "  [--example model_authoring|chair_authoring|shelf_authoring|frog_authoring] \\",
      "  [--provider openrouter|openai] [--port 8113] [--out-dir output/playwright/<example>-close-loop] [--write]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    example: "model_authoring",
    provider: "openrouter",
    port: 8113,
    outDir: null,
    write: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    switch (arg) {
      case "--example":
        options.example = argv[index + 1];
        index += 1;
        break;
      case "--edit-profile":
        options.editProfile = argv[index + 1];
        index += 1;
        break;
      case "--import-glb":
        options.importGlb = argv[index + 1];
        index += 1;
        break;
      case "--provider":
        options.provider = argv[index + 1];
        index += 1;
        break;
      case "--port":
        options.port = Number(argv[index + 1]);
        index += 1;
        break;
      case "--out-dir":
        options.outDir = argv[index + 1];
        index += 1;
        break;
      case "--write":
        options.write = true;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  return options;
}

function runNodeJson(scriptPath, args, cwd) {
  const result = spawnSync(process.execPath, [resolve(cwd, scriptPath), ...args], {
    cwd,
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || `${scriptPath} failed`);
  }
  return extractJsonDocument(result.stdout);
}

function runCommand(cmd, args, cwd) {
  const result = spawnSync(cmd, args, {
    cwd,
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(result.stderr || result.stdout || `${cmd} ${args.join(" ")} failed`);
  }
}

try {
  const plan = buildVlmCloseLoopPlan({
    cwd: process.cwd(),
    ...parseArgs(process.argv.slice(2)),
  });

  const initial = runNodeJson(
    "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs",
    plan.initialArgs,
    plan.cwd,
  );
  const initialBundle = JSON.parse(readFileSync(initial.bundle, "utf8"));
  const initialSummary = summarizeBundlePatchPayload(initialBundle);
  const feedback = runNodeJson(
    "tools/modeling3d/scripts/model-authoring-vlm-local-feedback.mjs",
    [
      "--bundle",
      initial.bundle,
      "--parsed",
      initial.parsed,
      "--out-dir",
      plan.feedbackOutDir,
    ],
    plan.cwd,
  );
  const patchPath = feedback.opt_in_patch_path ?? feedback.patch_path;
  const apply = shouldApplyBundlePatch(initialSummary)
    ? runNodeJson(
        "tools/modeling3d/scripts/model-authoring-vlm-apply-patch.mjs",
        [
          "--target",
          feedback.target_file,
          "--patch",
          patchPath,
          ...(plan.write ? ["--write"] : []),
        ],
        plan.cwd,
      )
    : {
        mode: plan.write ? "write" : "dry-run",
        target: resolve(plan.cwd, feedback.target_file),
        patch: patchPath,
        changed: false,
        skipped: true,
        reason: "no auto or opt-in patch actions were present in the bundle",
        preview: null,
      };

  if (plan.write && !apply.skipped && existsSync(plan.exampleDir)) {
    runCommand("moon", ["-C", plan.exampleDir, "fmt"], plan.cwd);
    runCommand("moon", ["-C", plan.exampleDir, "check", "--target", "js"], plan.cwd);
    runCommand("moon", ["-C", plan.exampleDir, "test", "--target", "js"], plan.cwd);
  }

  const importGlbPath = initial.import_glb;
  const residual = runNodeJson(
    "tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs",
    [
      "--example",
      plan.example,
      "--import-glb",
      importGlbPath,
      "--provider",
      plan.provider,
      "--serve",
      "--port",
      String(plan.residualPort),
      "--out-dir",
      plan.residualOutDir,
    ],
    plan.cwd,
  );
  const residualBundle = JSON.parse(readFileSync(residual.bundle, "utf8"));

  console.log(
    JSON.stringify(
      {
        mode: plan.write ? "write" : "dry-run",
        example: plan.example,
        initial,
        feedback,
        apply,
        residual: {
          bundle: residual.bundle,
          summary: summarizeBundlePatchPayload(residualBundle),
        },
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
