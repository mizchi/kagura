#!/usr/bin/env node
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { readFile, writeFile, mkdir, open, stat } from "node:fs/promises";
import { resolve, join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { randomUUID } from "node:crypto";
import {
  analyzeExperience,
  compareExperience,
  validateReport,
} from "../game/experience/index.mjs";
import { validateLedger } from "../game/experience/contract.mjs";
import { AgentError, int32 } from "./agents/errors.mjs";
import { renderExperienceMarkdown } from "./experience/markdown.mjs";

const root = fileURLToPath(new URL("../", import.meta.url));
const help = `Kagura loop/arc experience experiments (FATHOM)

just experience-run [options]
  --policy tactical|attack   Local policy; no API calls (default: tactical)
  --seed N                   Signed 32-bit seed (default: 731)
  --max-decisions N          Limit in [1,10000] (default: 400)
  --max-seconds N            Limit in (0,3600] (default: 120)
  --master-data FILE         Master JSON from Studio
  --balance FILE             Candidate balance profile
  --trace FILE               Verify and analyze an existing autoplay JSONL
  --baseline FILE            Previous report.json for descriptive comparison
  --subject ID               Explicit participant identity (default: unique run)
  --knowledge FILE           Previous ledger.json; requires --subject
  --scope ID                 Exposure history scope (default: fathom)
  --out DIRECTORY            New output directory; never overwritten
  --no-build                 Use existing agent_host build
  --help                     Show this help

Writes trace.jsonl, recording.json, events.jsonl, report.json, report.md and
ledger.json. Optional comparison.json preserves unknown values. Presentation
latency and human understanding remain unmeasured without matching evidence.
`;
function args(argv) {
  const o = {
    policy: "tactical",
    seed: 731,
    maxDecisions: 400,
    maxSeconds: 120,
    scope: "fathom",
  };
  const values = new Map([
    ["--policy", "policy"],
    ["--seed", "seed"],
    ["--max-decisions", "maxDecisions"],
    ["--max-seconds", "maxSeconds"],
    ["--master-data", "masterPath"],
    ["--balance", "balancePath"],
    ["--trace", "trace"],
    ["--baseline", "baseline"],
    ["--subject", "subject"],
    ["--knowledge", "knowledge"],
    ["--scope", "scope"],
    ["--out", "out"],
  ]);
  const used = new Set();
  for (let i = 0; i < argv.length; i++) {
    const flag = argv[i];
    if (used.has(flag))
      throw new AgentError("invalid_input", "duplicate option");
    used.add(flag);
    if (flag === "--help") {
      o.help = true;
      continue;
    }
    if (flag === "--no-build") {
      o.noBuild = true;
      continue;
    }
    const name = values.get(flag);
    if (!name || !argv[i + 1] || argv[i + 1].startsWith("--"))
      throw new AgentError("invalid_input", "unknown or incomplete option");
    const value = argv[++i];
    o[name] = ["seed", "maxDecisions", "maxSeconds"].includes(name)
      ? Number(value)
      : value;
  }
  if (o.help) return o;
  int32(o.seed, "seed");
  if (
    !["tactical", "attack"].includes(o.policy) ||
    !Number.isInteger(o.maxDecisions) ||
    o.maxDecisions < 1 ||
    o.maxDecisions > 10000 ||
    !Number.isFinite(o.maxSeconds) ||
    o.maxSeconds <= 0 ||
    o.maxSeconds > 3600
  )
    throw new AgentError("invalid_input", "invalid policy/budget");
  if (
    (o.knowledge && !o.subject) ||
    (o.trace &&
      (o.masterPath ||
        o.balancePath ||
        used.has("--seed") ||
        used.has("--policy")))
  )
    throw new AgentError("invalid_input", "incompatible options");
  for (const key of ["subject", "scope"])
    if (o[key] !== undefined && (!o[key].trim() || o[key].length > 200))
      throw new AgentError("invalid_input", `invalid ${key}`);
  return o;
}
async function read(path) {
  if ((await stat(path)).size > 32 * 1024 * 1024)
    throw new AgentError("invalid_input", "input exceeds 32 MiB");
  return readFile(path, "utf8");
}
async function json(path) {
  try {
    return JSON.parse(await read(path));
  } catch {
    throw new AgentError("invalid_input", "cannot read JSON input");
  }
}
async function build() {
  const exec = promisify(execFile);
  for (const cmd of [
    ["node", ["examples/games/dungeon_rpg/scripts/generate-master-data.mjs"]],
    ["node", ["scripts/prepare-moon-deps.mjs", "examples/games/dungeon_rpg"]],
    [
      "moon",
      [
        "-C",
        "examples/games/dungeon_rpg",
        "build",
        "agent_host",
        "--target",
        "js",
        "--release",
        "--deny-warn",
      ],
    ],
  ])
    await exec(cmd[0] === "node" ? process.execPath : cmd[0], cmd[1], {
      cwd: root,
      maxBuffer: 4 * 1024 * 1024,
    });
}

async function main() {
  const o = args(process.argv.slice(2));
  if (o.help) {
    process.stdout.write(help);
    return;
  }
  const ledger = o.knowledge ? await json(o.knowledge) : [];
  validateLedger(ledger);
  const baseline = o.baseline ? await json(o.baseline) : undefined;
  if (baseline) validateReport(baseline);
  if (!o.noBuild) await build();
  const { createHeadlessSession } = await import(
    "../examples/games/dungeon_rpg/agent/headless.mjs"
  );
  const { runAgent, replayRecords } = await import(
    "../examples/games/dungeon_rpg/agent/runner.mjs"
  );
  const { policyDecision } = await import(
    "../examples/games/dungeon_rpg/agent/policies.mjs"
  );
  const { recordingFromTrace } = await import(
    "./experience/adapters/dungeon-rpg.mjs"
  );
  const config = { seed: o.seed };
  if (o.masterPath) config.masterData = await json(o.masterPath);
  if (o.balancePath) {
    const p = await json(o.balancePath);
    if (p?.schemaVersion !== 1 || p.game !== "dungeon_rpg" || !p.parameters)
      throw new AgentError("invalid_input", "invalid balance profile");
    config.balance = p.parameters;
  }
  let records = [],
    result;
  if (o.trace) {
    try {
      records = (await read(o.trace))
        .split("\n")
        .filter((line) => line.trim())
        .map(JSON.parse);
    } catch {
      throw new AgentError("invalid_input", "cannot read trace");
    }
    result = await replayRecords(records);
    if (records[0].experienceVersion !== 1)
      throw new AgentError(
        "invalid_input",
        "trace has no experience telemetry; record a new run",
      );
  } else createHeadlessSession(config);
  const out = resolve(
    o.out ??
      `output/experience/${new Date().toISOString().replaceAll(":", "-")}`,
  );
  await mkdir(dirname(out), { recursive: true });
  try {
    await mkdir(out);
  } catch {
    throw new AgentError("output_exists", "choose a new output directory");
  }
  const file = await open(join(out, "trace.jsonl"), "wx");
  const controller = new AbortController(),
    interrupt = () => controller.abort();
  process.on("SIGINT", interrupt);
  try {
    if (o.trace) {
      for (const record of records)
        await file.write(JSON.stringify(record) + "\n");
    } else
      result = await runAgent({
        ...config,
        session: createHeadlessSession(config),
        model: `policy:${o.policy}`,
        maxDecisions: o.maxDecisions,
        maxSeconds: o.maxSeconds,
        signal: controller.signal,
        choose: (state) => policyDecision(state, o.policy),
        onRecord: async (record) => {
          records.push(record);
          await file.write(JSON.stringify(record) + "\n");
        },
      });
  } finally {
    process.removeListener("SIGINT", interrupt);
    await file.close();
  }
  const runId = `experience:${randomUUID()}`;
  const recording = recordingFromTrace(records, {
    runId,
    subjectId: o.subject ?? runId,
    scope: o.scope,
    ledger,
  });
  const report = analyzeExperience(recording),
    comparison = baseline ? compareExperience(baseline, report) : undefined;
  const artifacts = {
    "recording.json": recording,
    "report.json": report,
    "ledger.json": report.ledger,
    ...(comparison ? { "comparison.json": comparison } : {}),
  };
  for (const [name, value] of Object.entries(artifacts))
    await writeFile(join(out, name), JSON.stringify(value, null, 2) + "\n", {
      flag: "wx",
    });
  await writeFile(
    join(out, "events.jsonl"),
    recording.events.map((e) => JSON.stringify(e)).join("\n") + "\n",
    { flag: "wx" },
  );
  await writeFile(
    join(out, "report.md"),
    renderExperienceMarkdown(report, { comparison, events: recording.events }),
    { flag: "wx" },
  );
  process.stdout.write(
    JSON.stringify({
      status: result.status,
      valid: report.valid,
      loops: report.loops.length,
      arcs: report.arcs.length,
      report: join(out, "report.json"),
      markdown: join(out, "report.md"),
    }) + "\n",
  );
}
main().catch((error) => {
  process.stderr.write(
    (error instanceof AgentError
      ? error.message
      : `experience_failed: ${error.message}`) + "\n",
  );
  process.exitCode = 1;
});
