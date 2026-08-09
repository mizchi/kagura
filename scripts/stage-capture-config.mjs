#!/usr/bin/env node

/**
 * Stage the capture config an example reads before a native capture run.
 *
 * The example looks for `kagura_native_capture_config.txt` in its own directory
 * (see `modules/kagura_engine/capture`) and writes the frame PNG, the
 * machine-readable context and a summary to the paths it names. Absolute paths,
 * because the example runs with its own directory as the working directory.
 */

import { mkdirSync, writeFileSync } from "node:fs";
import { basename, isAbsolute, join, resolve } from "node:path";

export const CAPTURE_CONFIG_FILENAME = "kagura_native_capture_config.txt";

/**
 * Build the config text.
 *
 * Keys are `<key>=<value>` per line, parsed by `@capture.parse_capture_config`.
 * Paths are resolved here rather than in the engine so the config is unambiguous
 * regardless of where the example is launched from.
 */
export function buildCaptureConfig({ outDir, name, binarize = false }) {
  const dir = resolve(outDir);
  return [
    `screenshot_path=${join(dir, `${name}.png`)}`,
    `context_path=${join(dir, `${name}.context.json`)}`,
    `summary_path=${join(dir, `${name}.summary.txt`)}`,
    `binarize=${binarize ? "1" : "0"}`,
    "",
  ].join("\n");
}

function usage() {
  return [
    "Usage: node scripts/stage-capture-config.mjs --example-dir <dir> --out-dir <dir> [options]",
    "",
    "Options:",
    "  --example-dir <dir>  Example project root (the config is written into it)",
    "  --out-dir <dir>      Where the captured artifacts go",
    "  --name <name>        Artifact basename (default: the example directory name)",
    "  --binarize           Capture in black and white (silhouette review)",
    "  -h, --help           Show this help",
  ].join("\n");
}

function parseArgs(argv) {
  const options = { exampleDir: null, outDir: null, name: null, binarize: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "-h":
      case "--help":
        process.stdout.write(`${usage()}\n`);
        process.exit(0);
        break;
      case "--example-dir":
        options.exampleDir = argv[++i] ?? null;
        break;
      case "--out-dir":
        options.outDir = argv[++i] ?? null;
        break;
      case "--name":
        options.name = argv[++i] ?? null;
        break;
      case "--binarize":
        options.binarize = true;
        break;
      default:
        throw new Error(`unknown option: ${arg}`);
    }
  }
  if (options.exampleDir === null) throw new Error(`--example-dir is required\n\n${usage()}`);
  if (options.outDir === null) throw new Error(`--out-dir is required\n\n${usage()}`);
  return options;
}

function main(argv) {
  const options = parseArgs(argv);
  const exampleDir = resolve(options.exampleDir);
  const outDir = isAbsolute(options.outDir) ? options.outDir : resolve(options.outDir);
  const name = options.name ?? basename(exampleDir);
  mkdirSync(outDir, { recursive: true });
  const configPath = join(exampleDir, CAPTURE_CONFIG_FILENAME);
  writeFileSync(configPath, buildCaptureConfig({ outDir, name, binarize: options.binarize }));
  process.stderr.write(`staged ${configPath}\n  artifacts -> ${join(outDir, `${name}.*`)}\n`);
  return 0;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  try {
    process.exitCode = main(process.argv.slice(2));
  } catch (error) {
    process.stderr.write(`stage-capture-config: ${error.message}\n`);
    process.exitCode = 2;
  }
}
