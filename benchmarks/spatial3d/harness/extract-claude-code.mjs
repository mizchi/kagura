#!/usr/bin/env node
// Reads Claude Code subagent transcripts (the JSONL `output_file` of each
// background Agent) and prints, per transcript, the models that served it,
// the tools it called, and the answer lines ("<id>: ...") of its final reply.
//
//   node harness/extract-claude-code.mjs --out replies/ <transcript.output>...
//
// Writes replies/<transcript>.txt for import.mjs and prints an audit table.
// A run is valid only if every transcript lists exactly one Read (the batch
// file) besides the hand-back.

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";
import { parseArgs } from "node:util";

const { values: opt, positionals } = parseArgs({ allowPositionals: true, options: { out: { type: "string" } } });
if (!opt.out || positionals.length === 0) {
  console.error("usage: node harness/extract-claude-code.mjs --out <dir> <transcript.output>...");
  process.exit(2);
}
mkdirSync(opt.out, { recursive: true });
const ANSWER = /^\s*\**`?((?:pair|compound|frame|torus|scene|dist)-\d{3})`?\**\s*:\s*`?([^`\n]+?)`?\s*$/gm;
let bad = 0;
for (const file of positionals) {
  const texts = [];
  const tools = [];
  const models = new Set();
  for (const line of readFileSync(file, "utf8").split("\n")) {
    if (!line) continue;
    let j;
    try {
      j = JSON.parse(line);
    } catch {
      continue;
    }
    if (j.type !== "assistant" || !Array.isArray(j.message?.content)) continue;
    if (j.message.model) models.add(j.message.model);
    for (const c of j.message.content) {
      if (c.type === "text") texts.push(c.text);
      if (c.type === "tool_use") {
        tools.push(c.name);
        // The hand-back's report is a string field; take string values as-is
        // so an answer on its first line is not glued to JSON syntax.
        if (c.name === "SubagentHandback") texts.push(...Object.values(c.input ?? {}).filter((v) => typeof v === "string"));
      }
    }
  }
  const answers = new Map();
  for (const m of texts.join("\n").matchAll(ANSWER)) answers.set(m[1], `${m[1]}: ${m[2]}`);
  writeFileSync(join(opt.out, `${basename(file)}.txt`), [...answers.values()].join("\n") + "\n");
  const work = tools.filter((t) => t !== "SubagentHandback");
  const ok = work.length === 1 && work[0] === "Read";
  if (!ok) bad++;
  console.log(`${basename(file)}\tanswers=${answers.size}\tmodels=${[...models].join(",")}\ttools=${tools.join(",")}\t${ok ? "OK" : "INVALID"}`);
}
if (bad) {
  console.error(`${bad} transcript(s) used tools beyond the one Read`);
  process.exit(1);
}
