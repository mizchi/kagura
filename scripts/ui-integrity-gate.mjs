#!/usr/bin/env node

/**
 * Deterministic UI integrity gate — the canvas-UI counterpart of
 * `vlmkit check integrity`.
 *
 * Reads a UI snapshot (published by `@ui.publish_ui_snapshot`, or written to
 * `context_path` by the native capture) and reports text overflow, clipping,
 * off-screen HUD, safe-area intrusion, text collision, hit-box drift and
 * collapsed nodes. No browser, no VLM, no API key.
 */

import { readFileSync } from "node:fs";

import { FINDING_KINDS, analyzeSnapshot, formatReport } from "./ui-integrity-utils.mjs";

function usage() {
  return [
    "Usage: node scripts/ui-integrity-gate.mjs <ui-snapshot.json> [options]",
    "       node scripts/ui-integrity-gate.mjs - [options]     # read stdin",
    "",
    "Options:",
    "  --tolerance <px>   Sub-pixel slack before a rect counts as off (default 0.5)",
    "  --allow <rule>     Exempt an intentional pattern, repeatable.",
    "                     Syntax: <kind>[@<id-or-path>];<reason>",
    "                     A reason is required; an unknown kind is an error; an",
    "                     exempted finding is still listed; a rule matching",
    "                     nothing is reported.",
    "  --json             Print the report as JSON",
    "  --advisory         Print findings but exit 0",
    "  -h, --help         Show this help",
    "",
    `Kinds: ${FINDING_KINDS.join(", ")}`,
    "",
    "Exit code is non-zero when any defect remains unexempted, and when an",
    "--allow rule matched nothing (a stale suppression is a defect in itself).",
  ].join("\n");
}

function parseArgs(argv) {
  const options = { source: null, tolerance: 0.5, allow: [], json: false, advisory: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "-h":
      case "--help":
        process.stdout.write(`${usage()}\n`);
        process.exit(0);
        break;
      case "--tolerance": {
        const value = Number(argv[++i]);
        if (!Number.isFinite(value) || value < 0) {
          throw new Error(`--tolerance needs a non-negative number, got: ${argv[i]}`);
        }
        options.tolerance = value;
        break;
      }
      case "--allow": {
        const value = argv[++i];
        if (value === undefined) throw new Error("--allow needs a rule");
        options.allow.push(value);
        break;
      }
      case "--json":
        options.json = true;
        break;
      case "--advisory":
        options.advisory = true;
        break;
      default:
        if (arg.startsWith("--")) throw new Error(`unknown option: ${arg}`);
        if (options.source !== null) throw new Error(`unexpected extra argument: ${arg}`);
        options.source = arg;
    }
  }
  if (options.source === null) throw new Error(`missing <ui-snapshot.json>\n\n${usage()}`);
  return options;
}

function main(argv) {
  const options = parseArgs(argv);
  const raw = options.source === "-"
    ? readFileSync(0, "utf8")
    : readFileSync(options.source, "utf8");
  const result = analyzeSnapshot(raw, { tolerance: options.tolerance, allow: options.allow });

  if (options.json) {
    process.stdout.write(`${JSON.stringify({ source: options.source, ...result }, null, 2)}\n`);
  } else {
    process.stdout.write(`${formatReport(result, { source: options.source })}\n`);
  }

  if (options.advisory) return 0;
  return result.findings.length > 0 || result.unusedAllows.length > 0 ? 1 : 0;
}

try {
  process.exitCode = main(process.argv.slice(2));
} catch (error) {
  process.stderr.write(`ui-integrity-gate: ${error.message}\n`);
  process.exitCode = 2;
}
