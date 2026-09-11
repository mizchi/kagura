#!/usr/bin/env node

/**
 * Expand snapshot strings the way `vlmkit stress i18n` inflates DOM text,
 * re-measure with `dot_text_size`, and re-run the integrity gate.
 *
 * Default profile is German-style word inflation. Script/emoji/digit profiles
 * are opt-in because an ASCII HUD will always tofu them.
 */

import { readFileSync } from "node:fs";

import { I18N_PROFILES, analyzeI18nStress, formatI18nReport } from "./ui-i18n-utils.mjs";

function usage() {
  return [
    "Usage: node scripts/ui-i18n.mjs <ui-snapshot.json> [options]",
    "",
    "Options:",
    "  --profiles <list>  Comma-separated profiles, or `all`",
    `                     Known: ${I18N_PROFILES.join(", ")} (default: de)`,
    "  --json             Print the report as JSON",
    "  --advisory         Print findings but exit 0",
    "  -h, --help         Show this help",
  ].join("\n");
}

function parseArgs(argv) {
  const options = { source: null, profiles: null, json: false, advisory: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "-h":
      case "--help":
        process.stdout.write(`${usage()}\n`);
        process.exit(0);
        break;
      case "--profiles": {
        const value = argv[++i];
        if (value === undefined) throw new Error("--profiles needs a list");
        options.profiles = value.split(",").map((name) => name.trim()).filter(Boolean);
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
  const raw = readFileSync(options.source, "utf8");
  const result = analyzeI18nStress(raw, { profiles: options.profiles ?? undefined });
  if (options.json) {
    const printable = {
      source: options.source,
      ok: result.ok,
      profiles: Object.fromEntries(
        Object.entries(result.profiles).map(([name, profile]) => [
          name,
          { findings: profile.findings, missingGlyphs: profile.missingGlyphs },
        ]),
      ),
    };
    process.stdout.write(`${JSON.stringify(printable, null, 2)}\n`);
  } else {
    process.stdout.write(`${formatI18nReport(result, { source: options.source })}\n`);
  }
  if (options.advisory) return 0;
  return result.ok ? 0 : 1;
}

try {
  process.exitCode = main(process.argv.slice(2));
} catch (error) {
  process.stderr.write(`ui-i18n: ${error.message}\n`);
  process.exitCode = 2;
}
