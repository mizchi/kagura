#!/usr/bin/env node
// Collects model replies for the spatial3d dataset.
//
//   node run.mjs --provider anthropic --model claude-opus-5-5 [--effort high]
//   node run.mjs --provider openai --model <id> [--base-url https://.../v1]
//   node run.mjs --provider command --model <label> --cmd "some-cli --flag"
//   node run.mjs --export-prompts prompts.jsonl
//   node run.mjs --export-batches dir/ [--batch-size 28]   (then import.mjs)
//
// Common options: --dataset v1|v2 (default v2), --split lite|full|all (default all), --concurrency 4,
//   --out results/<dataset>/<label>.responses.jsonl, --limit N.
// Output is resumable: ids already present in --out are skipped.
//
// Providers:
//   anthropic  Messages API through @anthropic-ai/sdk (npm i @anthropic-ai/sdk).
//              Adaptive thinking, effort from --effort. No refusal fallback,
//              so every reply comes from the model being measured.
//   openai     Any OpenAI-compatible /chat/completions endpoint
//              (OPENAI_API_KEY, --base-url or OPENAI_BASE_URL).
//   command    Pipes the prompt to a shell command on stdin and reads the
//              reply from stdout (e.g. a vendor CLI in non-interactive mode).

import { spawn } from "node:child_process";
import { appendFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

import { buildBatchPrompt, buildPrompt, datasetSpec, parseAnswer } from "./lib/prompt.mjs";

const here = dirname(fileURLToPath(import.meta.url));

const { values: opt } = parseArgs({
  options: {
    provider: { type: "string" },
    model: { type: "string" },
    effort: { type: "string", default: "high" },
    "max-tokens": { type: "string", default: "64000" },
    "base-url": { type: "string" },
    cmd: { type: "string" },
    split: { type: "string", default: "all" },
    limit: { type: "string" },
    concurrency: { type: "string", default: "4" },
    dataset: { type: "string", default: "v2" },
    out: { type: "string" },
    "export-prompts": { type: "string" },
    "export-batches": { type: "string" },
    "batch-size": { type: "string", default: "28" },
  },
});

const readJsonl = (p) =>
  readFileSync(p, "utf8")
    .split("\n")
    .filter(Boolean)
    .map((l) => JSON.parse(l));

const PROMPT_VERSION = datasetSpec(opt.dataset).promptVersion;
const dataDir = join(here, "data", opt.dataset);
const problems = readJsonl(join(dataDir, "problems.jsonl"));
const splitOf = new Map(readJsonl(join(dataDir, "answers.jsonl")).map((a) => [a.id, a.split]));
let selected = problems.filter((p) => opt.split === "all" || splitOf.get(p.id) === opt.split);
if (opt.limit) selected = selected.slice(0, Number(opt.limit));

if (opt["export-prompts"]) {
  const rows = selected.map((p) => JSON.stringify({ id: p.id, task: p.task, prompt_version: PROMPT_VERSION, prompt: buildPrompt(p, opt.dataset) }));
  writeFileSync(opt["export-prompts"], rows.join("\n") + "\n");
  console.log(`wrote ${rows.length} prompts to ${opt["export-prompts"]}`);
  process.exit(0);
}

if (opt["export-batches"]) {
  const dir = opt["export-batches"];
  mkdirSync(dir, { recursive: true });
  let n = 0;
  for (const task of ["pair", "scene"]) {
    const items = selected.filter((p) => p.task === task);
    const size = task === "scene" ? Math.max(1, Math.round(Number(opt["batch-size"]) / 5)) : Number(opt["batch-size"]);
    for (let i = 0; i < items.length; i += size) {
      writeFileSync(join(dir, `batch-${String(n++).padStart(2, "0")}-${task}.txt`), buildBatchPrompt(task, items.slice(i, i + size), opt.dataset) + "\n");
    }
  }
  console.log(`wrote ${n} batch prompts to ${dir}`);
  process.exit(0);
}

if (!opt.provider || !opt.model) {
  console.error("--provider and --model are required (or use --export-prompts)");
  process.exit(2);
}

const label = opt.model.replace(/[^A-Za-z0-9._-]+/g, "_");
const outPath = resolve(opt.out ?? join(here, "results", opt.dataset, `${label}.responses.jsonl`));
mkdirSync(dirname(outPath), { recursive: true });
const done = new Set(existsSync(outPath) ? readJsonl(outPath).map((r) => r.id) : []);
const todo = selected.filter((p) => !done.has(p.id));

async function makeAnthropic() {
  let Anthropic;
  try {
    ({ default: Anthropic } = await import("@anthropic-ai/sdk"));
  } catch {
    throw new Error("install the SDK first: npm i @anthropic-ai/sdk");
  }
  const client = new Anthropic();
  return async (prompt) => {
    const stream = client.messages.stream({
      model: opt.model,
      max_tokens: Number(opt["max-tokens"]),
      thinking: { type: "adaptive" },
      output_config: { effort: opt.effort },
      messages: [{ role: "user", content: prompt }],
    });
    const msg = await stream.finalMessage();
    const text = msg.content
      .filter((b) => b.type === "text")
      .map((b) => b.text)
      .join("");
    return { text, stop_reason: msg.stop_reason, usage: msg.usage };
  };
}

function makeOpenAI() {
  const base = (opt["base-url"] ?? process.env.OPENAI_BASE_URL ?? "https://api.openai.com/v1").replace(/\/$/, "");
  return async (prompt) => {
    const res = await fetch(`${base}/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json", authorization: `Bearer ${process.env.OPENAI_API_KEY ?? ""}` },
      body: JSON.stringify({ model: opt.model, messages: [{ role: "user", content: prompt }] }),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${(await res.text()).slice(0, 300)}`);
    const body = await res.json();
    return { text: body.choices?.[0]?.message?.content ?? "", stop_reason: body.choices?.[0]?.finish_reason, usage: body.usage };
  };
}

function makeCommand() {
  if (!opt.cmd) throw new Error("--cmd is required for --provider command");
  return (prompt) =>
    new Promise((resolveReply, reject) => {
      const child = spawn(opt.cmd, { shell: true, stdio: ["pipe", "pipe", "inherit"] });
      let out = "";
      child.stdout.on("data", (d) => (out += d));
      child.on("error", reject);
      child.on("close", (code) => (code === 0 ? resolveReply({ text: out, stop_reason: "exit_0" }) : reject(new Error(`exit ${code}`))));
      child.stdin.end(prompt);
    });
}

const call = opt.provider === "anthropic" ? await makeAnthropic() : opt.provider === "openai" ? makeOpenAI() : opt.provider === "command" ? makeCommand() : null;
if (!call) {
  console.error(`unknown provider ${opt.provider}`);
  process.exit(2);
}

console.log(`${todo.length} to run (${done.size} already in ${outPath})`);
let next = 0;
let failures = 0;
async function worker() {
  while (next < todo.length) {
    const p = todo[next++];
    const started = Date.now();
    try {
      const r = await call(buildPrompt(p, opt.dataset));
      const row = {
        id: p.id,
        model: opt.model,
        provider: opt.provider,
        prompt_version: PROMPT_VERSION,
        settings: opt.provider === "anthropic" ? { effort: opt.effort, thinking: "adaptive" } : {},
        response: r.text,
        parsed: parseAnswer(p.task, r.text),
        stop_reason: r.stop_reason,
        usage: r.usage,
        elapsed_ms: Date.now() - started,
      };
      appendFileSync(outPath, JSON.stringify(row) + "\n");
      console.log(`${p.id} -> ${JSON.stringify(row.parsed)} (${row.elapsed_ms}ms)`);
    } catch (e) {
      failures++;
      console.error(`${p.id} failed: ${e.message}`);
    }
  }
}
await Promise.all(Array.from({ length: Number(opt.concurrency) }, worker));
if (failures) {
  console.error(`${failures} failed; rerun the same command to retry them`);
  process.exit(1);
}
