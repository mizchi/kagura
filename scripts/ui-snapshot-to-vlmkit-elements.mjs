#!/usr/bin/env node

/**
 * Convert a UI snapshot into a vlmkit `--elements-json` payload.
 *
 * `vlmkit diff png --elements-json` is the one vlmkit gate whose element schema
 * is DOM-agnostic, so this is how a canvas-rendered UI gets pixel-diff regions
 * attributed to named UI nodes:
 *
 *   node scripts/ui-snapshot-to-vlmkit-elements.mjs snapshot.json -o elements.json
 *   vlmkit diff png base.png current.png --elements-json elements.json
 */

import { readFileSync, writeFileSync } from "node:fs";

import { toVlmkitElements } from "./ui-snapshot-utils.mjs";

function usage() {
  return [
    "Usage: node scripts/ui-snapshot-to-vlmkit-elements.mjs <ui-snapshot.json> [options]",
    "       node scripts/ui-snapshot-to-vlmkit-elements.mjs - [options]     # read stdin",
    "",
    "Options:",
    "  -o, --out <path>       Write to a file instead of stdout",
    "  --scale <dpr|number>   Snapshot-unit to frame-pixel factor (default: dpr).",
    "                         The captured PNG is dpr-scaled, so leaving this at 1",
    "                         when dpr is 2 misaligns every rect against the image.",
    "  --include-invisible    Keep nodes marked invisible (dropped by default)",
    "  -h, --help             Show this help",
  ].join("\n");
}

function parseArgs(argv) {
  const options = { source: null, out: null, scale: "dpr", includeInvisible: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "-h":
      case "--help":
        process.stdout.write(`${usage()}\n`);
        process.exit(0);
        break;
      case "-o":
      case "--out": {
        const value = argv[++i];
        if (value === undefined) throw new Error("--out needs a path");
        options.out = value;
        break;
      }
      case "--scale": {
        const value = argv[++i];
        if (value === undefined) throw new Error("--scale needs a value");
        options.scale = value;
        break;
      }
      case "--include-invisible":
        options.includeInvisible = true;
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
  const payload = toVlmkitElements(raw, {
    scale: options.scale,
    includeInvisible: options.includeInvisible,
  });
  const text = `${JSON.stringify(payload, null, 2)}\n`;
  if (options.out === null) {
    process.stdout.write(text);
  } else {
    writeFileSync(options.out, text);
    process.stderr.write(`wrote ${payload.elements.length} elements to ${options.out}\n`);
  }
  return 0;
}

try {
  process.exitCode = main(process.argv.slice(2));
} catch (error) {
  process.stderr.write(`ui-snapshot-to-vlmkit-elements: ${error.message}\n`);
  process.exitCode = 2;
}
