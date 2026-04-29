#!/usr/bin/env node

import {
  formatValidationReport,
  validateReleaseWorkspace,
} from "./moon-release-utils.mjs";

function parseArgs(argv) {
  return {
    json: argv.includes("--json"),
  };
}

const args = parseArgs(process.argv.slice(2));
const result = validateReleaseWorkspace();

if (args.json) {
  process.stdout.write(
    `${JSON.stringify({
      errors: result.errors,
      warnings: result.warnings,
      modules: result.modules.map((mod) => ({
        name: mod.name,
        dir: mod.dir,
        version: mod.version,
      })),
    }, null, 2)}\n`,
  );
} else {
  process.stdout.write(formatValidationReport(result));
}

if (result.errors.length > 0) {
  process.exitCode = 1;
}
