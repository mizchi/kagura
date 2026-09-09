import { copyFileSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { tmpdir } from "node:os";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

import {
  buildDuckdbAppendSql,
  buildDuckdbPath,
  buildDuckdbSummarySql,
  buildHypothesisParquetPath,
  timestampToExperimentId,
} from "./balance_autoplay_record_utils.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, "../../..");
const exampleRoot = resolve(scriptDir, "..");
const defaultOutDir = resolve(
  exampleRoot,
  "data/hackslash/autoplay_hypothesis_experiments",
);
const defaultTableName = "autoplay_hypothesis_experiments";
const defaultHypotheses = [
  "default",
  "action_dense",
  "item_spike_feedback",
  "build_diverse_hackslash",
  "mechanics_roguelike",
  "mechanics_roguelike_v2",
  "autoplay_progression",
];
const defaultArchetypes = ["melee", "mage", "summoner", "ranger"];
const defaultBuildPolicies = ["aligned", "anti_synergy"];
const balanceAutoplayJsEntry = resolve(
  exampleRoot,
  "_build/js/debug/build/balance_autoplay/balance_autoplay.js",
);

function parseArgs(argv) {
  const options = {
    outDir: defaultOutDir,
    dbPath: null,
    tableName: defaultTableName,
    hypotheses: defaultHypotheses,
    archetypes: defaultArchetypes,
    buildPolicies: defaultBuildPolicies,
    maxGenerations: 8,
    simMaxFrames: 2400,
    startFloor: 5,
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
    } else if (arg === "--hypotheses") {
      options.hypotheses = argv[i + 1]
        .split(",")
        .map((value) => value.trim())
        .filter(Boolean);
      i += 1;
    } else if (arg === "--archetypes") {
      options.archetypes = argv[i + 1]
        .split(",")
        .map((value) => value.trim())
        .filter(Boolean);
      i += 1;
    } else if (arg === "--build-policies") {
      options.buildPolicies = argv[i + 1]
        .split(",")
        .map((value) => value.trim())
        .filter(Boolean);
      i += 1;
    } else if (arg === "--max-generations") {
      options.maxGenerations = Number.parseInt(argv[i + 1], 10);
      i += 1;
    } else if (arg === "--sim-max-frames") {
      options.simMaxFrames = Number.parseInt(argv[i + 1], 10);
      i += 1;
    } else if (arg === "--start-floor") {
      options.startFloor = Number.parseInt(argv[i + 1], 10);
      i += 1;
    } else {
      throw new Error(`unknown argument: ${arg}`);
    }
  }
  if (options.hypotheses.length === 0) {
    throw new Error("at least one hypothesis is required");
  }
  if (options.archetypes.length === 0) {
    throw new Error("at least one archetype is required");
  }
  if (options.buildPolicies.length === 0) {
    throw new Error("at least one build policy is required");
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
  const tempDir = mkdtempSync(join(tmpdir(), "hacknslash-balance-hypothesis-"));
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
  const experimentId = `autoplay-hypotheses-${timestampToExperimentId(createdAtUtc)}`;
  const dbPath = options.dbPath ?? buildDuckdbPath(options.outDir);
  const parquetPaths = [];

  for (const hypothesisName of options.hypotheses) {
    for (const archetypeName of options.archetypes) {
      for (const buildPolicyName of options.buildPolicies) {
        const parquetPath = buildHypothesisParquetPath(
          options.outDir,
          experimentId,
          hypothesisName,
          archetypeName,
          buildPolicyName,
        );
        parquetPaths.push(parquetPath);
        runBalanceAutoplayJs([
          parquetPath,
          experimentId,
          createdAtUtc,
          hypothesisName,
          "balance_hypothesis_record",
          String(options.startFloor),
          String(options.simMaxFrames),
          String(options.maxGenerations),
          archetypeName,
          buildPolicyName,
        ]);
        run("duckdb", [
          dbPath,
          "-c",
          buildDuckdbAppendSql(options.tableName, parquetPath),
        ]);
      }
    }
  }

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
        dbPath,
        outDir: options.outDir,
        parquetPaths,
        hypotheses: options.hypotheses,
        archetypes: options.archetypes,
        buildPolicies: options.buildPolicies,
        tableName: options.tableName,
        summary: JSON.parse(summary),
      },
      null,
      2,
    ),
  );
}

main();
