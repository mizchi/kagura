#!/usr/bin/env node

import {
  formatBoundaryReport,
  validateModuleImportBoundaries,
} from "./moon-boundary-utils.mjs";

function parseArgs(argv) {
  return {
    json: argv.includes("--json"),
  };
}

const args = parseArgs(process.argv.slice(2));
const result = validateModuleImportBoundaries();

if (args.json) {
  process.stdout.write(
    `${JSON.stringify({
      errors: result.errors,
      violations: result.violations,
      modules: result.modules.map((mod) => ({
        name: mod.name,
        dir: mod.dir,
      })),
    }, null, 2)}\n`,
  );
} else {
  process.stdout.write(formatBoundaryReport(result));
}

if (result.errors.length > 0) {
  process.exitCode = 1;
}
