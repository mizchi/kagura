#!/usr/bin/env node
// Turns batch replies ("<id>: YES" lines) into a responses file for score.mjs.
//
//   node import.mjs --model <id> --harness "<how it was run>" --out results/x.responses.jsonl reply1.txt reply2.txt ...
//
// Lines that do not start with a known problem id are ignored; the last
// line for an id wins.

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

import { PROMPT_VERSION } from "./lib/prompt.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: { model: { type: "string" }, harness: { type: "string", default: "batched" }, out: { type: "string" }, settings: { type: "string", default: "{}" } },
});
if (!opt.model || !opt.out || positionals.length === 0) {
  console.error("usage: node import.mjs --model <id> --out <file> [--harness text] [--settings json] reply.txt...");
  process.exit(2);
}
const ids = new Set(
  readFileSync(join(here, "data", "problems.jsonl"), "utf8")
    .split("\n")
    .filter(Boolean)
    .map((l) => JSON.parse(l).id),
);
const found = new Map();
for (const file of positionals) {
  for (const line of readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = line.replace(/[*`]/g, "").match(/^\s*([a-z]+-\d{3})\s*:\s*(.+?)\s*$/);
    if (m && ids.has(m[1])) found.set(m[1], m[2]);
  }
}
const rows = [...found].map(([id, ans]) =>
  JSON.stringify({ id, model: opt.model, provider: opt.harness, prompt_version: `${PROMPT_VERSION}+batch`, settings: JSON.parse(opt.settings), response: `ANSWER: ${ans}` }),
);
writeFileSync(opt.out, rows.join("\n") + "\n");
console.log(`imported ${rows.length}/${ids.size} answers into ${opt.out}`);
