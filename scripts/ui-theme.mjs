#!/usr/bin/env node

/**
 * Check a frame's palette against a declared theme token table.
 *
 * Extracts dominant colors with `vlmkit check palette --json`, then scores
 * each against the tokens. A color farther than `maxDistance` is a hard-coded
 * literal. Unused tokens are listed, not failed.
 */

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import { analyzeTheme, formatThemeReport } from "./ui-theme-utils.mjs";

function usage() {
  return [
    "Usage: node scripts/ui-theme.mjs <frame.png> [theme.json] [options]",
    "",
    "Options:",
    "  --json        Print the report as JSON",
    "  --advisory    Print findings but exit 0",
    "  -h, --help    Show this help",
  ].join("\n");
}

function parseArgs(argv) {
  const options = { image: null, theme: null, json: false, advisory: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "-h":
      case "--help":
        process.stdout.write(`${usage()}\n`);
        process.exit(0);
        break;
      case "--json":
        options.json = true;
        break;
      case "--advisory":
        options.advisory = true;
        break;
      default:
        if (arg.startsWith("--")) throw new Error(`unknown option: ${arg}`);
        if (options.image === null) options.image = arg;
        else if (options.theme === null) options.theme = arg;
        else throw new Error(`unexpected extra argument: ${arg}`);
    }
  }
  if (options.image === null) throw new Error(`missing <frame.png>\n\n${usage()}`);
  return options;
}

function extractPalette(image) {
  const stdout = execFileSync(
    "pnpm",
    ["exec", "vlmkit", "check", "palette", image, "--json", "--top", "16"],
    { cwd: resolve(import.meta.dirname, ".."), encoding: "utf8" },
  );
  const report = JSON.parse(stdout);
  if (!Array.isArray(report.palette)) throw new Error("vlmkit palette report has no palette");
  return report.palette;
}

function main(argv) {
  const options = parseArgs(argv);
  const themePath = options.theme ?? "examples/demos-2d/ui_demo/editor/theme.json";
  const theme = JSON.parse(readFileSync(themePath, "utf8"));
  const result = analyzeTheme(extractPalette(resolve(options.image)), theme);
  if (options.json) {
    process.stdout.write(`${JSON.stringify({ source: options.image, theme: themePath, ...result }, null, 2)}\n`);
  } else {
    process.stdout.write(`${formatThemeReport(result, { source: options.image })}\n`);
  }
  if (options.advisory) return 0;
  return result.ok ? 0 : 1;
}

try {
  process.exitCode = main(process.argv.slice(2));
} catch (error) {
  process.stderr.write(`ui-theme: ${error.message}\n`);
  process.exitCode = 2;
}
