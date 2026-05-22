import { copyFileSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { tmpdir } from "node:os";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

import {
  buildDuckdbAppendSql,
  buildDuckdbPath,
  buildDuckdbSummarySql,
  buildParquetPath,
  timestampToExperimentId,
} from "./balance_autoplay_record_utils.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, "../../..");
const exampleRoot = resolve(scriptDir, "..");
const defaultOutDir = resolve(exampleRoot, "data/hackslash/autoplay_experiments");
const defaultTableName = "autoplay_experiments";
const balanceAutoplayJsEntry = resolve(
  exampleRoot,
  "_build/js/debug/build/balance_autoplay/balance_autoplay.js",
);

function parseArgs(argv) {
  const options = {
    outDir: defaultOutDir,
    dbPath: null,
    tableName: defaultTableName,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--out-dir") {
      options.outDir = resolve(repoRoot, argv[i + 1]);
      i += 1;
    } else if (arg === "--db") {
      options.dbPath = resolve(repoRoot, argv[i + 1]);
      i += 1;
    } else if (arg === "--table") {
      options.tableName = argv[i + 1];
      i += 1;
    } else {
      throw new Error(`unknown argument: ${arg}`);
    }
  }
  return options;
}

function run(command, args, cwd = repoRoot) {
  const result = spawnSync(command, args, {
    cwd,
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(
      [
        `${command} ${args.join(" ")} failed with exit code ${result.status}`,
        result.stdout.trim(),
        result.stderr.trim(),
      ]
        .filter(Boolean)
        .join("\n"),
    );
  }
  return result.stdout;
}

function runBalanceAutoplayJs(args) {
  run("moon", [
    "-C",
    "examples/hacknslash_3d",
    "build",
    "src/balance_autoplay",
    "--target",
    "js",
  ]);
  const tempDir = mkdtempSync(join(tmpdir(), "hacknslash-balance-autoplay-"));
  const tempEntry = join(tempDir, "balance_autoplay.cjs");
  try {
    copyFileSync(balanceAutoplayJsEntry, tempEntry);
    run("node", [tempEntry, ...args], repoRoot);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  mkdirSync(options.outDir, { recursive: true });
  const createdAtUtc = new Date().toISOString();
  const experimentId = `autoplay-${timestampToExperimentId(createdAtUtc)}`;
  const parquetPath = buildParquetPath(options.outDir, experimentId);
  const dbPath = options.dbPath ?? buildDuckdbPath(options.outDir);

  runBalanceAutoplayJs([
    parquetPath,
    experimentId,
    createdAtUtc,
  ]);

  run("duckdb", [dbPath, "-c", buildDuckdbAppendSql(options.tableName, parquetPath)]);
  const summary = run("duckdb", [
    dbPath,
    "-json",
    "-noheader",
    "-c",
    buildDuckdbSummarySql(options.tableName, experimentId),
  ]);

  console.log(
    JSON.stringify(
      {
        experimentId,
        createdAtUtc,
        parquetPath,
        dbPath,
        tableName: options.tableName,
        summary: JSON.parse(summary),
      },
      null,
      2,
    ),
  );
}

main();
