#!/usr/bin/env node

import {
  formatPreparedManifestReport,
  validateReleaseWorkspace,
  writePreparedManifests,
} from "./moon-release-utils.mjs";

function parseArgs(argv) {
  const args = {
    dryRun: false,
    json: false,
    moduleFilter: [],
    outDir: "",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const item = argv[i];
    if (item === "--dry-run") {
      args.dryRun = true;
    } else if (item === "--json") {
      args.json = true;
    } else if (item === "--out") {
      i += 1;
      args.outDir = argv[i] ?? "";
    } else if (item === "--module") {
      i += 1;
      args.moduleFilter.push(argv[i] ?? "");
    } else {
      throw new Error(`unknown argument: ${item}`);
    }
  }
  return args;
}

function toJsonResult(result, dryRun) {
  if (dryRun) {
    return {
      errors: result.errors,
      warnings: result.warnings,
      modules: result.preparedManifests.map((prepared) => ({
        name: prepared.module.name,
        sourceDir: prepared.module.dir,
        conversions: prepared.conversions,
      })),
    };
  }
  return {
    errors: result.validation.errors,
    warnings: result.validation.warnings,
    outDir: result.outDir,
    modules: result.summary.modules,
  };
}

let args;
try {
  args = parseArgs(process.argv.slice(2));
} catch (error) {
  console.error(error.message);
  process.exit(2);
}

if (!args.dryRun && !args.outDir) {
  console.error("prepare-moon-release requires --dry-run or --out <dir>");
  process.exit(2);
}

const result = args.dryRun
  ? validateReleaseWorkspace()
  : writePreparedManifests({
      outDir: args.outDir,
      moduleFilter: args.moduleFilter,
    });

if (args.json) {
  process.stdout.write(`${JSON.stringify(toJsonResult(result, args.dryRun), null, 2)}\n`);
} else {
  process.stdout.write(formatPreparedManifestReport(result, { dryRun: args.dryRun }));
}

const errors = args.dryRun ? result.errors : result.validation.errors;
if (errors.length > 0) {
  process.exitCode = 1;
}
